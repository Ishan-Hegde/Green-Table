const Cart = require('../models/Cart');
const Order = require('../models/Order');
const mongoose = require('mongoose');

exports.addToCart = async (req, res) => {
    try {
        const { foodItemId, quantity, restaurantId } = req.body;
        
        let cart = await Cart.findOne({ 
            consumer: req.user.id, 
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
            existingItem.quantity += quantity;
        } else {
            cart.items.push({
                foodItem: foodItemId,
                quantity: quantity
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
    try {
        const cart = await Cart.findOne({ consumer: req.user.id })
            .populate('restaurant');
            
        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ error: 'Cart is empty' });
        }

        // Process order creation here (you already have this logic in OrderController)
        // Then clear the cart
        await Cart.deleteOne({ _id: cart._id });
        
        res.status(200).json({ message: 'Checkout successful' });
    } catch (error) {
        res.status(500).json({ error: 'Checkout failed' });
    }
};