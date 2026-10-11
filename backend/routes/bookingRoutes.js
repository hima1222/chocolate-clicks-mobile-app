const express = require('express');
const {
  createBooking,
  cancelBooking,
  getUserBookings,
} = require('../controllers/bookingController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);
router.post('/', createBooking);
router.get('/me', getUserBookings);
router.patch('/:id/cancel', cancelBooking);

module.exports = router;
