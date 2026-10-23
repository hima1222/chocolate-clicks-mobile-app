require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const sendEmail = require('../utils/sendEmail');
(async () => {
  await sendEmail.verify();
  console.log('SMTP connection and authentication verified.');
  if (process.argv.includes('--send')) {
    await sendEmail({ to: process.env.SMTP_USER, subject: 'Chocolate Clicks SMTP test',
      text: 'Your Chocolate Clicks backend can send email through SMTP.' });
    console.log('Test email accepted by SMTP for the configured SMTP_USER. Check the inbox and spam folder.');
  }
})().catch((error) => {
  // Do not print raw server responses, credentials, or message contents.
  const knownCodes = ['EAUTH', 'ETIMEDOUT', 'ECONNECTION', 'ESOCKET', 'EDNS', 'ENOTFOUND', 'ECONNREFUSED', 'ECONNRESET', 'ETLS'];
  const code = knownCodes.includes(error.code) ? error.code : 'CONFIG_OR_SMTP_ERROR';
  console.error(`SMTP check failed [${code}]${Number.isInteger(error.responseCode) ? ` (server ${error.responseCode})` : ''}.`);
  if (code === 'EAUTH') {
    console.error('Authentication rejected. Check SMTP_USER and use a Google App Password for that same account in SMTP_PASSWORD.');
  } else if (['ETIMEDOUT', 'ECONNECTION', 'ECONNREFUSED', 'ECONNRESET'].includes(code)) {
    console.error('Cannot reach the SMTP server. Check firewall/VPN/network restrictions. Gmail supports port 587 (STARTTLS) and 465 (TLS).');
  } else if (['EDNS', 'ENOTFOUND'].includes(code)) {
    console.error('SMTP hostname could not be resolved. Check SMTP_HOST and DNS/network access.');
  } else if (['ETLS', 'ESOCKET'].includes(code)) {
    console.error('SMTP socket or TLS handshake failed. Check port, system clock, certificates and antivirus TLS inspection.');
    const certificateErrors = ['self-signed certificate', 'unable to verify the first certificate',
      'certificate has expired', 'unable to get local issuer certificate'];
    const reason = certificateErrors.find(value => String(error.message).toLowerCase().includes(value));
    if (reason) {
      console.error(`Certificate validation: ${reason}.`);
      console.error('Check antivirus mail scanning or a network TLS proxy. If inspection is required, obtain its trusted root CA from your administrator and set NODE_EXTRA_CA_CERTS to that PEM file before starting Node.');
    }
  } else {
    console.error('Check SMTP_HOST, a valid SMTP_PORT, SMTP_USER and SMTP_PASSWORD in backend/.env.');
  }
  process.exitCode = 1;
});
