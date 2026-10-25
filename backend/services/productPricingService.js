const mongoose = require('mongoose');
const Product = require('../models/Product');
const { createError } = require('../middleware/errorMiddleware');
function setting(name, fallback) {
  const value = Number(process.env[name] || fallback);
  if (!Number.isFinite(value) || value < 0) throw createError(`Invalid ${name} configuration`, 503);
  return value;
}
async function quoteProducts(items, city = '') {
  if (!Array.isArray(items) || items.length < 1 || items.length > 100) throw createError('Order must include 1 to 100 product lines', 400);
  const quantities = new Map();
  for (const item of items) {
    if (!item || !mongoose.isValidObjectId(item.productId) || !Number.isInteger(item.quantity) || item.quantity < 1 || item.quantity > 100) {
      throw createError('A valid productId and quantity from 1 to 100 are required', 400);
    }
    const id = item.productId.toString(), quantity = (quantities.get(id) || 0) + item.quantity;
    if (quantity > 100) throw createError('Maximum quantity per product is 100', 400);
    quantities.set(id, quantity);
  }
  const products = await Product.find({ _id: { $in: [...quantities.keys()] } });
  if (products.length !== quantities.size) throw createError('One or more products are unavailable', 409);
  let subtotalCents = 0;
  const orderItems = products.map((product) => {
    const cents = Math.round(product.price * 100), quantity = quantities.get(product.id);
    if (!Number.isSafeInteger(cents) || cents <= 0) throw createError('Invalid product price', 409);
    subtotalCents += cents * quantity;
    return { product: product._id, name: product.name, price: cents / 100, quantity };
  });
  const baseDelivery = setting('DELIVERY_FEE', 300);
  let cityFees;
  try { cityFees = JSON.parse(process.env.DELIVERY_CITY_FEES || '{}'); }
  catch (_) { throw createError('Invalid DELIVERY_CITY_FEES configuration', 503); }
  if (!cityFees || typeof cityFees !== 'object' || Array.isArray(cityFees)) throw createError('Invalid DELIVERY_CITY_FEES configuration', 503);
  const normalizeCity = (value) => String(value).trim().toLowerCase().replace(/[^a-z0-9]/g, '').replace(/^colombo0(\d)$/, 'colombo$1');
  const match = Object.entries(cityFees).find(([name]) => normalizeCity(name) === normalizeCity(city));
  const delivery = match ? Number(match[1]) : baseDelivery;
  if (!Number.isFinite(delivery) || delivery < baseDelivery) throw createError('Invalid city delivery fee configuration', 503);
  const deliveryCents = Math.round(delivery * 100);
  const serviceCents = Math.round(setting('SERVICE_CHARGE', 0) * 100);
  const taxRate = setting('ORDER_TAX_RATE', 10);
  const taxCents = Math.round(subtotalCents * taxRate / 100);
  const totalCents = subtotalCents + deliveryCents + serviceCents + taxCents;
  if (![subtotalCents, totalCents].every(Number.isSafeInteger) || subtotalCents <= 0 || totalCents <= 0) throw createError('Invalid order total', 400);
  return { items: orderItems, pricing: { subtotal: subtotalCents / 100, deliveryFee: deliveryCents / 100,
    serviceCharge: serviceCents / 100, taxAmount: taxCents / 100, taxRate, totalAmount: totalCents / 100 } };
}
module.exports = { quoteProducts };
