const express = require('express');
const foodController = require('../controllers/foodController');

const router = express.Router();

router.post('/add', foodController.createFoodItem);
router.get('/live', foodController.getAvailableFoodListings);
router.post('/claim', foodController.claimFood);

module.exports = router;
