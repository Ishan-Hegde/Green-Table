// models/Food.js

const mongoose = require('mongoose');

const foodSchema = new mongoose.Schema({
  restaurantId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Restaurant',
    required: true 
  },
  restaurantName: { type: String, required: true },
  foodName: { type: String, required: true },
  description: { type: String, required: true },
  price: { type: Number, required: false },
  quantity: { type: Number, required: true },
  expiryDate: { type: Date, required: true },
  timeOfCooking: { type: Date, required: true },
  category: { type: String, required: true },
  isAvailable: { type: Boolean, default: true },
  claimedBy: [{
    consumerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    quantity: Number,
    claimedAt: { type: Date, default: Date.now }
  }],
});

// Add pre-save hook to auto-update isAvailable
foodSchema.pre('save', function(next) {
    if (this.quantity <= 0) {
        this.isAvailable = false;
    }
    next();
});

module.exports = mongoose.model('Food', foodSchema);
