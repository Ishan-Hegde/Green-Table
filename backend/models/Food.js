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
  price: { type: Number, required: true },
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

module.exports = mongoose.model('Food', foodSchema);
