const Order = require('../models/Order');
const Product = require('../models/Product');

const createOrder = async (req, res, next) => {
  try {
    if (req.body.eventId != null) return require('./payhereController').createEventOrder(req, res, next);
    const { items, deliveryAddress, notes } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Order must include at least one item' });
    }

    const orderItems = await Promise.all(
      items.map(async (item) => {
        if (!Number.isInteger(item.quantity) || item.quantity < 1 || item.quantity > 100) {
          const error = new Error('Invalid item quantity'); error.statusCode = 400; throw error;
        }
        const product = await Product.findById(item.productId);
        if (!product) {
          throw new Error(`Product not found: ${item.productId}`);
        }
        return {
          product: product._id,
          name: product.name,
          price: product.price,
          quantity: item.quantity || 1,
        };
      })
    );

    const order = await Order.create({
      user: req.user._id,
      items: orderItems,
      totalAmount: orderItems.reduce((sum, item) => sum + Math.round(item.price * 100) * item.quantity, 0) / 100,
      deliveryAddress,
      notes,
    });

    res.status(201).json({ success: true, data: order });
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
    if (order.eventId) return res.status(409).json({ message: 'Event payment orders require payment reconciliation; cancel through support' });
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

module.exports = {
  createOrder,
  getUserOrders,
  getOrderById,
  cancelOrder,
};
