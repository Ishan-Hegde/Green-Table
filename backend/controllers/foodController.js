const Food = require('../models/Food');

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
            imageUrl,
        } = req.body;

        if (!foodName || !description || !price || !quantity || !expiryDate || !timeOfCooking || !category || !imageUrl) {
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
            imageUrl,
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
        const foodListings = await Food.find({ isAvailable: true }).populate('restaurantId', 'name');
        res.json(foodListings);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching food listings', error });
    }
};

exports.claimFood = async (req, res) => {
    try {
        const { foodId, consumerId } = req.body;
        const foodItem = await Food.findByIdAndUpdate(
            foodId,
            { isAvailable: false, claimedBy: consumerId },
            { new: true }
        );
        res.json({ message: 'Food claimed successfully', data: foodItem });
    } catch (error) {
        res.status(500).json({ message: 'Error claiming food item', error });
    }
};
