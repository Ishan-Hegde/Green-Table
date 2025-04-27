const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['consumer', 'restaurant'], required: true },
  isVerified: { type: Boolean, default: false },
  otp: { type: String },
  otpExpiry: { type: Date },
  // Common fields
  phone: String,
  address: String,
  // Restaurant-specific fields
  restaurantName: String,
  creditScore: { type: Number, default: 0 },
  // Consumer-specific fields
  orderHistory: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Order' }] // Remove this line
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
