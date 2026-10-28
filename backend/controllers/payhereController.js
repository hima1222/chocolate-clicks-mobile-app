const mongoose = require('mongoose');
const Order = require('../models/Order');
const Event = require('../models/Event');
const { syncWorkshops } = require('../services/workshopSyncService');
const Booking = require('../models/Booking');
const PaymentReceipt = require('../models/PaymentReceipt');
const payhere = require('../services/payhereService');
const { createError } = require('../middleware/errorMiddleware');

const customerFor = (user, billing) => {
  if (!billing || !['address', 'city', 'country'].every((key) =>
    typeof billing[key] === 'string' && billing[key].trim().length > 0 && billing[key].length <= 200)) {
    throw createError('Billing address, city and country are required', 400);
  }
  return { first_name: user.firstName, last_name: user.lastName, email: user.email,
    phone: user.phone, address: billing.address.trim(), city: billing.city.trim(), country: billing.country.trim() };
};

async function createEventOrder(req, res, next) {
  try {
    payhere.config();
    const { eventId, quantity = 1 } = req.body;
    if (!mongoose.isValidObjectId(eventId) || !Number.isInteger(quantity) || quantity < 1 || quantity > 100) {
      throw createError('A valid eventId and quantity from 1 to 100 are required', 400);
    }
    const customer = customerFor(req.user, req.body.billing);
    await syncWorkshops();
    let order;
    let reused = false;
    const session = await mongoose.startSession();
    try {
      await session.withTransaction(async () => {
        order = await Order.findOne({ user: req.user._id, eventId }).session(session);
        reused = Boolean(order);
        if (order) {
          if (order.quantity !== quantity) throw createError('An order already exists for this event with a different quantity', 409);
          return;
        }
        if (await Booking.exists({ userId: req.user._id, eventId, status: 'CONFIRMED' }).session(session)) {
          throw createError('You already booked this event', 409);
        }
        const event = await Event.findOneAndUpdate({
          _id: eventId, sourcePublished: { $ne: false }, startDate: { $gt: new Date() },
          $expr: { $lte: [{ $add: ['$bookedCount', quantity] }, '$capacity'] },
        }, { $inc: { bookedCount: quantity } }, { new: true, session });
        if (!event) throw createError('Event is unavailable or does not have enough seats', 409);
        const unitCents = Math.round(event.price * 100);
        if (!Number.isSafeInteger(unitCents) || unitCents <= 0 ||
            !Number.isSafeInteger(unitCents * quantity)) {
          throw createError('This event does not have a valid payable price', 400);
        }
        const amount = (unitCents * quantity / 100).toFixed(2);
        [order] = await Order.create([{
          user: req.user._id, eventId, eventTitle: event.title, quantity,
          amount, totalAmount: Number(amount), currency: 'LKR', payment_status: 'pending', customer,
        }], { session });
      });
    } finally { await session.endSession(); }
    res.set('Cache-Control', 'no-store');
    res.status(201).json({ success: true, reused, data: order,
      checkout: order.payment_status === 'paid' ? null : payhere.checkout(order, req.body.platform) });
  } catch (error) {
    if (error.code === 11000 && error.keyPattern?.eventId) {
      try {
        const existing = await Order.findOne({ user: req.user._id, eventId: req.body.eventId });
        if (existing && existing.quantity === (req.body.quantity || 1)) {
          res.set('Cache-Control', 'no-store');
          return res.status(200).json({ success: true, reused: true, data: existing,
            checkout: existing.payment_status === 'paid' ? null : payhere.checkout(existing, req.body.platform) });
        }
      } catch (lookupError) { return next(lookupError); }
    }
    next(error);
  }
}

async function notify(req, res, next) {
  try {
    if (!req.is('application/x-www-form-urlencoded')) throw createError('Expected form-encoded notification', 415);
    payhere.verifyNotification(req.body);
    const b = req.body;
    if (!mongoose.isValidObjectId(b.order_id)) throw createError('Invalid order ID', 400);
    const paymentOrder = await Order.findById(b.order_id);
    if (!paymentOrder || !paymentOrder.amount) throw createError('Order not found', 404);
    if (!paymentOrder.eventId) {
      await require('../services/productPaymentService').confirmProductPayment(paymentOrder, b);
      return res.status(200).send('OK');
    }
    const session = await mongoose.startSession();
    try {
      await session.withTransaction(async () => {
        const order = await Order.findById(b.order_id).session(session);
        if (!order || !order.amount) throw createError('Order not found', 404);
        if (b.payhere_amount !== order.amount || b.payhere_currency !== order.currency) {
          throw createError('Payment amount or currency does not match order', 400);
        }
        // Success is monotonic: delayed pending/failure callbacks cannot undo a booking.
        if (order.payment_status === 'paid') {
          if (b.status_code === '2' && order.payhere_payment_id !== b.payment_id) {
            throw createError('Order already paid with a different payment ID; requires reconciliation', 409);
          }
          return;
        }
        if (b.status_code === '2') {
          if (order.eventId) await Booking.create([{ userId: order.user, eventId: order.eventId,
            orderId: order._id, seats: order.quantity }], { session });
          order.payment_status = 'paid';
          order.payhere_payment_id = b.payment_id;
          order.status = 'confirmed';
          await PaymentReceipt.create([{ orderId: order._id, to: order.customer.email,
            subject: order.eventId ? 'Chocolate Clicks booking confirmation' : 'Chocolate Clicks order confirmation',
            text: order.eventId ? `Your booking for ${order.eventTitle} is confirmed.\nSeats: ${order.quantity}\nAmount: ${order.currency} ${order.amount}\nOrder: ${order.id}` : `Your order is confirmed.\n${order.items.map((item) => `${item.name} x ${item.quantity}`).join('\n')}\nAmount: ${order.currency} ${order.amount}\nOrder: ${order.id}\nDelivery to: ${order.deliveryAddress}`,
          }], { session });
        } else if (order.payment_status === 'pending' || b.status_code !== '0') {
          order.payment_status = ({ '0': 'pending', '-1': 'cancelled', '-2': 'failed', '-3': 'chargedback' })[b.status_code];
        }
        await order.save({ session });
      });
    } finally { await session.endSession(); }
    res.status(200).send('OK');
  } catch (error) { next(error); }
}
module.exports = { createEventOrder, notify, customerFor };
