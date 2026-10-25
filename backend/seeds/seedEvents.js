const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const mongoose = require('mongoose');
const Event = require('../models/Event');
const events = require('./events.json');

// Calculate the next advertised session in Asia/Colombo (UTC+05:30).
function nextSession(weekday, hour, now = new Date()) {
  const local = new Date(now.getTime() + 330 * 60000);
  const next = new Date(Date.UTC(local.getUTCFullYear(), local.getUTCMonth(), local.getUTCDate(), hour) - 330 * 60000);
  next.setUTCDate(next.getUTCDate() + (weekday - local.getUTCDay() + 7) % 7);
  if (next <= now) next.setUTCDate(next.getUTCDate() + 7);
  return next;
}

async function seedEvents() {
  const capacity = Number(process.env.EVENT_DEFAULT_CAPACITY || 20);
  if (!Number.isInteger(capacity) || capacity < 1) throw new Error('EVENT_DEFAULT_CAPACITY must be a positive integer');
  for (const { weekday, hour, ...data } of events) {
    // Insert only: reruns preserve dates, edits, bookings and seat counts.
    await Event.updateOne({ title: data.title }, { $setOnInsert: {
      ...require('../utils/resolveImages')(data), startDate: nextSession(weekday, hour), capacity, bookedCount: 0,
    } }, { upsert: true, runValidators: true });
  }
  return Event.find({ title: { $in: events.map(e => e.title) } }).sort({ startDate: 1 });
}

if (require.main === module) {
  (async () => {
    try {
      if (!process.env.MONGO_URI) throw new Error('MONGO_URI is required');
      await mongoose.connect(process.env.MONGO_URI, { serverSelectionTimeoutMS: 15000 });
      const saved = await seedEvents();
      console.log(JSON.stringify(saved.map(e => ({ id: e.id, title: e.title, startDate: e.startDate, capacity: e.capacity, price: e.price })), null, 2));
    } catch (error) {
      console.error('Event seed failed:', error.message);
      process.exitCode = 1;
    } finally {
      await mongoose.disconnect();
    }
  })();
}
module.exports = { seedEvents, nextSession };

