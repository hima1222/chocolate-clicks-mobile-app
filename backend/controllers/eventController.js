const Event = require('../models/Event');

const getEvents = async (req, res, next) => {
  try {
    const events = await Event.find().sort({ date: 1 });
    res.json({ success: true, data: events });
  } catch (error) {
    next(error);
  }
};

const getEventById = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }
    res.json({ success: true, data: event });
  } catch (error) {
    next(error);
  }
};

const createEvent = async (req, res, next) => {
  try {
    const { title, description, date, location, price, imageUrl } = req.body;
    if (!title || !description || !date || !location || !imageUrl) {
      return res.status(400).json({ success: false, message: 'Missing event fields' });
    }

    const event = await Event.create({
      title,
      description,
      date,
      location,
      price: price || 0,
      imageUrl,
    });

    res.status(201).json({ success: true, data: event });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getEvents,
  getEventById,
  createEvent,
};
