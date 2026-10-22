const PaymentReceipt = require('../models/PaymentReceipt');
const sendEmail = require('../utils/sendEmail');
let running = false;
async function drainReceipts() {
  if (running || !process.env.SMTP_HOST) return;
  running = true;
  try {
    let receipt;
    while ((receipt = await PaymentReceipt.findOneAndUpdate(
      { status: 'queued' }, { $set: { status: 'sending' } }, { new: true }
    ))) {
      try {
        await sendEmail({ to: receipt.to, subject: receipt.subject, text: receipt.text });
        await PaymentReceipt.updateOne({ _id: receipt._id }, { $set: { status: 'sent', sentAt: new Date() } });
      } catch (_) {
        // SMTP can accept a message before a connection fails. Reconcile manually
        // rather than automatically sending another potentially duplicate receipt.
        await PaymentReceipt.updateOne({ _id: receipt._id }, { $set: { status: 'failed' } });
        console.error('Payment receipt requires review:', receipt.id);
      }
    }
  } finally { running = false; }
}
function startReceiptWorker() {
  const run = () => drainReceipts().catch(() => console.error('Payment receipt worker failed'));
  run();
  const timer = setInterval(run, 5000);
  timer.unref();
  return timer;
}
module.exports = { drainReceipts, startReceiptWorker };
