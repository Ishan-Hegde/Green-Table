const Food = require('../models/Food');

// Create Food Item
exports.createFoodItem = async (req, res) => {
    try {
        const { 
            name,
            description,
            price,
            quantity,
            expiryDate,
            timeOfCooking,
            restaurantId,
            restaurantName,
            imageUrl,
            isAvailable
        } = req.body;

        const foodItem = await Food.create({
            name,
            description,
            price: Number(price),
            quantity: Number(quantity),
            expiryDate: new Date(expiryDate),
            timeOfCooking: new Date(timeOfCooking),
            restaurantId,
            restaurantName,
            imageUrl,
            isAvailable: Boolean(isAvailable)
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
