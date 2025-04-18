const express = require('express');
const foodController = require('../controllers/foodController');

const router = express.Router();

router.post('/add', foodController.createFoodItem);
router.get('/live', foodController.getAvailableFoodListings);
router.get('/:restaurantId', foodController.getFoodItemsByRestaurant);
router.post('/claim', foodController.updateFoodAvailability);

module.exports = router;
