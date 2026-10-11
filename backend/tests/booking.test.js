process.env.JWT_SECRET = 'test-secret';
jest.setTimeout(120000);

const request = require('supertest');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../app');
const User = require('../models/User');
const Event = require('../models/Event');
const Booking = require('../models/Booking');

let mongoServer;
let userCounter = 0;

const tokenFor = (user) => jwt.sign({ id: user._id }, process.env.JWT_SECRET);

const createUser = (suffix) =>
  User.create({
    firstName: 'Test',
    lastName: suffix,
    email: `${suffix}@example.com`,
    phone: `555${String(++userCounter).padStart(7, '0')}`,
    password: 'password',
  });

const createEvent = (overrides = {}) =>
  Event.create({
    title: 'Chocolate Workshop',
    description: 'A workshop',
    imageUrl: 'https://example.com/event.jpg',
    location: 'Studio',
    startDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    capacity: 2,
    ...overrides,
  });

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());
  await Booking.init();
});

afterEach(async () => {
  if (mongoose.connection.readyState !== 1) {
    return;
  }
  await Promise.all([
    User.deleteMany({}),
    Event.deleteMany({}),
    Booking.deleteMany({}),
  ]);
});

afterAll(async () => {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
  }
  if (mongoServer) {
    await mongoServer.stop();
  }
});

describe('booking lifecycle', () => {
  test('rejects a duplicate confirmed booking', async () => {
    const user = await createUser('duplicate');
    const event = await createEvent();
    const authHeader = `Bearer ${tokenFor(user)}`;

    await request(app).post('/api/bookings').set('Authorization', authHeader).send({ eventId: event._id }).expect(201);
    const response = await request(app)
      .post('/api/bookings')
      .set('Authorization', authHeader)
      .send({ eventId: event._id })
      .expect(409);

    expect(response.body.message).toBe('You already booked this event');
    expect((await Event.findById(event._id)).bookedCount).toBe(1);
  });

  test('rejects a booking when the event is full', async () => {
    const event = await createEvent({ capacity: 1 });
    const firstUser = await createUser('full-one');
    const secondUser = await createUser('full-two');

    await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${tokenFor(firstUser)}`)
      .send({ eventId: event._id })
      .expect(201);
    const response = await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${tokenFor(secondUser)}`)
      .send({ eventId: event._id })
      .expect(409);

    expect(response.body.message).toBe('Event is full');
  });

  test('allows exactly one of ten concurrent requests for the last seat', async () => {
    const event = await createEvent({ capacity: 1 });
    const users = await Promise.all(
      Array.from({ length: 10 }, (_, index) => createUser(`concurrent-${index}`))
    );

    const responses = await Promise.all(
      users.map((user) =>
        request(app)
          .post('/api/bookings')
          .set('Authorization', `Bearer ${tokenFor(user)}`)
          .send({ eventId: event._id })
      )
    );

    expect(responses.filter((response) => response.status === 201)).toHaveLength(1);
    expect(responses.filter((response) => response.status === 409)).toHaveLength(9);
    expect((await Event.findById(event._id)).bookedCount).toBe(1);
  });

  test('allows the owner to cancel more than 24 hours before the event', async () => {
    const user = await createUser('cancel');
    const event = await createEvent();
    const bookingResponse = await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${tokenFor(user)}`)
      .send({ eventId: event._id })
      .expect(201);

    const response = await request(app)
      .patch(`/api/bookings/${bookingResponse.body.data._id}/cancel`)
      .set('Authorization', `Bearer ${tokenFor(user)}`)
      .expect(200);

    expect(response.body.data.status).toBe('CANCELLED');
    expect(response.body.data.cancelledAt).toBeTruthy();
    expect((await Event.findById(event._id)).bookedCount).toBe(0);
  });

  test('rejects cancellation within 24 hours of the event', async () => {
    const user = await createUser('late');
    const event = await createEvent({ startDate: new Date(Date.now() + 12 * 60 * 60 * 1000) });
    const booking = await Booking.create({ userId: user._id, eventId: event._id });
    await Event.updateOne({ _id: event._id }, { $set: { bookedCount: 1 } });

    const response = await request(app)
      .patch(`/api/bookings/${booking._id}/cancel`)
      .set('Authorization', `Bearer ${tokenFor(user)}`)
      .expect(400);

    expect(response.body.message).toMatch(/24 hours/i);
    expect((await Booking.findById(booking._id)).status).toBe('CONFIRMED');
    expect((await Event.findById(event._id)).bookedCount).toBe(1);
  });

  test('rejects cancellation by another user', async () => {
    const owner = await createUser('owner');
    const otherUser = await createUser('other');
    const event = await createEvent();
    const booking = await Booking.create({ userId: owner._id, eventId: event._id });
    await Event.updateOne({ _id: event._id }, { $set: { bookedCount: 1 } });

    const response = await request(app)
      .patch(`/api/bookings/${booking._id}/cancel`)
      .set('Authorization', `Bearer ${tokenFor(otherUser)}`)
      .expect(403);

    expect(response.body.message).toMatch(/own/i);
    expect((await Booking.findById(booking._id)).status).toBe('CONFIRMED');
  });
});
