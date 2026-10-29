const mongoose = require('mongoose');
const Event = require('../models/Event');

const workshopSlug = (workshop) => {
  const category = String(workshop.category || '').toLowerCase();
  const title = String(workshop.title || '').toLowerCase();
  if (category.includes('mask') || title.includes('mask')) return 'mask-painting-workshop';
  if (category.includes('bake') || title.includes('baking')) return 'bake-it-happen';
  return null;
};

// Keep website workshops compatible with Event references used by orders/bookings.
// Source availability is a ceiling; mobile reservations remain in bookedCount.
const syncWorkshops = async () => {
  const workshops = await mongoose.connection.collection('workshops').find({}).toArray();

  const categories = await mongoose.connection.collection('eventcategories').find({}).toArray();
  const operations = [];
  for (const workshop of workshops) {
    const slug = workshopSlug(workshop);
    if (!slug) continue;
    const startDate = new Date(workshop.date);
    if (Number.isNaN(startDate.getTime())) continue;
    const category = categories.find((item) => item.name === workshop.category)
      || categories.find((item) => workshopSlug({ category: item.name }) === slug);
    const priceText = String(category?.priceInfo || '').replace(/,/g, '');
    const categoryPrice = Number(priceText.match(/\d+(?:\.\d+)?/)?.[0]);
    const price = typeof workshop.price === 'number' ? workshop.price : categoryPrice;
    // Never accidentally expose a paid workshop as a free event.
    if (!Number.isFinite(price) || price < 0 || (!price && !category && workshop.price !== 0)) continue;
    const capacity = Math.max(0, Number(workshop.availableSlots ?? workshop.capacity) || 0);
    operations.push({ updateOne: {
      filter: { _id: workshop._id },
      update: {
        $set: {
          source: 'workshop', sourcePublished: workshop.isPublished === true,
          slug, title: workshop.title, description: workshop.description || category?.description || '',
          imageUrl: workshop.bannerUrl || '', cardImage: workshop.bannerUrl || '',
          location: workshop.venue || workshop.location || '', startDate, capacity, price,
        },
        $setOnInsert: { bookedCount: 0, createdAt: workshop.createdAt || new Date() },
      }, upsert: true,
    }});
  }
  if (operations.length) await Event.bulkWrite(operations);
  // Remove deleted/unpublished workshops from discovery and checkout, retaining booking history.
  await Event.updateMany(
    { source: 'workshop', _id: { $nin: workshops.filter(w => w.isPublished === true).map(w => w._id) } },
    { $set: { sourcePublished: false } }
  );
};

module.exports = { syncWorkshops, workshopSlug };
