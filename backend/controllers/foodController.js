const mongoose = require('mongoose');
const Food = require('../models/Food');
const Restaurant = require('../models/restaurantModel');
const { validationResult } = require('express-validator');
const logger = require('../utils/logger');

exports.createFoodItem = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        logger.warn('Validation errors in food creation', { errors: errors.array() });
        return res.status(400).json({
            code: 'VALIDATION_ERROR',
            message: 'Invalid request data',
            errors: errors.array()
        });
    }

    try {
        const { restaurantId, foodName, description, price, quantity, expiryDate } = req.body;
        
        const restaurant = await Restaurant.findById(restaurantId);
        if (!restaurant) {
            logger.error('Restaurant not found', { restaurantId });
            return res.status(404).json({
                code: 'RESTAURANT_NOT_FOUND',
                message: 'Specified restaurant does not exist'
            });
        }

        // Verify restaurant ownership
        if (req.user.role !== 'restaurant' || !req.user.id.equals(restaurant._id)) {
          return res.status(403).json({ 
            error: 'UNAUTHORIZED',
            message: 'You do not own this restaurant' 
          });
        }
        const foodItem = await Food.create({
            restaurantId,
            foodName,
            description: description || '',
            price: parseFloat(price).toFixed(2),
            quantity: parseInt(quantity),
            expiryDate: expiryDate || new Date(Date.now() + 24 * 60 * 60 * 1000)
        });

        logger.info('Food item created successfully', { foodId: foodItem._id });
        
        // Broadcast real-time update
        req.io.to(restaurantId).emit('foodUpdate', foodItem);

        res.status(201).json({
            code: 'FOOD_CREATED',
            data: {
                id: foodItem._id,
                name: foodItem.foodName,
                price: foodItem.price,
                quantity: foodItem.quantity
            }
        });

    } catch (error) {
        logger.error('Food creation failed', { error: error.message });
        res.status(500).json({
            code: 'SERVER_ERROR',
            message: 'Failed to create food item'
        });
    }
};

exports.getLiveFoodItems = async (req, res) => {
    try {
        const foodItems = await Food.find({
            quantity: { $gt: 0 },
            expiryDate: { $gt: new Date() }
        }).populate('restaurantId', 'name address');

        res.json(foodItems);
    } catch (error) {
        res.status(500).json({ 
            error: 'SERVER_ERROR',
            message: 'Failed to retrieve food items' 
        });
    }
};

// Get Available Food Listings
exports.getAvailableFoodListings = async (req, res) => {
    try {
        const foodListings = await Food.find({ quantity: { $gt: 0 } });
        res.status(200).json({
            status: 'success',
            data: foodListings
        });
    } catch (error) {
        console.error('Error fetching food listings:', error);
        res.status(500).json({
            status: 'error',
            message: 'Server error'
        });
    }
};

// Get Food Items by Restaurant ID
exports.getFoodItemsByRestaurant = async (req, res) => {
    try {
        const { restaurantId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(restaurantId)) {
            return res.status(400).json({ 
                error: 'INVALID_ID_FORMAT',
                message: 'Invalid restaurant ID format' 
            });
        }

        const restaurant = await Restaurant.findById(restaurantId);
        if (!restaurant) {
            return res.status(404).json({
                error: 'RESTAURANT_NOT_FOUND',
                message: 'Specified restaurant does not exist'
            });
        }

        const foodItems = await Food.find({ restaurantId: new mongoose.Types.ObjectId(restaurantId) });

        if (!foodItems || foodItems.length === 0) {
            return res.status(404).json({
                status: 'fail',
                message: 'No food items found for this restaurant'
            });
        }

        res.status(200).json({
            status: 'success',
            data: foodItems
        });
    } catch (error) {
        console.error('Error fetching restaurant foods:', error);
        res.status(500).json({
            status: 'error',
            message: 'Server error'
        });
    }
};
exports.getAvailableFoods = async (req, res) => {
    try {
        const foodListings = await Food.find({ isAvailable: true }).populate('restaurantId', 'name');
        res.status(200).json(foodListings);
    } catch (error) {
        console.error('Error fetching food listings:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateFoodAvailability = async (req, res) => {
    try {
        const { foodId, consumerId } = req.body;
        const foodItem = await Food.findByIdAndUpdate(
            foodId,
            { isAvailable: false, claimedBy: consumerId },
            { new: true }
        );
        res.json({ message: 'Food claimed successfully', data: foodItem });
    } catch (error) {
        console.error('Error updating food availability:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.claimFoodItem = async (req, res) => {
  try {
    const { foodId, quantity } = req.body;
    const foodItem = await Food.findById(foodId);
    
    if (!foodItem.isAvailable || foodItem.quantity < quantity) {
      return res.status(400).json({ 
        error: 'INSUFFICIENT_QUANTITY',
        message: 'Not enough food available' 
      });
    }

    foodItem.quantity -= quantity;
    foodItem.claimedBy.push({
      consumerId: req.user.id,
      quantity
    });
    
    if (foodItem.quantity === 0) {
      foodItem.isAvailable = false;
    }

    await foodItem.save();
    res.json({ 
      message: 'Food claimed successfully',
      remainingQuantity: foodItem.quantity 
    });

  } catch (error) {
    res.status(500).json({ 
      error: 'SERVER_ERROR',
      message: 'Failed to claim food item' 
    });
  }
};

// Update getLiveFoodItems to filter available foods
exports.getLiveFoodItems = async (req, res) => {
  try {
    const foodItems = await Food.find({
      isAvailable: true,
      quantity: { $gt: 0 },
      expiryDate: { $gt: new Date() }
    }).populate('restaurantId', 'name location');
    res.json(foodItems);
  } catch (error) {
    res.status(500).json({ 
      error: 'SERVER_ERROR',
      message: 'Failed to retrieve food items' 
    });
  }
};
