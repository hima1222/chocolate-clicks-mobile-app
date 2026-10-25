const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema(
  {
    slug: { type: String, index: true },
    subtitle: { type: String, default: '' },
    cardImage: { type: String, default: '' },
    gallery: { type: [String], default: [] },
    included: { type: [String], default: [] },
    schedule: { type: String, default: '' },
    duration: { type: String, default: '' },
    title: { type: String, required: true },
    description: { type: String, required: true },
    imageUrl: { type: String, required: true },
    location: { type: String, required: true },
    startDate: { type: Date, required: true },
    capacity: { type: Number, required: true, min: 1 },
    bookedCount: { type: Number, default: 0, min: 0 },
    price: { type: Number, required: true, default: 0 },
    createdAt: { type: Date, default: Date.now },
  }
);

const Event = mongoose.model('Event', eventSchema);
module.exports = Event;
