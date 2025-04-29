const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
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
    }
});

module.exports = mongoose.model('Restaurant', restaurantSchema);
