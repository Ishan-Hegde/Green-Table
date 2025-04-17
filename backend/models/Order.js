const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  consumer: { type: mongoose.Schema.Types.ObjectId, ref: 'Consumer', required: true },
  restaurant: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant', required: true },
  items: [{
    foodItem: { type: mongoose.Schema.Types.ObjectId, ref: 'Food', required: true },
    quantity: { type: Number, required: true }
  }],
  status: {
    type: String,
    enum: ['pending', 'preparing', 'in_transit', 'delivered', 'cancelled'],
    default: 'pending'
  },
  deliveryPartner: { type: mongoose.Schema.Types.ObjectId, ref: 'DeliveryPartner' },
  estimatedDeliveryTime: Date,
  actualDeliveryTime: Date,
  pickupTime: Date,
  location: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], required: true }
  },
  trackingHistory: [{
    status: String,
    location: {
      type: { type: String, default: 'Point' },
      coordinates: [Number]
    },
    timestamp: { type: Date, default: Date.now }
  }]
}, { timestamps: true });

orderSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Order', orderSchema);