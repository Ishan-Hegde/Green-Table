const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Add loyalty program fields
const userSchema = new Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['consumer', 'restaurant'], required: true },
  isVerified: { type: Boolean, default: false },
  otp: { type: String },
  otpExpiry: { type: Date },
  address: String,
  // Restaurant-specific fields
  restaurantName: String,
  creditScore: { type: Number, default: 0 },

  // Consumer-specific fields
  orderHistory: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Order' }],
  loyaltyPoints: { type: Number, default: 0 },
  favoriteRestaurants: [{ type: Schema.Types.ObjectId, ref: 'Restaurant' }],
  reviewHistory: [{
    restaurant: { type: Schema.Types.ObjectId, ref: 'Restaurant' },
    rating: Number,
    comment: String
  }]
});

module.exports = mongoose.model('User', userSchema);
