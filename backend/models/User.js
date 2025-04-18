// const mongoose = require('mongoose');

// const UserSchema = new mongoose.Schema({
//     name: String,
//     email: { type: String, unique: true, required: true },
//     phone: { type: String, unique: true, required: true },
//     password: String,
//     role: { type: String, enum: ['consumer', 'restaurant'], required: true },
//     isVerified: { type: Boolean, default: false },
//     kycCompleted: { type: Boolean, default: false }
// });

// module.exports = mongoose.model('User', UserSchema);

const mongoose = require("mongoose");

const baseUserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['consumer', 'restaurant'], required: true },
    isVerified: { type: Boolean, default: false },
}, { timestamps: true, discriminatorKey: 'role' });

const User = mongoose.model('User', baseUserSchema);

const consumerSchema = new mongoose.Schema({});

const restaurantSchema = new mongoose.Schema({
    kycStatus: {
        type: String,
        enum: ['unverified', 'pending', 'verified', 'rejected'],
        default: 'unverified'
    },
    kycDocuments: [{
        docType: { type: String, enum: ['id', 'proof_of_address'] },
        url: String,
        uploadedAt: { type: Date, default: Date.now }
    }],
    otp: String,
    otpExpiry: Date,
}, { timestamps: true });

// const User = mongoose.model("User", userSchema);
module.exports = User;
