const mongoose = require('mongoose');

const KYCSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    restaurantName: String,
    ownerName: String,
    address: String,
    licenseNumber: String,
    documents: [String], // Store document URLs
    status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' }
});

module.exports = mongoose.model('KYC', KYCSchema);
