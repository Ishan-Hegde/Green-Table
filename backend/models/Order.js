const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  restaurantId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: true 
  },
  consumerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: true 
  },
  items: [{
    foodId: String,
    quantity: Number,
    price: Number
  }],
  status: {
    type: String,
    enum: ['pending', 'preparing', 'in-transit', 'delivered', 'cancelled'],
    default: 'pending'
  },
  totalAmount: Number,
  deliveryLocation: {
    type: { type: String, default: 'Point' },
    coordinates: [Number]
  },
  rating: { type: Number, min: 1, max: 5 }
}, { timestamps: true });

orderSchema.index({ deliveryLocation: '2dsphere' });
module.exports = mongoose.model('Order', orderSchema);