// routes/restaurant.js
const express = require('express');
const router = express.Router();
const Restaurant = require('../models/restaurantModel');

// Register Restaurant Endpoint (existing code)
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;

  // Check if all required fields are provided
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Missing required fields: name, email, or password' });
  }

  try {
    // Check if restaurant already exists
    const existingRestaurant = await Restaurant.findOne({ email });
    if (existingRestaurant) {
      return res.status(400).json({ message: 'Restaurant with this email already exists' });
    }

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create a new restaurant
    const newRestaurant = new Restaurant({
      name,
      email,
      password: hashedPassword,
    });

    // Save the restaurant to the database
    const savedRestaurant = await newRestaurant.save();

    // Respond with success message
    res.status(201).json({
      message: 'Restaurant registered successfully',
      restaurant: {
        id: savedRestaurant._id,
        name: savedRestaurant.name,
        email: savedRestaurant.email,
      },
    });
  } catch (error) {
    console.error(error);  // Log error for debugging purposes
    res.status(500).json({
      message: 'Failed to register restaurant',
      error: error.message || 'Internal server error',
    });
  }
});

// Fetch all restaurant details
router.get('/all', async (req, res) => {
  try {
    const restaurants = await Restaurant.find({}, { password: 0 }); // Exclude password field
    res.status(200).json(restaurants);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch restaurant details' });
  }
});

// Add the route to fetch a restaurant by its unique _id
router.get('/:id', async (req, res) => {
  const { id } = req.params;

  try {
    // Find the restaurant by its unique _id
    const restaurant = await Restaurant.findById(id);

    if (!restaurant) {
      return res.status(404).send('Restaurant not found');
    }

    // Send the restaurant data back as JSON
    res.json(restaurant);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

module.exports = router;
