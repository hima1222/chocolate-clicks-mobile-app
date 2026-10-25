const Order = require('../models/Order');
const Product = require('../models/Product');
const { notifyUser } = require('../services/notificationService');

const createOrder = async (req, res, next) => {
  try {
    const { items, totalAmount, deliveryAddress, notes } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Order must include at least one item',
      });
    }

    const orderItems = await Promise.all(
      items.map(async (item) => {
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
      totalAmount,
      deliveryAddress,
      notes,
    });

    await notifyUser(req.user._id, {
      title: 'Order received',
      message: `Your order ${order._id} has been received and is being processed.`,
      type: 'order',
      actionUrl: `/orders/${order._id}`,
    });

    res.status(201).json({
      success: true,
      data: order,
    });
  } catch (error) {
    next(error);
  }
};

const getUserOrders = async (req, res, next) => {
  try {
    const orders = await Order.find({ user: req.user._id })
      .sort({ createdAt: -1 })
      .populate('items.product');

    res.set('Cache-Control', 'no-store');

    res.json({
      success: true,
      data: orders,
    });
  } catch (error) {
    next(error);
  }
};

const getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
    }).populate('items.product');

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    res.set('Cache-Control', 'no-store');

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    next(error);
  }
};

const cancelOrder = async (req, res, next) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    if (order.status === 'completed' || order.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Order cannot be cancelled',
      });
    }

    order.status = 'cancelled';
    await order.save();

    await notifyUser(req.user._id, {
      title: 'Order cancelled',
      message: `Your order ${order._id} has been cancelled.`,
      type: 'delivery',
      actionUrl: `/orders/${order._id}`,
    });

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    next(error);
  }
};

const updateOrderStatus = async (req, res, next) => {
  try {
    const { status } = req.body;

    const validStatuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'completed',
      'cancelled',
    ];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid order status',
      });
    }

    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    if (order.status === status) {
      return res.json({
        success: true,
        data: order,
      });
    }

    order.status = status;

    if (status === 'completed') {
      order.completedAt = new Date();
    }

    await order.save();

    await notifyUser(order.user, {
      title: 'Delivery status updated',
      message: `Your order ${order._id} is now ${status}.`,
      type: 'delivery',
      actionUrl: `/orders/${order._id}`,
    });

    res.set('Cache-Control', 'no-store');

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createOrder,
  getUserOrders,
  getOrderById,
  cancelOrder,
  updateOrderStatus,
};