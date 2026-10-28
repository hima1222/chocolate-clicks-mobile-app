process.env.JWT_SECRET = 'test-secret';
process.env.PAYHERE_MERCHANT_ID = '12345';
process.env.PAYHERE_MERCHANT_SECRET = 'test-secret';
process.env.PAYHERE_NOTIFY_URL = 'https://example.com/api/payments/payhere/notify';
jest.setTimeout(120000);
const request = require('supertest');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const { MongoMemoryReplSet } = require('mongodb-memory-server');
const app = require('../app');
const User = require('../models/User');
const Event = require('../models/Event');
const Order = require('../models/Order');
const Booking = require('../models/Booking');
const Receipt = require('../models/PaymentReceipt');
const { md5 } = require('../services/payhereService');
jest.mock('../utils/sendEmail', () => jest.fn().mockResolvedValue(undefined));
const sendEmail = require('../utils/sendEmail');
const { drainReceipts } = require('../services/receiptService');
let mongo, user, event;
const billing = { address: '1 Main Street', city: 'Colombo', country: 'Sri Lanka' };
const auth = (u = user) => `Bearer ${jwt.sign({ id: u.id }, process.env.JWT_SECRET)}`;
const create = (body = {}, u = user) => request(app).post('/api/orders').set('Authorization', auth(u))
  .send({ eventId: event.id, quantity: 2, billing, ...body });
const notice = (order, overrides = {}) => {
  const b = { merchant_id: '12345', order_id: order._id, payment_id: 'payment-123',
    payhere_amount: order.amount, payhere_currency: order.currency, status_code: '2', ...overrides };
  b.md5sig = md5(b.merchant_id + b.order_id + b.payhere_amount + b.payhere_currency + b.status_code + md5('test-secret'));
  return b;
};
const notify = (b) => request(app).post('/api/payments/payhere/notify').type('form').send(b);
const otherUser = () => User.create({ firstName: 'Other', lastName: 'Person', email: 'other@example.com', phone: '0777654321', password: 'password' });
beforeAll(async () => {
  mongo = await MongoMemoryReplSet.create({ replSet: { count: 1, storageEngine: 'wiredTiger' } });
  await mongoose.connect(mongo.getUri());
  await Promise.all([Order.init(), Booking.init(), Receipt.init()]);
  // Reproduce the legacy website index reported by the running database.
  await Order.collection.createIndex({ orderNumber: 1 }, { unique: true });
});
beforeEach(async () => {
  user = await User.create({ firstName: 'Test', lastName: 'Customer', email: 'test@example.com', phone: '0771234567', password: 'password' });
  event = await Event.create({ title: 'Workshop', description: 'Test', imageUrl: 'image', location: 'Studio',
    startDate: new Date(Date.now() + 7 * 86400000), capacity: 2, price: 1250.25 });
});
afterEach(async () => {
  await Promise.all([User, Event, Order, Booking, Receipt].map((m) => m.deleteMany({})));
  jest.clearAllMocks(); delete process.env.SMTP_HOST;
});
afterAll(async () => { await mongoose.disconnect(); if (mongo) await mongo.stop(); });
test('database pricing, seat reservation and order reuse', async () => {
  const first = await create({ totalAmount: 0.01 }).expect(201);
  const second = await create().expect(201);
  expect(first.body.data.amount).toBe('2500.50');
  expect(first.body.checkout).toMatchObject({ merchant_secret: 'test-secret', amount: '2500.50', first_name: 'Test', address: billing.address });
  expect(second.body.data._id).toBe(first.body.data._id);
  expect(await Order.countDocuments()).toBe(1);
  expect((await Event.findById(event.id)).bookedCount).toBe(2);
  expect(await Booking.countDocuments()).toBe(0);
});
test('authentication, quantity and billing validation', async () => {
  await request(app).post('/api/orders').send({ eventId: event.id }).expect(401);
  for (const quantity of [0, -1, 1.5, '2', 101]) await create({ quantity }).expect(400);
  await create({ billing: {} }).expect(400);
});
test('concurrent customers cannot oversell', async () => {
  const other = await otherUser();
  const results = await Promise.all([create(), create({}, other)]);
  expect(results.map((r) => r.status).sort()).toEqual([201, 409]);
  expect((await Event.findById(event.id)).bookedCount).toBe(2);
});
test('rejects forged signature and mismatched amount, currency and merchant', async () => {
  const { body } = await create().expect(201);
  const forged = notice(body.data); forged.md5sig = '0'.repeat(32);
  await notify(forged).expect(400);
  for (const overrides of [{ payhere_amount: '1.00' }, { payhere_currency: 'USD' }, { merchant_id: '999' }]) {
    await notify(notice(body.data, overrides)).expect(400);
  }
  expect((await Order.findById(body.data._id)).payment_status).toBe('pending');
  expect(await Booking.countDocuments()).toBe(0);
});
test('concurrent duplicate success callbacks confirm once and queue/send one receipt', async () => {
  const { body } = await create().expect(201);
  const b = notice(body.data);
  await Promise.all([notify(b).expect(200), notify(b).expect(200)]);
  const order = await Order.findById(body.data._id);
  expect(order.payment_status).toBe('paid');
  expect(order.payhere_payment_id).toBe('payment-123');
  expect(await Booking.countDocuments()).toBe(1);
  expect((await Booking.findOne()).seats).toBe(2);
  expect(await Receipt.countDocuments()).toBe(1);
  expect((await Event.findById(event.id)).bookedCount).toBe(2);
  process.env.SMTP_HOST = 'test';
  await Promise.all([drainReceipts(), drainReceipts()]);
  await notify(b).expect(200); await drainReceipts();
  expect(sendEmail).toHaveBeenCalledTimes(1);
  await notify(notice(body.data, { status_code: '-2' })).expect(200);
  expect((await Order.findById(body.data._id)).payment_status).toBe('paid');
});
test('failed or cancelled payment remains unpaid; late success confirms', async () => {
  const { body } = await create().expect(201);
  await notify(notice(body.data, { status_code: '-1' })).expect(200);
  expect((await Order.findById(body.data._id)).payment_status).toBe('cancelled');
  expect(await Booking.countDocuments()).toBe(0);
  await notify(notice(body.data)).expect(200);
  expect((await Order.findById(body.data._id)).payment_status).toBe('paid');
});
test('enforces order ownership and blocks free booking bypass for paid events', async () => {
  const { body } = await create().expect(201);
  await request(app).get(`/api/orders/${body.data._id}`).set('Authorization', auth()).expect(200);
  const other = await otherUser();
  await request(app).get(`/api/orders/${body.data._id}`).set('Authorization', auth(other)).expect(404);
  await request(app).post('/api/bookings').set('Authorization', auth()).send({ eventId: event.id }).expect(402);
});
test('booking conflict rolls back payment status and receipt creation', async () => {
  const { body } = await create().expect(201);
  await Booking.create({ userId: user.id, eventId: event.id });
  await notify(notice(body.data)).expect(500);
  expect((await Order.findById(body.data._id)).payment_status).toBe('pending');
  expect(await Receipt.countDocuments()).toBe(0);
});

