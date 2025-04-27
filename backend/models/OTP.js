const mongoose = require("mongoose");

const OTPSchema = new mongoose.Schema({
    email: { type: String, required: true },
    otp: { type: String, required: true },
    expiresAt: { type: Date, required: true } // Expiry time
});

module.exports = mongoose.model("OTP", OTPSchema);