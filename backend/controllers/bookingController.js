const { createError } = require('../middleware/errorMiddleware');
const {
  createBooking: reserveBooking,
  cancelBooking: cancelReservedBooking,
  listUserBookings,
} = require('../services/bookingService');

const mapBookingError = (error) => {
  if (error?.code === 11000) {
    error.statusCode = 409;
    error.message = 'You already booked this event';
  }
  return error;
};

const createBooking = async (req, res, next) => {
  try {
    if (!req.body.eventId) {
      return next(createError('eventId is required', 400));
    }

    const booking = await reserveBooking(req.user._id, req.body.eventId);
    await booking.populate('eventId', 'title startDate imageUrl');
    res.status(201).json({ success: true, data: booking });
  } catch (error) {
    next(mapBookingError(error));
  }
};

const cancelBooking = async (req, res, next) => {
  try {
    const booking = await cancelReservedBooking(req.params.id, req.user._id);
    res.json({ success: true, data: booking });
  } catch (error) {
    next(mapBookingError(error));
  }
};

const getUserBookings = async (req, res, next) => {
  try {
    const bookings = await listUserBookings(req.user._id);
    res.json({ success: true, data: bookings });
  } catch (error) {
    next(error);
  }
};

module.exports = { createBooking, cancelBooking, getUserBookings };
