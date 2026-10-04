const Event = require('../models/Event');

const withAvailability = (event) => {
  const data = event.toObject ? event.toObject() : event;
  return {
    ...data,
    id: data._id.toString(),
    remainingSeats: Math.max(data.capacity - (data.bookedCount || 0), 0),
  };
};

const listUpcomingEvents = () =>
  Event.find({ startDate: { $gt: new Date() } }).sort({ startDate: 1 });

const findEventById = (id) => Event.findById(id);

module.exports = {
  withAvailability,
  listUpcomingEvents,
  findEventById,
};
