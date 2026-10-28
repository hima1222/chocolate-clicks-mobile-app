const mongoose = require('mongoose');
const { MongoMemoryReplSet } = require('mongodb-memory-server');
const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../app');
const User = require('../models/User');
process.env.JWT_SECRET = 'workshop-test-secret';
process.env.PAYHERE_MERCHANT_ID = '12345';
process.env.PAYHERE_MERCHANT_SECRET = 'test-secret';
process.env.PAYHERE_NOTIFY_URL = 'https://example.com/api/payments/payhere/notify';
const Event = require('../models/Event');
const { listUpcomingEvents, withAvailability } = require('../services/eventService');
let server;
jest.setTimeout(120000);
beforeAll(async () => { server = await MongoMemoryReplSet.create({ replSet: { count: 1, storageEngine: 'wiredTiger' } }); await mongoose.connect(server.getUri()); });
afterEach(async () => { await mongoose.connection.db.dropDatabase(); });
afterAll(async () => { await mongoose.disconnect(); if (server) await server.stop(); });

const workshop = (overrides = {}) => ({
  _id: new mongoose.Types.ObjectId(), title: 'Wes Mask Painting Workshop',
  category: 'Mask Painting', date: new Date(Date.now() + 86400000),
  venue: 'Art Studio', bannerUrl: 'https://example.com/mask.jpg',
  capacity: 20, availableSlots: 19, isPublished: true, ...overrides,
});
async function insert(rows) {
  await mongoose.connection.collection('workshops').insertMany(rows);
  await mongoose.connection.collection('eventcategories').insertOne({
    name: 'Sri Lankan Wes Mask Painting', priceInfo: 'LKR 5,000/- PER PERSON', description: 'Traditional mask painting',
  });
}
test('published website workshop is available with its source ID, category price and remaining slots', async () => {
  const source = workshop(); await insert([source]);
  const events = await listUpcomingEvents();
  expect(events).toHaveLength(1);
  expect(withAvailability(events[0])).toMatchObject({ id: String(source._id), slug: 'mask-painting-workshop',
    title: source.title, price: 5000, remainingSeats: 19, location: 'Art Studio', imageUrl: source.bannerUrl });
  await Event.updateOne({ _id: source._id }, { $inc: { bookedCount: 2 } });
  const refreshed = await listUpcomingEvents();
  expect(withAvailability(refreshed[0]).remainingSeats).toBe(17);
  expect(await Event.countDocuments()).toBe(1);
});
test('past, unpublished and unsupported workshops are excluded; removed workshops stop appearing', async () => {
  const live = workshop();
  await insert([live, workshop({ isPublished: false }), workshop({ date: new Date(0) }),
    workshop({ category: 'Pot Painting', title: 'Pot Painting' })]);
  expect(await listUpcomingEvents()).toHaveLength(1);
  await mongoose.connection.collection('workshops').deleteMany({});
  expect(await listUpcomingEvents()).toHaveLength(0);
  expect((await Event.findById(live._id)).sourcePublished).toBe(false);
});

test('website workshop can reserve a paid event order and refresh preserves its reserved seat', async () => {
  const source = workshop(); await insert([source]);
  const user = await User.create({ firstName: 'Workshop', lastName: 'Tester', email: 'workshop@example.com',
    phone: '0771234567', password: 'password' });
  const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET);
  const response = await request(app).post('/api/orders').set('Authorization', `Bearer ${token}`)
    .send({ eventId: String(source._id), quantity: 1, billing: { address: '1 Main Street', city: 'Colombo', country: 'Sri Lanka' } });
  expect(response.status).toBe(201);
  expect(response.body.data).toMatchObject({ eventId: String(source._id), amount: '5000.00', payment_status: 'pending' });
  const events = await listUpcomingEvents();
  expect(withAvailability(events[0]).remainingSeats).toBe(18);
  await mongoose.connection.collection('workshops').updateOne({ _id: source._id }, { $set: { isPublished: false } });
  const unavailable = await request(app).post('/api/orders').set('Authorization', `Bearer ${token}`)
    .send({ eventId: String(source._id), quantity: 2, billing: { address: '1 Main Street', city: 'Colombo', country: 'Sri Lanka' } });
  expect(unavailable.status).toBe(409);
  expect(await listUpcomingEvents()).toHaveLength(0);
});
