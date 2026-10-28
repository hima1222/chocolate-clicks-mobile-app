const express = require('express');
const {
  getConfirmation,
  resendConfirmation,
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
router.post('/', (req, res, next) => {
  if (Object.prototype.hasOwnProperty.call(req.body, 'eventId')) {
    return require('../controllers/payhereController').createEventOrder(req, res, next);
  }
  return require('../controllers/productCheckoutController').createProductOrder(req, res, next);
});
router.post('/:id/checkout', require('../controllers/productCheckoutController').resumeCheckout);
router.get('/', getUserOrders);
router.get('/:id', getOrderById);
router.get('/:id/confirmation', getConfirmation);
router.post('/:id/resend-confirmation', resendConfirmation);
router.put('/:id/cancel', cancelOrder);
router.put('/:id/status', adminOnly, updateOrderStatus);

module.exports = router;
