const { createError } = require('../middleware/errorMiddleware');
const {
  withAvailability,
  listUpcomingEvents,
  findEventById,
} = require('../services/eventService');
const Event = require('../models/Event');
const { notifyAllUsers } = require('../services/notificationService');

const getEvents = async (req, res, next) => {
  try {
    const events = await listUpcomingEvents();
    res.json({ success: true, data: events.map(withAvailability) });
  } catch (error) {
    next(error);
  }
};

const getEventById = async (req, res, next) => {
  try {
    const event = await findEventById(req.params.id);
    if (!event) {
      return next(createError('Event not found', 404));
    }
    res.json({ success: true, data: withAvailability(event) });
  } catch (error) {
    next(error);
  }
};

const createEvent = async (req, res, next) => {
  try {
    const event = await Event.create(req.body);
    await notifyAllUsers({
      title: 'New event announced',
      message: `${event.title} is now open for bookings.`,
      type: 'event',
      actionUrl: `/events/${event._id}`,
    });
    res.status(201).json({ success: true, data: withAvailability(event) });
  } catch (error) {
    next(error);
  }
};

module.exports = { getEvents, getEventById, createEvent };