test('receipt status and resends enforce ownership and atomic cooldown', async () => {
  const { body } = await create().expect(201);
  const id = body.data._id;
  await notify(notice(body.data)).expect(200);
  process.env.SMTP_HOST = 'test';
  await drainReceipts();
  const status = await request(app).get(`/api/orders/${id}/confirmation`).set('Authorization', auth()).expect(200);
  expect(status.body.data).toMatchObject({ paymentStatus: 'paid', emailStatus: 'sent' });
  const other = await otherUser();
  await request(app).post(`/api/orders/${id}/resend-confirmation`).set('Authorization', auth(other)).expect(404);
  const results = await Promise.all([1, 2].map(() => request(app).post(`/api/orders/${id}/resend-confirmation`).set('Authorization', auth())));
  expect(results.map(r => r.status).sort()).toEqual([202, 429]);
  await drainReceipts();
  await request(app).post(`/api/orders/${id}/resend-confirmation`).set('Authorization', auth()).expect(429);
  expect(sendEmail).toHaveBeenCalledTimes(2);
});

test('product payments use catalog totals, reuse checkout and confirm once without event bookings', async () => {
  const Product = require('../models/Product');
  const product = await Product.create({ name: 'Chocolate cake', description: 'Cake', price: 1250.25, categoryId: 'Cakes', imageUrl: 'cake.jpg' });
  try {
    const payload = { items: [{ productId: product.id, quantity: 2 }], billing,
      expectedTotal: 3050.55, checkoutKey: 'product-checkout-123456', platform: 'web' };
    const createProduct = () => request(app).post('/api/orders').set('Authorization', auth()).send(payload);
    const first = await createProduct().expect(201);
    expect(first.body.checkout.merchant_secret).toBeUndefined();
    expect(first.body.checkout.hash).toBeDefined();
    expect(first.body.data.amount).toBe('3050.55');
    const second = await createProduct().expect(200);
    expect(second.body.data._id).toBe(first.body.data._id);
    const other = await otherUser();
    await request(app).post(`/api/orders/${first.body.data._id}/checkout`).set('Authorization', auth(other)).send({ platform: 'web' }).expect(404);
    await notify(notice(first.body.data, { payhere_amount: '0.01' })).expect(400);
    await Promise.all([notify(notice(first.body.data)).expect(200), notify(notice(first.body.data)).expect(200)]);
    expect((await Order.findById(first.body.data._id)).status).toBe('confirmed');
    expect(await Booking.countDocuments()).toBe(0);
    expect(await Receipt.countDocuments()).toBe(1);
    const paid = await request(app).post(`/api/orders/${first.body.data._id}/checkout`).set('Authorization', auth()).send({ platform: 'web' }).expect(200);
    expect(paid.body.checkout).toBeNull();
  } finally { await Product.deleteMany({}); }
});


test('multiple product orders and an event order coexist with legacy orderNumber uniqueness', async () => {
  const Product = require('../models/Product');
  const product = await Product.create({ name: 'Cake', description: 'Cake', price: 1250.25, categoryId: 'Cakes', imageUrl: 'cake.jpg' });
  try {
    await Order.collection.insertOne({ orderNumber: null });
    const payload = { items: [{ productId: product.id, quantity: 2 }], billing, expectedTotal: 3050.55, platform: 'web' };
    const first = await request(app).post('/api/orders').set('Authorization', auth()).send({ ...payload, checkoutKey: 'first-purchase-123456' }).expect(201);
    const second = await request(app).post('/api/orders').set('Authorization', auth()).send({ ...payload, checkoutKey: 'second-purchase-123456' }).expect(201);
    const booked = await create({ platform: 'web' }).expect(201);
    const numbers = [first, second, booked].map(result => result.body.data.orderNumber);
    expect(numbers.every(number => /^CC-[A-F0-9]{24}$/.test(number))).toBe(true);
    expect(new Set(numbers).size).toBe(3);
    expect(booked.body.checkout.hash).toBeDefined();
  } finally { await Product.deleteMany({}); }
});
