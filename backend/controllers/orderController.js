const Order = require('../models/Order');
const Receipt = require('../models/PaymentReceipt');
const mongoose = require('mongoose');

const createOrder = async (req, res, next) => {
  try {
    if (req.body.eventId != null) return require('./payhereController').createEventOrder(req, res, next);
    return require('./productCheckoutController').createProductOrder(req, res, next);
  } catch (error) {
    next(error);
  }
};

const getUserOrders = async (req, res, next) => {
  try {
    const orders = await Order.find({ user: req.user._id }).sort({ createdAt: -1 }).populate('items.product');
    res.set('Cache-Control', 'no-store');
    res.json({ success: true, data: orders });
  } catch (error) {
    next(error);
  }
};

const getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, user: req.user._id }).populate('items.product');
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    res.set('Cache-Control', 'no-store');
    res.json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
};

const cancelOrder = async (req, res, next) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, user: req.user._id });
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    if (order.eventId || order.amount) return res.status(409).json({ message: 'Payment orders require payment reconciliation; cancel through support' });
    if (order.status === 'completed' || order.status === 'cancelled') {
      return res.status(400).json({ success: false, message: 'Order cannot be cancelled' });
    }
    order.status = 'cancelled';
    await order.save();
    res.set('Cache-Control', 'no-store');
    res.json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
};

async function getConfirmation(req, res, next) {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) return res.status(400).json({ message: 'Invalid order ID' });
    const order = await Order.findOne({ _id: req.params.id, user: req.user._id });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    const receipt = await Receipt.findOne({ orderId: order._id }).select('status sentAt');
    res.set('Cache-Control', 'no-store');
    res.json({ success: true, data: { paymentStatus: order.payment_status,
      emailStatus: receipt?.status || 'unavailable', sentAt: receipt?.sentAt || null } });
  } catch (error) { next(error); }
}
async function resendConfirmation(req, res, next) {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) return res.status(400).json({ message: 'Invalid order ID' });
    const order = await Order.findOne({ _id: req.params.id, user: req.user._id });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (order.payment_status !== 'paid') return res.status(409).json({ message: 'Payment is not confirmed' });
    if (!process.env.SMTP_HOST) return res.status(503).json({ message: 'Email service is not configured' });
    const receipt = await Receipt.findOneAndUpdate({ orderId: order._id,
      status: { $in: ['sent', 'failed'] },
      $or: [{ resendRequestedAt: { $exists: false } },
        { resendRequestedAt: { $lte: new Date(Date.now() - 5 * 60 * 1000) } }],
    }, { $set: { status: 'queued', resendRequestedAt: new Date() } }, { new: true });
    if (!receipt) return res.status(429).json({ message: 'Email is pending or was recently requested. Try again in five minutes.' });
    res.status(202).json({ success: true, data: { emailStatus: 'queued' } });
  } catch (error) { next(error); }
}
module.exports = {
  getConfirmation,
  resendConfirmation,
  createOrder,
  getUserOrders,
  getOrderById,
  cancelOrder,
};
