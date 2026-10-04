const Booking = require('../models/Booking');
const Event = require('../models/Event');

const serviceError = (message, statusCode) => {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
};

const reserveEventSeat = (eventId) =>
  Event.findOneAndUpdate(
    {
      _id: eventId,
      startDate: { $gt: new Date() },
      $expr: { $lt: ['$bookedCount', '$capacity'] },
    },
    { $inc: { bookedCount: 1 } },
    { new: true }
  );

const createBooking = async (userId, eventId) => {
  const event = await reserveEventSeat(eventId);
  if (!event) {
    const existingEvent = await Event.findById(eventId).select('_id startDate bookedCount capacity');
    if (!existingEvent) {
      throw serviceError('Event not found', 404);
    }
    throw serviceError(
      existingEvent.startDate <= new Date()
        ? 'Event is no longer available'
        : 'Event is full',
      409
    );
  }

  try {
    return await Booking.create({ userId, eventId });
  } catch (error) {
    await Event.updateOne({ _id: event._id }, { $inc: { bookedCount: -1 } });
    throw error;
  }
};

const cancelBooking = async (bookingId, userId) => {
  const booking = await Booking.findById(bookingId).select('userId eventId status');
  if (!booking) {
    throw serviceError('Booking not found', 404);
  }
  if (booking.userId.toString() !== userId.toString()) {
    throw serviceError('You do not own this booking', 403);
  }
  if (booking.status !== 'CONFIRMED') {
    throw serviceError('Booking is already cancelled', 400);
  }

  const event = await Event.findById(booking.eventId).select('startDate');
  if (!event) {
    throw serviceError('Event not found', 404);
  }
  const cancellationDeadline = new Date(event.startDate.getTime() - 24 * 60 * 60 * 1000);
  if (new Date() > cancellationDeadline) {
    throw serviceError('Bookings can only be cancelled at least 24 hours before the event', 400);
  }

  const cancelledAt = new Date();
  const updatedBooking = await Booking.findOneAndUpdate(
    { _id: bookingId, userId, status: 'CONFIRMED' },
    { $set: { status: 'CANCELLED', cancelledAt } },
    { new: true }
  );
  if (!updatedBooking) {
    throw serviceError('Booking is already cancelled', 400);
  }

  try {
    const updatedEvent = await Event.findOneAndUpdate(
      { _id: booking.eventId, bookedCount: { $gt: 0 } },
      { $inc: { bookedCount: -1 } },
      { new: true }
    );
    if (!updatedEvent) {
      throw serviceError('Event not found', 404);
    }
  } catch (error) {
    await Booking.updateOne(
      { _id: bookingId, status: 'CANCELLED' },
      { $set: { status: 'CONFIRMED' }, $unset: { cancelledAt: 1 } }
    );
    throw error;
  }

  await updatedBooking.populate('eventId', 'title startDate imageUrl');
  return updatedBooking;
};

const listUserBookings = (userId) =>
  Booking.find({ userId })
    .populate('eventId', 'title startDate imageUrl')
    .sort({ createdAt: -1 });

module.exports = {
  createBooking,
  cancelBooking,
  listUserBookings,
};
