const { createError } = require('../middleware/errorMiddleware');
const {
  withAvailability,
  listUpcomingEvents,
  findEventById,
} = require('../services/eventService');

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

module.exports = { getEvents, getEventById };
