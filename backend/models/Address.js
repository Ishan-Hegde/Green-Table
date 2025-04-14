const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,  // Optional, if you want to enforce unique emails
  },
  address: {
    type: String,
    required: true,
  },
}, { timestamps: true });

const Address = mongoose.model('Address', addressSchema);

module.exports = Address;
