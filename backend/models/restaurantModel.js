const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const restaurantSchema = new Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { 
    type: String, 
    required: true,
    minlength: 8,
    select: false
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  status: {
    type: String,
    enum: ['pending', 'active', 'suspended'],
    default: 'pending'
  },
  name: String,
  location: {
    type: { type: String, default: 'Point' },
    coordinates: [Number]
  },
  // Add credit system fields
  creditScore: { type: Number, default: 100 },
  quarterlyOrders: { type: Number, default: 0 },
  averageRating: { type: Number, default: 0 },
  isBanned: { type: Boolean, default: false }
});

module.exports = mongoose.model('Restaurant', restaurantSchema);
