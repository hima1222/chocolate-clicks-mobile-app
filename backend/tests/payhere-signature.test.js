const { md5, verifyNotification, config } = require('../services/payhereService');
beforeEach(() => {
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
