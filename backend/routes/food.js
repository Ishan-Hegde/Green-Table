const express = require('express');
const Food = require('../models/Food'); // Fixed model reference

const router = express.Router();

// Get all food listings for a restaurant
router.get('/:restaurantId', async (req, res) => {
  try {
    const foods = await Food.find({ restaurantId: req.params.restaurantId });
    res.json(foods);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Existing endpoints remain unchanged
module.exports = router;
