const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const auth = require('../middleware/auth');

router.post('/', auth, orderController.createOrder);
router.patch('/:id/status', auth, orderController.updateOrderStatus);
router.post('/:id/rating', auth, orderController.submitRating);

module.exports = router;