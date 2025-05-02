const mongoose = require('mongoose');
const Food = require('../models/Food');
const Restaurant = require('../models/restaurantModel');
const { validationResult } = require('express-validator');
const logger = require('../utils/logger');
const io = require('socket.io');

exports.createFoodItem = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    try {
        const foodItem = await Food.create({
            ...req.body,
            restaurantId: req.body.restaurantId,
            isAvailable: true
        });

        // Broadcast real-time update to consumers
        req.app.get('io').emit('new-food-item', foodItem);
        logger.info('Food item created successfully', { foodId: foodItem._id });

        // Broadcast real-time update
        if (req.io && restaurantId) {
            req.io.to(restaurantId.toString()).emit('foodUpdate', foodItem);
        }

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
    const currentDate = new Date();
    
    const foodItems = await Food.find({
      quantity: { $gt: 0 },
      expiryDate: { $gt: currentDate },
      // timeOfCooking: { $lt: currentDate },  // Removed time comparison
      isAvailable: true
    })
    .select('_id restaurantId restaurantName foodName description price quantity expiryDate timeOfCooking category')
    .lean();

    res.json({
      status: 'success',
      results: foodItems.length,
      data: foodItems
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to retrieve food items',
      systemMessage: error.message
    });
  }
};

// Get Available Food Listings
exports.getAvailableFoodListings = async (req, res) => {
    try {
        const foodListings = await Food.find({ 
            isAvailable: true
        });
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
            logger.error('Restaurant lookup failed', { restaurantId: req.params.restaurantId }); // Use param directly
            return res.status(404).json({
                error: 'RESTAURANT_NOT_FOUND',
                message: 'No restaurant found with provided ID'
            });
        }

        // Convert string ID to ObjectId for comparison
        if (req.user.role !== 'restaurant' || !req.user.id.equals(new mongoose.Types.ObjectId(restaurant._id))) {
            return res.status(403).json({
                error: 'UNAUTHORIZED',
                message: 'You do not own this restaurant'
            });
        }
        const foodItems = await Food.find({ 
          restaurantId: restaurantId 
        }).populate('restaurantId', 'name address');

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
        // Rename destructured variable
        const { foodId, quantity: requestedQuantity } = req.body;
        const foodItem = await Food.findById(foodId);

        if (!foodItem.isAvailable || foodItem.quantity < requestedQuantity) {
            return res.status(400).json({
                error: 'INSUFFICIENT_QUANTITY',
                message: 'Not enough food available'
            });
        }

        foodItem.quantity -= requestedQuantity;
        foodItem.claimedBy.push({
            consumerId: req.user.id,
            // Use renamed variable
            quantity: requestedQuantity,
            claimedAt: new Date()
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