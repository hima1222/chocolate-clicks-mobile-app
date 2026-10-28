require('dotenv').config();
const mongoose = require('mongoose');
const { listUpcomingEvents, withAvailability } = require('../services/eventService');
(async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, { serverSelectionTimeoutMS:15000, family:4 });
    const events = await listUpcomingEvents();
    console.log(JSON.stringify(events.map(event => {
      const row = withAvailability(event);
      return { id: row.id, title: row.title, slug: row.slug, startDate: row.startDate,
        location: row.location, price: row.price, remainingSeats: row.remainingSeats };
    }), null, 2));
  } catch (error) {
    console.error('Workshop sync failed:', error.name);
    process.exitCode = 1;
  } finally { await mongoose.disconnect(); }
})();
