const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const isLocalAccount = function () {
  return !this.googleId; // only email/password accounts must fill these in
};

const userSchema = new mongoose.Schema(
  {
    firstName: { type: String, required: true },
    lastName: { type: String, required: isLocalAccount },
    email: { type: String, required: true, unique: true, lowercase: true },
    phone: { type: String, required: isLocalAccount, unique: true, sparse: true },
    password: { type: String, required: isLocalAccount },
    googleId: { type: String, unique: true, sparse: true },
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    profileImageUrl: { type: String },
    isEmailVerified: { type: Boolean, default: false },
    isPhoneVerified: { type: Boolean, default: false },
    resetCodeHash: { type: String, select: false },
    resetCodeExpires: { type: Date, select: false },
    resetCodeAttempts: { type: Number, default: 0, select: false },
  },
  { timestamps: true }
);

userSchema.pre('save', async function (next) {
  if (!this.password || !this.isModified('password')) {
    return next();
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  if (!this.password) return false; // Google-only account
  return await bcrypt.compare(enteredPassword, this.password);
};

userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

const User = mongoose.model('User', userSchema);
module.exports = User;
