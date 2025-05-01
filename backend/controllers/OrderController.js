const Order = require('../models/Order');
const Cart = require('../models/Cart'); // Add this import
const { calculateCreditScore } = require('../utils/creditSystem');
const Food = require('../models/Food');
const Restaurant = require('../models/restaurantModel');
const User = require('../models/User');
const { emitToRoom } = require('../utils/socketManager');
const { calculateETA } = require('../utils/mapService');

// exports.createOrder = async (req, res) => {
//   try {
//     const order = await Order.create({
//       ...req.body,
//       consumerId: req.user.userId
//     });
    
//     // Real-time update
//     req.io.to(order.restaurantId.toString()).emit('new-order', order);
//     res.status(201).json(order);
    
//   } catch (error) {
//     res.status(400).json({ error: error.message });
//   }
// };

exports.updateOrderStatus = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Get the restaurant through the User model
    const restaurantUser = await User.findOne({
      _id: order.restaurant,
      role: 'restaurant'
    });

    // Modified comparison to handle undefined values
    if (!restaurantUser || String(restaurantUser._id) !== String(req.user.id)) {
      return res.status(403).json({ error: 'Unauthorized access' });
    }

    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.id,
      { status: req.body.status },
      { new: true }
    );

    emitToRoom(updatedOrder.id, 'status-update', updatedOrder);
    res.json(updatedOrder);
  } catch (error) {
    res.status(500).json({ 
      error: 'UPDATE_FAILED',
      message: error.message 
    });
  }
};

exports.submitRating = async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { rating: req.body.rating },
      { new: true }
    );

    // Update restaurant credit score
    const restaurant = await User.findById(order.restaurantId);
    restaurant.creditScore = calculateCreditScore(restaurant);
    await restaurant.save();

    res.json(order);
    
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.assignDeliveryPartner = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { deliveryPartnerId } = req.body;

    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ error: 'Order not found' });

    const restaurant = await Restaurant.findById(order.restaurant);
    const consumer = await User.findById(order.consumer);
    
    const eta = await calculateETA(
      restaurant.location.coordinates,
      consumer.location.coordinates
    );

    const updatedOrder = await Order.findByIdAndUpdate(
      orderId,
      { 
        deliveryPartner: deliveryPartnerId,
        estimatedDeliveryTime: new Date(Date.now() + eta * 1000),
        status: 'preparing'
      },
      { new: true }
    );

    emitToRoom(order.restaurant.toString(), 'deliveryAssigned', updatedOrder);
    res.status(200).json(updatedOrder);
  } catch (error) {
    console.error('Delivery assignment error:', error);
    res.status(500).json({ error: 'Failed to assign delivery partner' });
  }
};

exports.getOrderDetails = async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId)
      .populate('consumer restaurant deliveryPartner');
    res.status(200).json(order);
  } catch (error) {
    console.error('Order fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch order details' });
  }
};

exports.createOrderFromCart = async (req, res) => {
    try {
        const cart = await Cart.findOne({ consumer: req.user.id });
        
        // Add delivery location validation
        const deliveryLocation = {
            type: 'Point',
            coordinates: [
                parseFloat(req.body.deliveryAddress.longitude),
                parseFloat(req.body.deliveryAddress.latitude)
            ]
        };

        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ error: 'EMPTY_CART' });
        }
    
        const order = await Order.create({
            consumer: req.user.id,
            restaurant: cart.restaurant,
            items: cart.items,
            deliveryLocation, // Add validated location
            totalAmount: cart.items.reduce((acc, item) => 
                acc + (item.foodItem.price * item.quantity), 0),
            deliveryOTP: Math.floor(100000 + Math.random() * 900000).toString(),
            status: 'pending'
        });
    
        // Clear cart
        await Cart.deleteOne({ _id: cart._id });
    
        // Notify restaurant
        req.io.to(`restaurant_${cart.restaurant}`).emit('new-order', order);
        
        res.status(201).json({
            message: 'Order created successfully',
            orderId: order._id,  // Order ID included here
            status: order.status,
            restaurant: order.restaurant
        });
        
        // Reduce food quantities
        for (const item of cart.items) {
            await Food.findByIdAndUpdate(item.foodItem, {
                $inc: { quantity: -item.quantity }
            });
        }
    } catch (error) {
        res.status(500).json({ error: 'ORDER_FAILED', message: error.message });
    }
};

exports.verifyDeliveryOTP = async (req, res) => {
  try {
    const { orderId, otp } = req.body;
    
    const order = await Order.findOne({
      _id: orderId,
      deliveryOTP: otp,
      status: 'out-for-delivery'
    });

    if (!order) {
      return res.status(400).json({ error: 'INVALID_OTP' });
    }

    order.status = 'delivered';
    await order.save();

    // Final status update and cleanup
    await Order.findByIdAndUpdate(orderId, { 
      status: 'completed',
      completedAt: Date.now()
    });
    
    // Update restaurant analytics
    // Add to verifyDeliveryOTP function
    await Restaurant.findByIdAndUpdate(order.restaurant, {
      $inc: { 
        totalOrders: 1,
        quarterlyOrders: 1,
        totalRevenue: order.totalAmount
      },
      $set: { 
        averageRating: await calculateAverageRating(order.restaurant),
        isBanned: await checkBanStatus(order.restaurant)
      }
    });
    
    // New helper functions
    const calculateAverageRating = async (restaurantId) => {
      const result = await Order.aggregate([
        { $match: { restaurant: restaurantId, rating: { $exists: true } } },
        { $group: { _id: null, avgRating: { $avg: "$rating" } } }
      ]);
      return result[0]?.avgRating || 0;
    };
    
    const checkBanStatus = async (restaurantId) => {
      const restaurant = await Restaurant.findById(restaurantId);
      return restaurant.quarterlyOrders < 50 && restaurant.averageRating < 3.5;
    };

    const updateRestaurantStats = async (restaurantId, amount) => {
      await Restaurant.findByIdAndUpdate(restaurantId, {
        $inc: {
          totalOrders: 1,
          quarterlyOrders: 1,
          totalRevenue: amount
        }
      });
      
      const stats = await Restaurant.findById(restaurantId);
      if(stats.quarterlyOrders < 50 && stats.averageRating < 3.5) {
        await Restaurant.findByIdAndUpdate(restaurantId, { isBanned: true });
      }
    };
    
    res.json({ message: 'Delivery verified successfully' });
  } catch (error) {
    res.status(500).json({ error: 'OTP_VERIFICATION_FAILED' });
  }
};

exports.updateDeliveryLocation = async (req, res) => {
    try {
        const order = await Order.findByIdAndUpdate(
            req.params.id,
            { deliveryLocation: req.body.location },
            { new: true }
        );
        res.json(order);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getOrderTracking = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id)
            .select('status deliveryLocation estimatedDeliveryTime');
        res.json(order);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getDeliveryPath = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .select('currentLocation estimatedDeliveryTime');
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: 'TRACKING_FETCH_FAILED' });
  }
};