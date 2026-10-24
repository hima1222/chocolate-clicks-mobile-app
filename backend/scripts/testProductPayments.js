// Uses a new temporary database on the configured MongoDB server, never the app database.
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const crypto = require('crypto');
const assert = require('node:assert/strict');
const request = require('supertest');
const jwt = require('jsonwebtoken');
const database = 'chocolate_clicks_product_test_' + crypto.randomUUID().replaceAll('-', '');
const mongoUri = process.env.MONGO_URI;
process.env.JWT_SECRET = 'isolated-product-test';
process.env.PAYHERE_MERCHANT_ID = '12345';
process.env.PAYHERE_MERCHANT_SECRET = 'isolated-product-test';
process.env.PAYHERE_NOTIFY_URL = 'https://example.com/api/payments/payhere/notify';
process.env.PAYHERE_SANDBOX = 'true';
process.env.DELIVERY_FEE = '300'; process.env.ORDER_TAX_RATE = '10'; process.env.SERVICE_CHARGE = '0'; process.env.DELIVERY_CITY_FEES = '{}';
delete process.env.PAYHERE_WEB_MERCHANT_SECRET;
const app = require('../app');
const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Receipt = require('../models/PaymentReceipt');
const Booking = require('../models/Booking');
const { md5 } = require('../services/payhereService');
const { repairProductReceipts } = require('../services/productPaymentService');
async function main() {
  assert(mongoUri, 'MONGO_URI is required');
  await mongoose.connect(mongoUri, { dbName: database, serverSelectionTimeoutMS: 10000 });
  await Promise.all([Order.init(), Receipt.init(), Booking.init(), User.init()]);
  const user = await User.create({ firstName: 'Test', lastName: 'Buyer', email: 'buyer@example.com', phone: '0771234567', password: 'test-password' });
  const other = await User.create({ firstName: 'Other', lastName: 'Buyer', email: 'other@example.com', phone: '0771234568', password: 'test-password' });
  const token = (u) => `Bearer ${jwt.sign({ id: u.id }, process.env.JWT_SECRET)}`;
  const product = await Product.create({ name: 'Test cake', price: 1250.25, description: 'Test', imageUrl: 'cake.jpg', categoryId: 'Cakes' });
  const payload = { checkoutKey: 'isolated-checkout-123456', expectedTotal: 3050.55, items: [{ productId: product.id, quantity: 2 }],
    billing: { address: '1 Main St', city: 'Colombo', country: 'Sri Lanka' }, platform: 'web' };
  const create = (body = payload) => request(app).post('/api/orders').set('Authorization', token(user)).send(body);
  await create({ ...payload, expectedTotal: 1 }).expect(409);
  const quote = await request(app).post('/api/orders/quote').send({ items: payload.items, city: 'Colombo' }).expect(200);
  assert.equal(quote.body.data.pricing.totalAmount, 3050.55);
  assert.equal(quote.body.data.pricing.taxAmount, 250.05);
  const results = await Promise.all([create(), create()]);
  assert.deepEqual(results.map((r) => r.status).sort(), [200, 201]);
  assert.equal(await Order.countDocuments(), 1);
  const order = results[0].body.data;
  assert.equal(order.amount, '3050.55');
  assert.equal(results[0].body.checkout.merchant_secret, undefined);
  assert(results[0].body.checkout.hash);
  await request(app).post(`/api/orders/${order._id}/checkout`).set('Authorization', token(other)).send({ platform: 'web' }).expect(404);
  const notice = (extra = {}) => {
    const b = { merchant_id: '12345', order_id: order._id, payment_id: 'isolated-payment', payhere_amount: '3050.55', payhere_currency: 'LKR', status_code: '2', ...extra };
    b.md5sig = md5(b.merchant_id + b.order_id + b.payhere_amount + b.payhere_currency + b.status_code + md5('isolated-product-test'));
    return b;
  };
  const notify = (body) => request(app).post('/api/payments/payhere/notify').type('form').send(body);
  await notify({ ...notice(), md5sig: '0'.repeat(32) }).expect(400);
  await notify(notice({ payhere_amount: '0.01' })).expect(400);
  await notify(notice({ status_code: '-1' })).expect(200);
  assert.equal((await Order.findById(order._id)).payment_status, 'cancelled');
  const resumed = await request(app).post(`/api/orders/${order._id}/checkout`).set('Authorization', token(user)).send({ platform: 'web' }).expect(200);
  assert(resumed.body.checkout.hash);
  await Promise.all([notify(notice()).expect(200), notify(notice()).expect(200)]);
  assert.equal((await Order.findById(order._id)).payment_status, 'paid');
  assert.equal((await Order.findById(order._id)).status, 'confirmed');
  assert.equal(await Receipt.countDocuments(), 1);
  assert.equal(await Booking.countDocuments(), 0);
  await notify(notice({ status_code: '-2' })).expect(200);
  assert.equal((await Order.findById(order._id)).payment_status, 'paid');
  await notify(notice({ payment_id: 'different-payment' })).expect(409);
  const paid = await request(app).post(`/api/orders/${order._id}/checkout`).set('Authorization', token(user)).send({ platform: 'web' }).expect(200);
  assert.equal(paid.body.checkout, null);
  // Simulate a crash after payment confirmation but before receipt enqueueing.
  await Receipt.deleteOne({ orderId: order._id });
  await Order.updateOne({ _id: order._id }, { $set: { receiptQueued: false } });
  await repairProductReceipts();
  assert.equal(await Receipt.countDocuments(), 1);
  assert.equal((await Order.findById(order._id)).receiptQueued, true);
  console.log('PASS: real MongoDB product pricing, concurrent order reuse, ownership, retry, signatures, duplicate callbacks, monotonic payment and receipt recovery.');
  console.log('PayHere and SMTP were not contacted. The temporary test database is removed.');
}
main().catch(() => { console.error('Product database regression failed. Application data was not used.'); process.exitCode = 1; })
  .finally(async () => {
    if (mongoose.connection.readyState === 1 && mongoose.connection.name === database) await mongoose.connection.dropDatabase();
    await mongoose.disconnect();
  });
