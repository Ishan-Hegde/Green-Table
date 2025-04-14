const express = require('express');
const router = express.Router();
const User = require('../models/User');
const crypto = require('crypto');
const sendEmail = require('../utils/emailService');

// User Registration Route
router.post('/register', async (req, res) => {
    const { name, email, password, emailPassword } = req.body;

    try {
        let user = await User.findOne({ email });

        if (user) {
            return res.status(400).json({ message: "User already exists" });
        }

        // Create new user
        user = new User({ name, email, password, emailPassword });

        // Generate OTP
        const otp = crypto.randomInt(100000, 999999).toString();
        user.otp = otp;
        user.otpExpires = Date.now() + 10 * 60 * 1000; // OTP expires in 10 minutes

        await user.save();

        // Send OTP via email using user's credentials
        await sendEmail(email, emailPassword, "Your OTP Code", `Your OTP is: ${otp}`);

        res.status(201).json({ message: "User registered. OTP sent to email." });

    } catch (error) {
        res.status(500).json({ message: "Error registering user", error });
    }
});

// OTP Verification Route
router.post('/verify-otp', async (req, res) => {
    const { email, otp } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(400).json({ message: "User not found" });
        }

        // Check OTP and expiration
        if (user.otp !== otp || user.otpExpires < Date.now()) {
            return res.status(400).json({ message: "Invalid or expired OTP" });
        }

        // OTP verified, clear it from DB
        user.otp = null;
        user.otpExpires = null;
        await user.save();

        res.status(200).json({ message: "OTP verified successfully" });

    } catch (error) {
        res.status(500).json({ message: "Error verifying OTP", error });
    }
});

module.exports = router;
