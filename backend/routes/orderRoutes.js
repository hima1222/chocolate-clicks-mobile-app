const express = require('express');
const {
  getConfirmation,
  resendConfirmation,
  createOrder,
  getUserOrders,
  getOrderById,
  cancelOrder,
  updateOrderStatus,
} = require('../controllers/orderController');
const { protect } = require('../middleware/authMiddleware');
const { adminOnly } = require('../middleware/adminMiddleware');

const router = express.Router();

router.post('/quote', require('../controllers/productCheckoutController').quoteProductOrder);
router.use(protect);
router.post('/', createOrder);
router.post('/:id/checkout', require('../controllers/productCheckoutController').resumeCheckout);
router.get('/', getUserOrders);
router.get('/:id', getOrderById);
router.get('/:id/confirmation', getConfirmation);
router.post('/:id/resend-confirmation', resendConfirmation);
router.put('/:id/cancel', cancelOrder);
router.put('/:id/status', adminOnly, updateOrderStatus);

module.exports = router;
