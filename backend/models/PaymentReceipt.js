const mongoose = require('mongoose');
const receiptSchema = new mongoose.Schema({
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true, unique: true },
  to: { type: String, required: true },
  subject: { type: String, required: true },
  text: { type: String, required: true },
  status: { type: String, enum: ['queued', 'sending', 'sent', 'failed'], default: 'queued' },
  sentAt: Date,
  resendRequestedAt: Date,
}, { timestamps: true });
module.exports = mongoose.model('PaymentReceipt', receiptSchema);
