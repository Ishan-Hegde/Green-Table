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

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ["consumer"], required: true }, 
    isVerified: { type: Boolean, default: false }, // OTP verification
}, { timestamps: true });

const User = mongoose.model("User", userSchema);
module.exports = User;
