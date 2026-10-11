const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    eventId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Event',
      required: true,
    },
    status: {
      type: String,
      enum: ['CONFIRMED', 'CANCELLED'],
      default: 'CONFIRMED',
    },
    cancelledAt: { type: Date, default: null },
    createdAt: { type: Date, default: Date.now },
  }
);

bookingSchema.index(
  { userId: 1, eventId: 1 },
  { unique: true, partialFilterExpression: { status: 'CONFIRMED' } }
);

const Booking = mongoose.model('Booking', bookingSchema);
module.exports = Booking;
