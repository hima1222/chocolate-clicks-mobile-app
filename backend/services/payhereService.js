const crypto = require('crypto');
const { createError } = require('../middleware/errorMiddleware');
const md5 = (value) => crypto.createHash('md5').update(value).digest('hex').toUpperCase();

function config() {
  const merchantId = process.env.PAYHERE_MERCHANT_ID?.trim();
  const secret = process.env.PAYHERE_MERCHANT_SECRET?.trim();
  const missing = [!merchantId && 'PAYHERE_MERCHANT_ID', !secret && 'PAYHERE_MERCHANT_SECRET'].filter(Boolean);
  if (missing.length) throw createError(`PayHere is not configured: missing ${missing.join(', ')} on the backend.`, 503);
  const publicApiUrl = process.env.PUBLIC_API_URL?.trim();
  const notifyUrl = process.env.PAYHERE_NOTIFY_URL?.trim() || (publicApiUrl
    ? publicApiUrl.replace(/\/$/, '').replace(/\/api$/, '') + '/api/payments/payhere/notify' : '');
  if (!notifyUrl) throw createError('PayHere merchant credentials are configured, but PAYHERE_NOTIFY_URL is missing. Set it to your public HTTPS backend URL followed by /api/payments/payhere/notify, or set PUBLIC_API_URL.', 503);
  let url;
  try { url = new URL(notifyUrl); } catch (_) { /* checked below */ }
  if (!url || url.protocol !== 'https:' || ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname)) {
    throw createError('PayHere callback is not configured correctly: PAYHERE_NOTIFY_URL must be a public HTTPS backend URL. Localhost cannot receive payment confirmations.', 503);
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
  const secrets = [secret, process.env.PAYHERE_WEB_MERCHANT_SECRET, process.env.PAYHERE_APP_MERCHANT_SECRET].map(value => value?.trim()).filter(Boolean);
  const valid = secrets.some((candidate) => {
    const expected = md5(body.merchant_id + body.order_id + body.payhere_amount +
      body.payhere_currency + body.status_code + md5(candidate));
    return crypto.timingSafeEqual(Buffer.from(expected, 'hex'), Buffer.from(body.md5sig, 'hex'));
  });
  if (body.merchant_id !== merchantId || !valid) {
    throw createError('Invalid PayHere signature', 400);
  }
}

function checkout(order, platform = 'native') {
  const settings = config();
  return {
    sandbox: settings.sandbox,
    merchant_id: settings.merchantId,
    // Native SDK requires the registered app secret. Never log this object.
    ...(platform === 'web' ? { hash: md5(settings.merchantId + order.id + order.amount + order.currency + md5(process.env.PAYHERE_WEB_MERCHANT_SECRET || settings.secret)) } : { merchant_secret: process.env.PAYHERE_APP_MERCHANT_SECRET?.trim() || settings.secret }),
    notify_url: settings.notifyUrl,
    order_id: order.id,
    items: order.eventTitle || order.items.map((item) => `${item.name} x ${item.quantity}`).join(', ').slice(0, 250),
    amount: order.amount,
    currency: order.currency,
    ...order.toObject().customer,
  };
}
module.exports = { config, verifyNotification, checkout, md5 };

