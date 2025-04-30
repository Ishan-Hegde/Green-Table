const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');
const { auth } = require('../middleware/auth');

router.post('/add', auth, cartController.addToCart);
router.get('/', auth, cartController.getCart);
router.post('/checkout', auth, cartController.checkoutCart);

module.exports = router;