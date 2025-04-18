// const express = require('express');
// const { registerConsumer, registerRestaurant, login } = require('../controllers/authController');

// const router = express.Router();

// router.post('/register/consumer', registerConsumer);
// router.post('/register/restaurant', registerRestaurant);
// router.post('/login', login);

// module.exports = router;
const express = require('express');
const { registerRestaurant, login, verifyOTP, uploadKYC, registerUser } = require('../controllers/authController');

const router = express.Router();

router.post('/register-restaurant', registerRestaurant);
router.post('/register-consumer', registerUser);
router.post('/login', login);
router.post('/verify-otp', verifyOTP);
const upload = require('../middleware/multer');
router.post('/upload-kyc', upload.single('document'), uploadKYC);

module.exports = router;
