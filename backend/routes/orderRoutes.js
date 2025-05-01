const express = require('express');
const router = express.Router();
const orderController = require('../controllers/OrderController');
const { auth } = require('../middleware/auth');

router.post('/', auth, orderController.createOrderFromCart);

// Add status update endpoint
router.patch('/:id/status', auth, orderController.updateOrderStatus);

// Add delivery partner assignment
router.post('/:id/assign', auth, orderController.assignDeliveryPartner);

// Add OTP verification endpoint
router.post('/verify-otp', orderController.verifyDeliveryOTP);

router.patch('/:id/location', auth, orderController.updateDeliveryLocation);
router.get('/:id/track', auth, orderController.getOrderTracking);

module.exports = router;