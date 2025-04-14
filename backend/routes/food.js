const express = require('express');
const FoodListing = require('../models/FoodListing');

const router = express.Router();

// Add food listing
router.post('/add', async (req, res) => {
  const { restaurantId, foodName, quantity, expiryDate, location } = req.body;
  
  const newListing = new FoodListing({ restaurantId, foodName, quantity, expiryDate, location });
  await newListing.save();

  res.json({ message: 'Food listed successfully', data: newListing });
});

// Get live food listings
router.get('/live', async (req, res) => {
  const listings = await FoodListing.find().sort({ createdAt: -1 });
  res.json(listings);
});

module.exports = router;
