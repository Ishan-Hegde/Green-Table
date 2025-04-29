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
        
        // Find valid OTP
        const validOTP = await OTP.findOne({ 
            email,
            otp,
            expiresAt: { $gt: new Date() }
        });

        if (!validOTP) {
            return res.status(400).json({ error: 'Invalid or expired OTP' });
        }

        // Handle restaurant verification
        if (userType === 'restaurant') {
            const restaurant = await Restaurant.findOneAndUpdate(
                { email },
                { isVerified: true },
                { new: true }
            );
            
            if (!restaurant) {
                return res.status(404).json({ error: 'Restaurant not found' });
            }

            // Generate JWT token for restaurant
            const token = jwt.sign({ 
                restaurantId: restaurant._id,
                role: 'restaurant'
            }, process.env.JWT_SECRET, { expiresIn: '1d' });

            await OTP.deleteOne({ _id: validOTP._id });
            return res.json({ 
                token,
                role: 'restaurant',
                message: 'Restaurant OTP verified successfully'
            });
        }

        // Existing consumer verification logic
        const user = await User.findOneAndUpdate(
            { email },
            { isVerified: true },
            { new: true }
        );

        // Delete used OTP
        await OTP.deleteOne({ _id: validOTP._id });

        // Generate JWT token
        const token = jwt.sign({ 
            userId: user._id,
            role: user.role
        }, process.env.JWT_SECRET, { expiresIn: '1d' });

        res.json({ 
            token,
            role: user.role,
            message: 'OTP verified successfully'
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// User registration logic
exports.registerUser = async (req, res) => {
    try {
        const { email, password, role, ...rest } = req.body;
        
        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: 'User already exists' });
        }

        // Generate OTP
        const otp = Math.floor(100000 + Math.random() * 900000);
        const otpExpiry = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

        // Save OTP to database
        await OTP.create({ 
            email,
            otp: otp.toString(),
            expiresAt: otpExpiry
        });

        // Send OTP email
        const emailSent = await sendOTP(email, otp);
        if (!emailSent) {
            return res.status(500).json({ error: 'Failed to send OTP' });
        }

        // Create user (without verification)
        const user = new User({
            email,
            password: await bcrypt.hash(password, 10),
            role,
            isVerified: false,
            ...rest
        });

        await user.save();
        
        res.status(201).json({ 
            message: 'OTP sent successfully',
            email: email
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.verifyOTP = async (req, res) => {
    try {
        const { email, otp } = req.body;
        
        // Find valid OTP
        const validOTP = await OTP.findOne({ 
            email,
            otp,
            expiresAt: { $gt: new Date() }
        });

        if (!validOTP) {
            return res.status(400).json({ error: 'Invalid or expired OTP' });
        }

        // Update user verification status
        const user = await User.findOneAndUpdate(
            { email },
            { isVerified: true },
            { new: true }
        );

        // Delete used OTP
        await OTP.deleteOne({ _id: validOTP._id });

        // Generate JWT token
        const token = jwt.sign({ 
            userId: user._id,
            role: user.role
        }, process.env.JWT_SECRET, { expiresIn: '1d' });

        res.json({ 
            token,
            role: user.role,
            message: 'OTP verified successfully'
        });
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
