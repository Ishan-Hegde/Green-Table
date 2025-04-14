const express = require('express');
const { addFoodListing, getAvailableFoodListings, claimFood } = require('../controllers/foodController');

const router = express.Router();

router.post('/add', addFoodListing);
router.get('/available', getAvailableFoodListings);
router.post('/claim', claimFood);

module.exports = router;
