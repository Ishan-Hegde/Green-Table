// models/Food.js

const mongoose = require('mongoose');

const foodSchema = new mongoose.Schema({
  restaurantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant', required: true },
  restaurantName: { type: String, required: true },
  foodItems: { type: [String], required: true },
  description: { type: String, default: '' },
  expiryDate: { type: Date, default: null },
  quantity: { type: Number, required: true },
  price: { type: Number, required: true },
  category: { type: String, required: true },
  timeOfCooking: { type: String, required: true },
});

module.exports = mongoose.model('FoodListing', foodSchema);
