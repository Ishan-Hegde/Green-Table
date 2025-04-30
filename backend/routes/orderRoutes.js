const express = require('express');
const router = express.Router();
const orderController = require('../controllers/OrderController');
const { auth } = require('../middleware/auth'); // Destructure auth from middleware

router.post('/', auth, orderController.createOrderFromCart);

module.exports = router;