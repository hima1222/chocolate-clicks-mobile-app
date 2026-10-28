const { md5, verifyNotification, config } = require('../services/payhereService');
beforeEach(() => {
  delete process.env.PAYHERE_WEB_MERCHANT_SECRET;
  delete process.env.PUBLIC_API_URL;
  process.env.PAYHERE_MERCHANT_ID = '12345';
  process.env.PAYHERE_MERCHANT_SECRET = 'registered-app-secret';
  process.env.PAYHERE_NOTIFY_URL = 'https://example.com/api/payments/payhere/notify';
  process.env.PAYHERE_SANDBOX = 'true';
});
const valid = (extra = {}) => {
  const b = { merchant_id: '12345', order_id: 'order', payment_id: 'payment',
    payhere_amount: '2500.50', payhere_currency: 'LKR', status_code: '2', ...extra };
  b.md5sig = md5(b.merchant_id + b.order_id + b.payhere_amount + b.payhere_currency +
    b.status_code + md5('registered-app-secret'));
  return b;
};
test('accepts valid signatures including lowercase hexadecimal', () => {
  const b = valid(); expect(() => verifyNotification(b)).not.toThrow();
  b.md5sig = b.md5sig.toLowerCase(); expect(() => verifyNotification(b)).not.toThrow();
});
test('rejects tampering, wrong merchant, malformed and repeated parameters', () => {
  const b = valid(); b.payhere_amount = '0.01';
  expect(() => verifyNotification(b)).toThrow('signature');
  expect(() => verifyNotification(valid({ merchant_id: 'other' }))).toThrow('signature');
  for (const extra of [{ md5sig: 'invalid' }, { status_code: ['2', '0'] },
    { payhere_amount: 'NaN' }, { status_code: '3' }]) {
    const body = { ...valid(), ...extra };
    expect(() => verifyNotification(body)).toThrow('notification');
  }
});
test('requires sandbox or live mode, credentials and a public HTTPS callback', () => {
  expect(config().sandbox).toBe(true);
  process.env.PAYHERE_SANDBOX = 'false'; expect(config().sandbox).toBe(false);
  process.env.PAYHERE_SANDBOX = 'yes'; expect(() => config()).toThrow('configuration');
  process.env.PAYHERE_SANDBOX = 'true';
  for (const url of ['http://example.com/notify', 'https://localhost/notify', 'invalid']) {
    process.env.PAYHERE_NOTIFY_URL = url; expect(() => config()).toThrow('configured');
  }
});

test('web checkout signs the exact payment amount without disclosing the merchant secret', () => {
  const { checkout } = require('../services/payhereService');
  const order = { id: 'order-123', amount: '2500.50', currency: 'LKR', eventTitle: 'Workshop',
    toObject: () => ({ customer: { first_name: 'Test' } }) };
  const web = checkout(order, 'web');
  expect(web.merchant_secret).toBeUndefined();
  expect(web.hash).toBe(md5('12345order-1232500.50LKR' + md5('registered-app-secret')));
  expect(web.first_name).toBe('Test');
  expect(checkout(order).merchant_secret).toBe('registered-app-secret');
});

test('accepts web notifications signed with the registered domain secret', () => {
  process.env.PAYHERE_WEB_MERCHANT_SECRET = 'registered-domain-secret';
  const body = valid();
  body.md5sig = md5(body.merchant_id + body.order_id + body.payhere_amount +
    body.payhere_currency + body.status_code + md5('registered-domain-secret'));
  expect(() => verifyNotification(body)).not.toThrow();
});

test('derives the callback from a public API base and reports a missing callback clearly', () => {
  delete process.env.PAYHERE_NOTIFY_URL;
  expect(() => config()).toThrow('PAYHERE_NOTIFY_URL');
  process.env.PUBLIC_API_URL = 'https://api.example.com/api/';
  expect(config().notifyUrl).toBe('https://api.example.com/api/payments/payhere/notify');
});

test('reports missing merchant credentials separately from a missing callback', () => {
  delete process.env.PAYHERE_NOTIFY_URL;
  expect(() => config()).toThrow('merchant credentials are configured');
  delete process.env.PAYHERE_MERCHANT_SECRET;
  expect(() => config()).toThrow('missing PAYHERE_MERCHANT_SECRET');
});

test('trims settings copied into environment configuration', () => {
  process.env.PAYHERE_MERCHANT_ID = ' 12345 ';
  process.env.PAYHERE_MERCHANT_SECRET = ' registered-app-secret ';
  process.env.PAYHERE_NOTIFY_URL = ' https://chocolate-clicks-backend.hostless.app/api/payments/payhere/notify ';
  expect(config()).toMatchObject({ merchantId: '12345', secret: 'registered-app-secret',
    notifyUrl: 'https://chocolate-clicks-backend.hostless.app/api/payments/payhere/notify' });
});
