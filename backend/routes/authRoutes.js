// const express = require('express');
// const { registerConsumer, registerRestaurant, login } = require('../controllers/authController');

// const router = express.Router();

// router.post('/register/consumer', registerConsumer);
// router.post('/register/restaurant', registerRestaurant);
// router.post('/login', login);

// module.exports = router;
const express = require('express');
const { registerRestaurant, login, verifyOTP, uploadKYC, registerConsumer } = require('../controllers/authController');

const router = express.Router();

router.post('/register-restaurant', registerRestaurant);
router.post('/register-consumer', registerConsumer);
router.post('/login', login);
router.post('/verify-otp', verifyOTP);
router.post('/upload-kyc', uploadKYC);

module.exports = router;
