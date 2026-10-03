const nodemailer = require('nodemailer');

const sendEmail = async ({ to, subject, text }) => {
  // Dev fallback: no SMTP configured, so print to the terminal
  if (!process.env.SMTP_HOST) {
    console.log(`[DEV EMAIL] To: ${to}\nSubject: ${subject}\n${text}`);
    return;
  }

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT) || 587,
    secure: Number(process.env.SMTP_PORT) === 465,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });

  await transporter.sendMail({
    from: process.env.MAIL_FROM || process.env.SMTP_USER,
    to,
    subject,
    text,
  });
};

module.exports = sendEmail;