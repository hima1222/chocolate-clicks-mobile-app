const Product = require('../models/Product');
const { notifyAllUsers } = require('../services/notificationService');

const getProducts = async (req, res, next) => {
  try {
    const products = await Product.find();
    res.json({ success: true, data: products });
  } catch (error) {
    next(error);
  }
};

const getProductsByCategory = async (req, res, next) => {
  try {
    const { categoryId } = req.params;
    const products = await Product.find({ categoryId });
    res.json({ success: true, data: products });
  } catch (error) {
    next(error);
  }
};

const getProductById = async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }
    res.json({ success: true, data: product });
  } catch (error) {
    next(error);
  }
};

const searchProducts = async (req, res, next) => {
  try {
    const { q } = req.query;
    const filter = q
      ? {
          $or: [
            { name: { $regex: q, $options: 'i' } },
            { description: { $regex: q, $options: 'i' } },
          ],
        }
      : {};
    const products = await Product.find(filter);
    res.json({ success: true, data: products });
  } catch (error) {
    next(error);
  }
};

const createProduct = async (req, res, next) => {
  try {
    const { name, description, price, categoryId, imageUrl, quantity } = req.body;

    if (!name || !description || !price || !categoryId || !imageUrl) {
      return res.status(400).json({ success: false, message: 'Missing required product fields' });
    }

    const product = await Product.create({
      name,
      description,
      price,
      categoryId,
      imageUrl,
      quantity: quantity || 0,
    });

    await notifyAllUsers({
      title: 'New baking goods available',
      message: `${product.name} is now available to order.`,
      type: 'product',
      actionUrl: '/baking_goods',
    });

    res.status(201).json({ success: true, data: product });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProducts,
  getProductsByCategory,
  getProductById,
  searchProducts,
  createProduct,
};
