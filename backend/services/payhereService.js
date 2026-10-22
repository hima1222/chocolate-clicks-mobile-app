const crypto = require('crypto');
const { createError } = require('../middleware/errorMiddleware');
const md5 = (value) => crypto.createHash('md5').update(value).digest('hex').toUpperCase();

function config() {
  const merchantId = process.env.PAYHERE_MERCHANT_ID;
  const secret = process.env.PAYHERE_MERCHANT_SECRET;
  const notifyUrl = process.env.PAYHERE_NOTIFY_URL;
  let url;
  try { url = new URL(notifyUrl); } catch (_) { /* checked below */ }
  if (!merchantId || !secret || !url || url.protocol !== 'https:' ||
      ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname)) {
    throw createError('PayHere is not configured with merchant credentials and a public HTTPS notify URL', 503);
  }
  const mode = process.env.PAYHERE_SANDBOX || 'true';
  if (!['true', 'false'].includes(mode)) throw createError('Invalid PAYHERE_SANDBOX configuration', 503);
  return { merchantId, secret, notifyUrl, sandbox: mode === 'true' };
}

function verifyNotification(body) {
  const { merchantId, secret } = config();
  const required = ['merchant_id', 'order_id', 'payment_id', 'payhere_amount',
    'payhere_currency', 'status_code', 'md5sig'];
  if (!required.every((key) => typeof body[key] === 'string' && body[key].length > 0) ||
      !/^[a-fA-F0-9]{32}$/.test(body.md5sig) ||
      !/^\d+\.\d{2}$/.test(body.payhere_amount) ||
      !['2', '0', '-1', '-2', '-3'].includes(body.status_code)) {
    throw createError('Invalid PayHere notification', 400);
  }
  const expected = md5(body.merchant_id + body.order_id + body.payhere_amount +
    body.payhere_currency + body.status_code + md5(secret));
  if (body.merchant_id !== merchantId || !crypto.timingSafeEqual(
    Buffer.from(expected, 'hex'), Buffer.from(body.md5sig, 'hex'))) {
    throw createError('Invalid PayHere signature', 400);
  }
}

function checkout(order) {
  const settings = config();
  return {
    sandbox: settings.sandbox,
    merchant_id: settings.merchantId,
    // Native SDK requires the registered app secret. Never log this object.
    merchant_secret: settings.secret,
    notify_url: settings.notifyUrl,
    order_id: order.id,
    items: order.eventTitle,
    amount: order.amount,
    currency: order.currency,
    ...order.toObject().customer,
  };
}
module.exports = { config, verifyNotification, checkout, md5 };

