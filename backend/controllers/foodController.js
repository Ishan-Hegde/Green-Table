const FoodListing = require('../models/FoodListing');

// Add Food Listing
exports.addFoodListing = async (req, res) => {
    try {
        const { restaurantId, foodName, quantity, expiryTime, pickupLocation } = req.body;

        const food = await FoodListing.create({ restaurantId, foodName, quantity, expiryTime, pickupLocation });

        res.status(201).json({ message: 'Food listing added successfully', food });
    } catch (error) {
        res.status(500).json({ message: 'Error adding food listing', error });
    }
};

// Get Available Food Listings
exports.getAvailableFoodListings = async (req, res) => {
    try {
        const foodListings = await FoodListing.find({ status: 'available' }).populate('restaurantId', 'name');
        res.json(foodListings);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching food listings', error });
    }
};

// Claim Food
exports.claimFood = async (req, res) => {
    try {
        const { foodId } = req.body;

        const food = await FoodListing.findById(foodId);
        if (!food || food.status !== 'available') {
            return res.status(400).json({ message: 'Food not available' });
        }

        food.status = 'claimed';
        await food.save();

        res.json({ message: 'Food claimed successfully', food });
    } catch (error) {
        res.status(500).json({ message: 'Error claiming food', error });
    }
};
