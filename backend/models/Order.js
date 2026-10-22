const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema(
  {
    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product',
      required: true,
    },
    name: { type: String, required: true },
    price: { type: Number, required: true },
    quantity: { type: Number, required: true, default: 1 },
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event' },
    eventTitle: String,
    quantity: { type: Number, min: 1 },
    amount: String,
    currency: { type: String, default: 'LKR' },
    payment_status: { type: String, enum: ['pending', 'paid', 'failed', 'cancelled', 'chargedback'], default: 'pending' },
    payhere_payment_id: { type: String },
    customer: {
      first_name: String, last_name: String, email: String, phone: String,
      address: String, city: String, country: String,
    },
    items: [orderItemSchema],
    totalAmount: { type: Number, required: true },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled'],
      default: 'pending',
    },
    deliveryAddress: { type: String },
    notes: { type: String },
    completedAt: { type: Date },
  },
  { timestamps: true }
);

orderSchema.index({ user: 1, eventId: 1 }, { unique: true, partialFilterExpression: { eventId: { $exists: true } } });
orderSchema.index({ payhere_payment_id: 1 }, { unique: true, sparse: true });
const Order = mongoose.model('Order', orderSchema);
module.exports = Order;
