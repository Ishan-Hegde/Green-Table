const express = require('express');
const router = express.Router();
const Address = require('../models/Address');

// Save Address Endpoint
router.post('/save-address', async (req, res) => {
  const { name, email, address } = req.body;

  // Check if all required fields are present
  if (!name || !email || !address) {
    return res.status(400).json({ message: 'Missing required fields: name, email, or address' });
  }

  try {
    // Create a new address object
    const newAddress = new Address({ name, email, address });

    // Save the address to the database
    const savedAddress = await newAddress.save();

    // Respond with success message and the saved address
    res.status(201).json({
      message: 'Address saved successfully',
      address: savedAddress,
    });
  } catch (error) {
    console.error(error);  // Log error for debugging purposes
    res.status(500).json({
      message: 'Failed to save address',
      error: error.message || 'Internal server error',
    });
  }
});

module.exports = router;
