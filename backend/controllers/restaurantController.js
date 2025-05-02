const User = require('../models/User');
const Order = require('../models/Order');

exports.getRestaurantDashboard = async (req, res) => {
  try {
    // Change from req.user.userId to req.user.id
    const restaurant = await User.findById(req.user.id)
      .populate('creditScore')
      .populate({
        path: 'orders',
        match: { status: { $in: ['preparing', 'in-transit'] } }
      });
      
    res.json(restaurant);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.listFoodItems = async (req, res) => {
  try {
    const foodItems = await Order.find({ 
      restaurantId: req.user.userId,
      status: 'pending'
    });
    res.json(foodItems);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
