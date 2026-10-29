const mongoose = require('mongoose');
const Order = require('../models/Order');
const { quoteProducts } = require('../services/productPricingService');
const payhere = require('../services/payhereService');
const { customerFor } = require('./payhereController');
const { createError } = require('../middleware/errorMiddleware');

async function sendCheckout(res, order, platform, reused = false) {
  if (order.userDeletedAt) {
    order.userDeletedAt = undefined;
    await order.save();
  }
  res.set('Cache-Control', 'no-store');
  return res.status(reused ? 200 : 201).json({ success: true, reused, data: order,
    checkout: order.payment_status === 'paid' ? null : payhere.checkout(order, platform) });
}

async function createProductOrder(req, res, next) {
  try {
    payhere.config();
    const { items, billing, checkoutKey, expectedTotal, notes } = req.body;
    if (typeof checkoutKey !== 'string' || !/^[a-zA-Z0-9_-]{16,100}$/.test(checkoutKey)) {
      throw createError('A valid checkoutKey is required', 400);
    }
    const existing = await Order.findOne({ user: req.user._id, checkoutKey });
    if (existing) return await sendCheckout(res, existing, req.body.platform, true);
    const customer = customerFor(req.user, billing);
    const quote = await quoteProducts(items, billing.city);
    const totalCents = Math.round(quote.pricing.totalAmount * 100);
    const orderItems = quote.items;
    if (typeof expectedTotal !== 'number' || !Number.isFinite(expectedTotal) || Math.round(expectedTotal * 100) !== totalCents) {
      throw createError('Prices or delivery charges changed. Reload your order summary before paying.', 409);
    }
    if (notes != null && (typeof notes !== 'string' || notes.length > 1000)) throw createError('Invalid order notes', 400);
    let order;
    try {
      order = await Order.create({ user: req.user._id, checkoutKey, items: orderItems,
        pricing: quote.pricing, amount: (totalCents / 100).toFixed(2), totalAmount: totalCents / 100, currency: 'LKR',
        fromCart: req.body.fromCart === true, customer, payment_status: 'pending', status: 'pending', notes,
        deliveryAddress: [customer.first_name + ' ' + customer.last_name, customer.phone,
          customer.address, customer.city, customer.country].join('\n') });
    } catch (error) {
      if (error.code !== 11000) throw error;
      order = await Order.findOne({ user: req.user._id, checkoutKey });
      if (!order) throw error;
      return await sendCheckout(res, order, req.body.platform, true);
    }
    return await sendCheckout(res, order, req.body.platform);
  } catch (error) { next(error); }
}

async function resumeCheckout(req, res, next) {
  try {
    payhere.config();
    if (!mongoose.isValidObjectId(req.params.id)) throw createError('Invalid order ID', 400);
    const order = await Order.findOne({ _id: req.params.id, user: req.user._id });
    if (!order) throw createError('Order not found', 404);
    if (!order.amount || !order.customer?.address) throw createError('This older order cannot be paid online. Please contact support.', 409);
    if (order.status === 'cancelled' || order.payment_status === 'chargedback') throw createError('This order requires support reconciliation.', 409);
    return await sendCheckout(res, order, req.body.platform, true);
  } catch (error) { next(error); }
}
async function quoteProductOrder(req, res, next) {
  try {
    const quote = await quoteProducts(req.body.items, req.body.city);
    res.set('Cache-Control', 'no-store');
    res.json({ success: true, data: quote });
  } catch (error) { next(error); }
}
module.exports = { createProductOrder, resumeCheckout, quoteProductOrder };
