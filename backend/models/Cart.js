const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
  consumer: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
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
  createdAt: { 
    type: Date, 
    default: Date.now 
  }
});

module.exports = mongoose.model('Cart', cartSchema);