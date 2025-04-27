const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/register', authController.registerUser);
router.post('/verify-otp', authController.verifyOTP);
router.post('/login', authController.login);

module.exports = router;
