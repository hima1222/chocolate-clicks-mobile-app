const nodemailer = require('nodemailer');
let transporter;
function getTransporter() {
  if (transporter) return transporter;
  const port = Number(process.env.SMTP_PORT || 587);
  const password = process.env.SMTP_PASSWORD || process.env.SMTP_PASS;
  if (!process.env.SMTP_HOST || !process.env.SMTP_USER || !password ||
      !Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('Configure SMTP_HOST, SMTP_PORT, SMTP_USER and SMTP_PASSWORD in backend/.env');
  }
  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST, port, secure: port === 465, requireTLS: port !== 465,
    auth: { user: process.env.SMTP_USER, pass: password },
    connectionTimeout: 15000, greetingTimeout: 15000, socketTimeout: 30000,
  });
  return transporter;
}
async function sendEmail({ to, subject, text }) {
  return getTransporter().sendMail({
    from: process.env.MAIL_FROM || process.env.SMTP_USER, to, subject, text,
  });
}
sendEmail.verify = () => getTransporter().verify();
module.exports = sendEmail;
