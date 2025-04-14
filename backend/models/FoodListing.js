const mongoose = require('mongoose');

const FoodListingSchema = new mongoose.Schema({
    restaurantId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    foodName: String,
    quantity: Number,
    expiryTime: Date,
    pickupLocation: String,
    status: { type: String, enum: ['available', 'claimed'], default: 'available' }
});

module.exports = mongoose.model('FoodListing', FoodListingSchema);
