// routes/consumer.js
const express = require('express');
const router = express.Router();
const Consumer = require('../models/Consumer');

// Fetch all consumer details
router.get('/all', async (req, res) => {
  try {
    const consumers = await Consumer.find({}, { password: 0 }); // Exclude password field
    res.status(200).json(consumers);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch consumer details' });
  }
});

module.exports = router;
