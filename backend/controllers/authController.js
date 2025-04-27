const User = require('../models/User');
const Restaurant = require('../models/restaurantModel');
const OTP = require('../models/OTP');
const { sendOTP } = require('../utils/emailService');
const bcrypt = require('bcryptjs');  // Ensure this import exists
const jwt = require('jsonwebtoken');
const { sendEmail } = require('../utils/emailService');  // Replace mailer reference

// Restaurant Registration
exports.registerRestaurant = async (req, res) => {
    try {
        const { email, password, name, phone, address } = req.body;
        let existingUser = await Restaurant.findOne({ email });

        if (existingUser) {
            return res.status(400).json({ message: "Restaurant already registered. Please log in." });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newRestaurant = new Restaurant({
            email, password: hashedPassword, name, phone, address, isKYCVerified: false
        });
        await newRestaurant.save();

        const otpCode = Math.floor(100000 + Math.random() * 900000);
        await OTP.create({ email, otp: otpCode });

        // In the registerRestaurant function, replace:
        await sendOTP(email, otpCode);
        // With:
        await sendEmail({
            to: email,
            subject: 'OTP Verification',
            text: `Your OTP is: ${otpCode}`
        });

        res.status(200).json({ message: "OTP sent. Please verify to complete registration." });
    } catch (error) {
        console.error("Error in registerRestaurant:", error);
        res.status(500).json({ error: "Internal server error." });
    }
};

// Verify OTP
exports.verifyOTP = async (req, res) => {
    try {
        const { email, otp, userType } = req.body;
        const isValid = await verifyOTP(email, otp);

        if (!isValid) {
            return res.status(400).json({ message: "Invalid OTP or OTP expired." });
        }

        if (userType === 'donor') {
            await Restaurant.updateOne({ email }, { isVerified: true });
        } else if (userType === 'consumer') {
            await User.updateOne({ email, role: 'consumer' }, { isVerified: true });
        }

        res.status(200).json({ message: "OTP verified successfully. Registration complete." });
    } catch (error) {
        console.error("Error in verifyOTP:", error);
        res.status(500).json({ error: "Internal server error." });
    }
};

// User registration logic
exports.registerUser = async (req, res) => {
    try {
        const { email, password, role, ...rest } = req.body;
    
        // Generate OTP
        const otp = Math.floor(100000 + Math.random() * 900000);
        const otpExpiry = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

        await sendEmail({
            to: email,
            subject: 'Your Green Table Verification OTP',
            html: `<div>
                <h3>Green Table Verification Code</h3>
                <p>Your OTP code is: <strong>${otp}</strong></p>
                <p>This code expires in 5 minutes.</p>
            </div>`
        });
        const user = new User({
          email,
          password: await bcrypt.hash(password, 10),
          role,
          otp,
          otpExpiry,
          ...rest
        });
    
        await user.save();
        // Replace sendOTP with proper email implementation
        await sendEmail({
            to: email,
            subject: 'OTP Verification',
            text: `Your OTP code is: ${otp}`
        });
        
        res.status(201).json({ message: 'OTP sent to email' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.verifyOTP = async (req, res) => {
    try {
        const { email, otp } = req.body;
        const user = await User.findOne({ email, otp, otpExpiry: { $gt: new Date() } });
    
        if (!user) return res.status(400).json({ error: 'Invalid or expired OTP' });
    
        user.isVerified = true;
        user.otp = undefined;
        user.otpExpiry = undefined;
        await user.save();
    
        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
        
        res.json({ token, role: user.role });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// User login logic
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });

        if (!user || !(await bcrypt.compare(password, user.password))) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Check verification status
        if (user.role === 'restaurant') {
            const restaurant = await Restaurant.findOne({ userId: user._id });
        }

        if (!user.isVerified) {
            return res.status(403).json({
                message: 'OTP verification required',
                requiresOTP: true
            });
        }

        // Generate token
        const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.json({ token, role: user.role });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Remove the entire uploadKYC function and its references
