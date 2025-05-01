const Cart = require('../models/Cart');
const Order = require('../models/Order');
const mongoose = require('mongoose');
const Food = require('../models/Food');

exports.addToCart = async (req, res) => {
    try {
        const { foodItemId, restaurantId } = req.body;
        const quantity = parseInt(req.body.quantity, 10); // Convert to number

        if (isNaN(quantity) || quantity < 1) {
            return res.status(400).json({
                error: 'INVALID_QUANTITY',
                message: 'Quantity must be a positive number'
            });
        }
        
        // Validate restaurant match
        const existingCart = await Cart.findOne({ consumer: req.user.id });
        if (existingCart && !existingCart.restaurant.equals(restaurantId)) {
            return res.status(400).json({
                error: 'RESTAURANT_MISMATCH',
                message: 'Cannot add items from multiple restaurants'
            });
        }

        // Food stock check would go here (needs implementation)
        // Check food item stock
        const foodItem = await Food.findById(foodItemId);
        if (!foodItem) {
            return res.status(404).json({ error: 'FOOD_NOT_FOUND' });
        }
        else if (foodItem.quantity < quantity) {
            return res.status(400).json({ 
                error: 'INSUFFICIENT_STOCK',
                available: foodItem.quantity
            });
        }

        // Add quantity validation
        if (quantity < 1) {
            return res.status(400).json({
                error: 'INVALID_QUANTITY',
                message: 'Quantity must be at least 1'
            });
        }
        // In addToCart function:
        let cart = await Cart.findOne({ 
            consumer: req.user.id,  // MUST match logged-in user ID
            restaurant: restaurantId 
        });

        if (!cart) {
            cart = new Cart({
                consumer: req.user.id,
                restaurant: restaurantId,
                items: []
            });
        }

        const existingItem = cart.items.find(item => 
            item.foodItem.equals(new mongoose.Types.ObjectId(foodItemId)));

        if (existingItem) {
            existingItem.quantity += quantity; // Now working with numbers
        } else {
            cart.items.push({
                foodItem: foodItemId,
                quantity: quantity // Store as number
            });
        }

        await cart.save();
        res.status(200).json(cart);
    } catch (error) {
        res.status(500).json({ error: 'Failed to add to cart' });
    }
};

exports.getCart = async (req, res) => {
    try {
        const cart = await Cart.findOne({ consumer: req.user.id })
            .populate('items.foodItem', 'foodName price');
            
        res.status(200).json(cart || { items: [] });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch cart' });
    }
};

exports.checkoutCart = async (req, res) => {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        
        const cart = await Cart.findOne({ consumer: req.user.id })
            .populate({
                path: 'items.foodItem',
                model: 'Food',
                select: 'price quantity'
            }).session(session);

        if (!cart || cart.items.length === 0) {
            await session.abortTransaction();
            session.endSession();
            return res.status(400).json({ error: 'EMPTY_CART' });
        }

        // Revalidate stock and calculate total
        let totalAmount = 0;
        for (const item of cart.items) {
            const food = await Food.findById(item.foodItem._id).session(session);
            if (food.quantity < item.quantity) {
                await session.abortTransaction();
                return res.status(400).json({
                    error: 'INSUFFICIENT_STOCK',
                    item: food.foodName,
                    available: food.quantity
                });
            }
            food.quantity -= item.quantity;
            await food.save({ session });
            totalAmount += food.price * item.quantity;
        }

        // Create order with OTP
        const order = await Order.create([{
            consumer: req.user.id,
            restaurant: cart.restaurant,
            items: cart.items.map(item => ({
                foodItem: item.foodItem._id,
                quantity: item.quantity
            })),
            totalAmount,
            deliveryOTP: Math.floor(100000 + Math.random() * 900000).toString(),
            status: 'pending'
        }], { session });

        await Cart.deleteOne({ _id: cart._id }).session(session);
        await session.commitTransaction();
        session.endSession();
        
        // Socket.io notification
        const io = req.app.get('io');
        io.to(`restaurant_${cart.restaurant.toString()}`).emit('new-order', order[0]);

        res.status(200).json({
            message: 'Checkout successful',
            orderId: order[0]._id,
            otp: order[0].deliveryOTP,
            total: order[0].totalAmount
        });

    } catch (error) {
        if (session.inTransaction()) {
            await session.abortTransaction();
        }
        session.endSession();
        console.error('Checkout error:', error);
        res.status(500).json({ 
            error: 'CHECKOUT_FAILED',
            message: error.message 
        });
    }
};