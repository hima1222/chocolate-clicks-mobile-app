jest.mock('nodemailer', () => ({ createTransport: jest.fn() }));

const originalEnv = { ...process.env };
afterEach(() => { process.env = { ...originalEnv }; jest.resetModules(); jest.clearAllMocks(); });
test.each([587, 465])('SMTP port %s uses encryption and canonical credentials', async (port) => {
  process.env.SMTP_HOST = 'smtp.gmail.com'; process.env.SMTP_PORT = String(port);
  process.env.SMTP_USER = 'sender@example.com'; process.env.SMTP_PASSWORD = 'app-password';
  const transport = { sendMail: jest.fn().mockResolvedValue({}), verify: jest.fn().mockResolvedValue(true) };
  const nodemailer = require('nodemailer');
  nodemailer.createTransport.mockReturnValue(transport);
  const send = require('../utils/sendEmail');
  await send({ to: 'customer@example.com', subject: 'Booking', text: 'Confirmed' });
  await send.verify();
  expect(nodemailer.createTransport).toHaveBeenCalledWith(expect.objectContaining({
    port, secure: port === 465, requireTLS: port !== 465,
    auth: { user: 'sender@example.com', pass: 'app-password' },
  }));
  expect(transport.verify).toHaveBeenCalledTimes(1);
});
test('missing SMTP rejects instead of logging reset codes or reporting success', async () => {
  delete process.env.SMTP_HOST;
  await expect(require('../utils/sendEmail')({ to: 'a@example.com', text: 'secret' })).rejects.toThrow('Configure SMTP');
});
