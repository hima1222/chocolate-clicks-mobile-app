const request = require('supertest');
const express = require('express');
jest.mock('../middleware/authMiddleware', () => ({ protect: (req, res, next) => next() }));
jest.mock('../middleware/adminMiddleware', () => ({ adminOnly: (req, res, next) => next() }));
jest.mock('../controllers/orderController', () => Object.fromEntries([
  'getConfirmation', 'resendConfirmation', 'getUserOrders', 'getOrderById',
  'cancelOrder', 'updateOrderStatus',
].map(name => [name, jest.fn()])));
jest.mock('../controllers/productCheckoutController', () => ({
  createProductOrder: jest.fn((req, res) => res.json({ flow: 'product' })),
  quoteProductOrder: jest.fn(), resumeCheckout: jest.fn(),
}));
jest.mock('../controllers/payhereController', () => ({
  createEventOrder: jest.fn((req, res) => res.json({ flow: 'event', quantity: req.body.quantity })),
}));
const app = express();
app.use(express.json());
app.use('/orders', require('../routes/orderRoutes'));
test('product payment requests reach the priced checkout handler', async () => {
  const response = await request(app).post('/orders').send({ items: [{ productId: 'p', quantity: 1 }], expectedTotal: 4150 });
  expect(response.status).toBe(200);
  expect(response.body.flow).toBe('product');
});
test('event payment requests bypass product validation and preserve participant count', async () => {
  const response = await request(app).post('/orders').send({ eventId: 'event', quantity: 3 });
  expect(response.status).toBe(200);
  expect(response.body).toEqual({ flow: 'event', quantity: 3 });
});
