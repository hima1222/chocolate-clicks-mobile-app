jest.mock('../models/Order', () => ({ findOne: jest.fn(), create: jest.fn(), findById: jest.fn(), findOneAndUpdate: jest.fn(), updateOne: jest.fn() }));
jest.mock('../models/Product', () => ({ find: jest.fn() }));
jest.mock('../models/Booking', () => ({ create: jest.fn() }));
jest.mock('../models/PaymentReceipt', () => ({ create: jest.fn(), updateOne: jest.fn(), exists: jest.fn() }));
jest.mock('../services/payhereService', () => ({ config: jest.fn(), checkout: jest.fn(), verifyNotification: jest.fn() }));
const mongoose = require('mongoose');
const Order = require('../models/Order');
const Product = require('../models/Product');
const Booking = require('../models/Booking');
const Receipt = require('../models/PaymentReceipt');
const payhere = require('../services/payhereService');
const { createProductOrder, resumeCheckout } = require('../controllers/productCheckoutController');
const { notify } = require('../controllers/payhereController');
const productId = '507f1f77bcf86cd799439011';
const orderId = '507f1f77bcf86cd799439012';
const userId = '507f1f77bcf86cd799439013';
function response() { return { set: jest.fn(), status: jest.fn().mockReturnThis(), json: jest.fn(), send: jest.fn() }; }
function request() { return { user: { _id: userId, firstName: 'Test', lastName: 'Buyer', phone: '0771234567', email: 'buyer@example.com' },
  body: { checkoutKey: 'checkout-key-123456', items: [{ productId, quantity: 2 }],
    billing: { address: '1 Main St', city: 'Colombo', country: 'Sri Lanka' }, expectedTotal: 3050.55, platform: 'web' }, params: { id: orderId } }; }
beforeEach(() => {
  jest.resetAllMocks();
  process.env.DELIVERY_FEE = '300'; process.env.ORDER_TAX_RATE = '10'; process.env.SERVICE_CHARGE = '0'; delete process.env.DELIVERY_CITY_FEES;
  Order.findOne.mockResolvedValue(null);
  Product.find.mockResolvedValue([{ _id: productId, id: productId, name: 'Cake', price: 1250.25 }]);
  Order.create.mockImplementation(async (data) => ({ ...data, id: orderId, _id: orderId }));
  payhere.checkout.mockReturnValue({ hash: 'signed' });
});
test('uses catalog pricing, authenticated contact details and an unpaid snapshot', async () => {
  const req = request(); req.body.totalAmount = 0.01; req.body.customer = { email: 'attacker@example.com' };
  const res = response(), next = jest.fn();
  await createProductOrder(req, res, next);
  expect(next).not.toHaveBeenCalled();
  expect(Order.create).toHaveBeenCalledWith(expect.objectContaining({ user: userId, amount: '3050.55', totalAmount: 3050.55, pricing: expect.objectContaining({ subtotal: 2500.5, deliveryFee: 300, taxAmount: 250.05 }),
    payment_status: 'pending', status: 'pending', customer: expect.objectContaining({ email: 'buyer@example.com' }) }));
  expect(payhere.checkout).toHaveBeenCalledWith(expect.objectContaining({ amount: '3050.55' }), 'web');
});
test.each([0, -1, 1.5, '2', 101])('rejects invalid quantity %s', async (quantity) => {
  const req = request(); req.body.items[0].quantity = quantity;
  const next = jest.fn(); await createProductOrder(req, response(), next);
  expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
  expect(Order.create).not.toHaveBeenCalled();
});
test('rejects stale prices and missing billing before creating an order', async () => {
  const req = request(), next = jest.fn(); req.body.expectedTotal = 1;
  await createProductOrder(req, response(), next);
  expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 409 }));
  req.body.billing = {}; next.mockClear();
  await createProductOrder(req, response(), next);
  expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
  expect(Order.create).not.toHaveBeenCalled();
});
test('reuses an existing checkout without creating a duplicate', async () => {
  Order.findOne.mockResolvedValue({ id: orderId, payment_status: 'pending' });
  const res = response(); await createProductOrder(request(), res, jest.fn());
  expect(Order.create).not.toHaveBeenCalled();
  expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ reused: true }));
});
test('resumes only an owned order and never opens checkout for a paid order', async () => {
  const req = request(), next = jest.fn();
  await resumeCheckout(req, response(), next);
  expect(Order.findOne).toHaveBeenCalledWith({ _id: orderId, user: userId });
  expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
  Order.findOne.mockResolvedValue({ id: orderId, amount: '2500.50', customer: { address: '1 Main St' }, payment_status: 'paid' });
  const res = response(); await resumeCheckout(req, res, jest.fn());
  expect(payhere.checkout).not.toHaveBeenCalled();
  expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ checkout: null }));
});
test('verified product payment confirms atomically and queues a receipt without an event booking', async () => {
  const order = { _id: orderId, id: orderId, user: userId, amount: '2500.50', currency: 'LKR', payment_status: 'pending',
    items: [{ name: 'Cake', quantity: 2 }], customer: { email: 'buyer@example.com' } };
  Order.findById.mockResolvedValue(order);
  Order.findOneAndUpdate.mockImplementation(async (_, update) => Object.assign(order, update.$set));
  const req = { is: () => true, body: { order_id: orderId, payhere_amount: '2500.50', payhere_currency: 'LKR', status_code: '2', payment_id: 'payment-1' } };
  const next = jest.fn(); await notify(req, response(), next);
  expect(next).not.toHaveBeenCalled();
  expect(order.payment_status).toBe('paid'); expect(order.status).toBe('confirmed');
  expect(Booking.create).not.toHaveBeenCalled();
  expect(Receipt.updateOne).toHaveBeenCalledWith({ orderId }, expect.objectContaining({ $setOnInsert: expect.objectContaining({ to: 'buyer@example.com' }) }), { upsert: true });
  await notify(req, response(), next);
  expect(Order.findOneAndUpdate).toHaveBeenCalledTimes(1);
  req.body.payhere_amount = '0.01'; await notify(req, response(), next);
  expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
});
test('late failure cannot reverse a paid product order', async () => {
  const { confirmProductPayment } = require('../services/productPaymentService');
  const order = { _id: orderId, payment_status: 'paid', amount: '2500.50', currency: 'LKR',
    payhere_payment_id: 'payment-1', items: [], customer: { email: 'buyer@example.com' } };
  await confirmProductPayment(order, { payhere_amount: order.amount, payhere_currency: 'LKR', status_code: '-2' });
  expect(Order.findOneAndUpdate).not.toHaveBeenCalled();
  expect(Order.updateOne).toHaveBeenCalledWith({ _id: orderId, payment_status: 'paid' }, { $set: { receiptQueued: true } });
});

test('city delivery and 10 percent subtotal tax are shared by quotes and order creation', async () => {
  process.env.DELIVERY_CITY_FEES = JSON.stringify({ Colombo: 450 });
  const { quoteProductOrder } = require('../controllers/productCheckoutController');
  const req = request(); req.body.city = ' colombo ';
  const res = response(), next = jest.fn();
  await quoteProductOrder(req, res, next);
  expect(next).not.toHaveBeenCalled();
  expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ data: expect.objectContaining({ pricing: {
    subtotal: 2500.5, deliveryFee: 450, serviceCharge: 0, taxAmount: 250.05, taxRate: 10, totalAmount: 3200.55 } }) }));
  req.body.expectedTotal = 3200.55;
  await createProductOrder(req, response(), next);
  expect(Order.create).toHaveBeenCalledWith(expect.objectContaining({ amount: '3200.55' }));
});
