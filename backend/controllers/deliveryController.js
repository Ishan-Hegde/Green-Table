exports.updateDeliveryLocation = async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(
      req.params.orderId,
      { 
        deliveryLocation: {
          type: 'Point',
          coordinates: [req.body.longitude, req.body.latitude]
        }
      },
      { new: true }
    );
    
    emitToRoom(order.id, 'location-update', order.deliveryLocation);
    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ error: 'LOCATION_UPDATE_FAILED' });
  }
};