const express = require('express');
const router = express.Router();
const OrderController = require('../controllers/OrderController');
const authMiddleware = require('../middleware/authMiddleware');

// Order creation
router.post('/create', authMiddleware, OrderController.createOrder);

// Order status retrieval
router.get('/:orderId/status', authMiddleware, OrderController.getOrderStatus);

// Delivery assignment
router.post('/:orderId/assign-delivery', authMiddleware, OrderController.assignDeliveryPartner);

// Status updates
router.put('/:orderId/status', authMiddleware, OrderController.updateOrderStatus);

// Order details
router.get('/:orderId', authMiddleware, OrderController.getOrderDetails);

module.exports = router;