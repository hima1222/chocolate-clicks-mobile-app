const express = require('express');
const {
  getProducts,
  getProductsByCategory,
  getProductById,
  searchProducts,
  createProduct,
} = require('../controllers/productController');

const router = express.Router();

router.get('/search', searchProducts);
router.get('/category/:categoryId', getProductsByCategory);
router.get('/:id', getProductById);
router.get('/', getProducts);
router.post('/', createProduct);

module.exports = router;
