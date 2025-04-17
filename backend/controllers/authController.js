const User = require('../models/User');
const Restaurant = require('../models/restaurantModel');
const Consumer = require('../models/Consumer');
const OTP = require('../models/OTP');
const sendOTP = require('../utils/mailer');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { generateOTP, verifyOTP } = require('../utils/otpService');

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

        await sendOTP(email, otpCode);

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
            await Consumer.updateOne({ email }, { isVerified: true });
        }

        res.status(200).json({ message: "OTP verified successfully. Registration complete." });
    } catch (error) {
        console.error("Error in verifyOTP:", error);
        res.status(500).json({ error: "Internal server error." });
    }
};

// Consumer Registration
exports.registerConsumer = async (req, res) => {
    try {
        const { name, email, phone, password, confirmPassword } = req.body;

        if (password !== confirmPassword) {
            return res.status(400).json({ message: "Passwords do not match" });
        }

        let existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "Email already registered" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({
            name,
            email,
            phone,
            password: hashedPassword,
            role: "consumer",
            isVerified: false
        });

        await newUser.save();

        const otpCode = Math.floor(100000 + Math.random() * 900000);
        await OTP.create({ email, otp: otpCode });

        await sendOTP(email, otpCode);

        return res.status(201).json({ message: "Consumer registered successfully. OTP sent to email." });

    } catch (error) {
        console.error("Error in registerConsumer:", error);
        res.status(500).json({ message: "Server error" });
    }
};

// Login
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const consumer = await User.findOne({ email });
        const restaurant = await Restaurant.findOne({ email });

        if (!consumer && !restaurant) {
            return res.status(404).json({ message: "User not found." });
        }

        const user = consumer || restaurant;
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: "Invalid credentials." });

        if (restaurant && (!restaurant.isKYCVerified || restaurant.kycStatus !== 'verified')) {
            return res.status(403).json({ 
              message: "KYC verification required. Please complete verification process.",
              nextStep: "/kyc-upload"
            });
        }

        if (consumer && !consumer.isVerified) {
            return res.status(403).json({ message: "OTP not verified. Please complete verification." });
        }

        const token = jwt.sign({ id: user._id, role: restaurant ? "restaurant" : "consumer" }, process.env.JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({ message: "Login successful.", token });
    } catch (error) {
        console.error("Error in login:", error);
        res.status(500).json({ error: "Internal server error." });
    }
};

// Upload KYC Documents
exports.uploadKYC = async (req, res) => {
    try {
        console.log("Finding restaurant with email:", req.body.email);
        const restaurant = await Restaurant.findOne({ email: req.body.email });

        if (!restaurant) {
            return res.status(404).json({ message: "Restaurant not found" });
        }

        if (!restaurant.isVerified) {
            return res.status(400).json({ message: "Please verify OTP before uploading KYC" });
        }

        if (!req.file) {
            return res.status(400).json({ message: "KYC document is required" });
        }

        // Storing file path in the database
        restaurant.kycDocument = req.file.path;
        // Simulate KYC verification API call
        const verificationResult = await verifyKYCDocument({
  documentPath: req.file.path,
  apiKey: process.env.KYC_API_KEY,
  endpoint: process.env.KYC_API_ENDPOINT
});

        if (verificationResult.status === 'verified') {
          restaurant.isKYCVerified = true;
          restaurant.kycStatus = "verified";
          await restaurant.save();
          return res.status(200).json({ message: "KYC verification completed successfully." });
        } else {
          restaurant.kycStatus = "rejected";
          await restaurant.save();
          return res.status(400).json({ message: "KYC verification failed. Please submit valid documents." });
        }
    } catch (error) {
        console.error("Error in uploadKYC:", error);
        return res.status(500).json({ message: "Internal Server Error" });
    }
};
