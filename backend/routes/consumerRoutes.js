const express = require('express');
const router = express.Router();
const User = require('../models/User');  

router.get('/all', async (req, res) => {
  try {
    const consumers = await User.find({ role: 'consumer' }, { password: 0 });
    res.status(200).json(consumers);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch consumer details' });
  }
});

module.exports = router; // Ensure this export exists
