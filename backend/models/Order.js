const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  consumer: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Consumer', 
    required: true 
  },
  restaurant: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Restaurant', 
    required: true 
  },
  items: [{
    foodItem: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: 'Food', 
      required: true 
    },
    quantity: { 
      type: Number, 
      required: true,
      min: 1
    }
  }],
  status: {
    type: String,
    enum: ['pending', 'preparing', 'out-for-delivery', 'delivered', 'cancelled'],
    default: 'pending'
  },
  totalAmount: {
    type: Number,
    required: true
  },
  deliveryOTP: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  deliveryLocation: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], default: [0, 0] }
  }
});

module.exports = mongoose.model('Order', orderSchema);