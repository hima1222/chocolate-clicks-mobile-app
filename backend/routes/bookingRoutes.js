const express = require('express');
const { createBooking, getUserBookings, getBookingById } = require('../controllers/bookingController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);
router.post('/', createBooking);
router.get('/', getUserBookings);
router.get('/:id', getBookingById);

module.exports = router;
