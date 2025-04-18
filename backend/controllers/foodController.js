const mongoose = require('mongoose');
const Food = require('../models/Food');
const FoodListing = require('../models/FoodListing');

// Create Food Item
exports.createFoodItem = async (req, res) => {
    try {
        const {
            restaurantId,
            restaurantName,
            foodName,
            description,
            price,
            quantity,
            expiryDate,
            timeOfCooking,
            category,
        } = req.body;

        if (!foodName || !description || !price || !quantity || !expiryDate || !timeOfCooking || !category) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        if (isNaN(price) || isNaN(quantity)) {
            return res.status(400).json({ message: 'Price and quantity must be numbers' });
        }

        const foodItem = await Food.create({
            restaurantId,
            restaurantName,
            foodName: foodName,
            description,
            price: parseFloat(price),
            quantity: parseInt(quantity),
            expiryDate: new Date(expiryDate),
            timeOfCooking: new Date(timeOfCooking),
            category,
        });

        res.status(201).json({
            status: 'success',
            data: foodItem
        });
    } catch (error) {
        res.status(400).json({
            status: 'fail',
            message: error.message
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

        if (!restaurantId || !mongoose.Types.ObjectId.isValid(restaurantId)) {
            return res.status(400).json({
                status: 'fail',
                message: 'Invalid restaurant ID format'
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
