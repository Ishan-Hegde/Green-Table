const Order = require('../models/Order');
const { emitToRoom } = require('../utils/socketManager');
const Restaurant = require('../models/restaurantModel');
const Consumer = require('../models/Consumer');
const { calculateETA } = require('../utils/mapService');

exports.createOrder = async (req, res) => {
  try {
    const { consumerId, restaurantId, items } = req.body;
    
    const newOrder = new Order({
      consumer: consumerId,
      restaurant: restaurantId,
      items,
      status: 'pending',
      location: req.user.location // Assuming location is stored in user
    });

    await newOrder.save();
    emitToRoom(restaurantId.toString(), 'newOrder', newOrder);
    
    res.status(201).json(newOrder);
  } catch (error) {
    console.error('Order creation error:', error);
    res.status(500).json({ error: 'Failed to create order' });
  }
};

exports.assignDeliveryPartner = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { deliveryPartnerId } = req.body;

    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ error: 'Order not found' });

    const restaurant = await Restaurant.findById(order.restaurant);
    const consumer = await Consumer.findById(order.consumer);
    
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

exports.updateOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status, location } = req.body;
    
    const order = await Order.findByIdAndUpdate(
      orderId,
      { status, $push: { trackingHistory: { status, location } } },
      { new: true }
    );

    emitToRoom(orderId, 'statusUpdate', order);
    res.status(200).json(order);
  } catch (error) {
    console.error('Order update error:', error);
    res.status(500).json({ error: 'Failed to update order' });
  }
};

exports.assignDeliveryPartner = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { deliveryPartnerId } = req.body;

    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ error: 'Order not found' });

    const restaurant = await Restaurant.findById(order.restaurant);
    const consumer = await Consumer.findById(order.consumer);
    
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