const Order = require('../models/Order');
const Receipt = require('../models/PaymentReceipt');
const { createError } = require('../middleware/errorMiddleware');

async function queueProductReceipt(order) {
  if (order.eventId || order.payment_status !== 'paid') return;
  const receipt = { orderId: order._id, to: order.customer.email,
    subject: 'Chocolate Clicks order confirmation',
    text: `Your order is confirmed.\n${order.items.map((item) => `${item.name} x ${item.quantity}`).join('\n')}\nAmount: ${order.currency} ${order.amount}\nOrder: ${order._id}\nDelivery to: ${order.deliveryAddress}` };
  try { await Receipt.updateOne({ orderId: order._id }, { $setOnInsert: receipt }, { upsert: true }); }
  catch (error) {
    // Concurrent callbacks may both insert against the unique receipt index.
    if (error.code !== 11000 || !await Receipt.exists({ orderId: order._id })) throw error;
  }
  await Order.updateOne({ _id: order._id, payment_status: 'paid' }, { $set: { receiptQueued: true } });
}

async function confirmProductPayment(order, notice) {
  if (notice.payhere_amount !== order.amount || notice.payhere_currency !== order.currency) {
    throw createError('Payment amount or currency does not match order', 400);
  }
  if (notice.status_code === '2' && order.payment_status !== 'paid') {
    try {
      const updated = await Order.findOneAndUpdate({ _id: order._id, amount: notice.payhere_amount,
        currency: notice.payhere_currency, payment_status: { $ne: 'paid' } },
      { $set: { payment_status: 'paid', status: 'confirmed', payhere_payment_id: notice.payment_id, receiptQueued: false } }, { new: true });
      order = updated || await Order.findById(order._id);
    } catch (error) {
      if (error.code === 11000) throw createError('Payment ID already belongs to an order; requires reconciliation', 409);
      throw error;
    }
  }
  if (order.payment_status === 'paid') {
    if (notice.status_code === '2' && order.payhere_payment_id !== notice.payment_id) {
      throw createError('Order already paid with a different payment ID; requires reconciliation', 409);
    }
    await queueProductReceipt(order);
    return;
  }
  const status = ({ '0': 'pending', '-1': 'cancelled', '-2': 'failed', '-3': 'chargedback' })[notice.status_code];
  if (status) {
    const filter = { _id: order._id, payment_status: notice.status_code === '0' ? 'pending' : { $ne: 'paid' } };
    await Order.updateOne(filter, { $set: { payment_status: status } });
  }
}

// Repair a crash between the atomic paid-order update and receipt enqueueing.
// This runs even when SMTP is disabled, so receipts remain durably queued.
async function repairProductReceipts() {
  const orders = await Order.find({ payment_status: 'paid', eventId: { $exists: false },
    amount: { $exists: true }, receiptQueued: { $ne: true } }).limit(50);
  for (const order of orders) await queueProductReceipt(order);
}
module.exports = { confirmProductPayment, repairProductReceipts };
