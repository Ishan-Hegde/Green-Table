// New loyalty endpoints
exports.updateLoyaltyPoints = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $inc: { loyaltyPoints: req.body.points } },
      { new: true }
    );
    res.json({ loyaltyPoints: user.loyaltyPoints });
  } catch (error) {
    res.status(500).json({ error: 'LOYALTY_UPDATE_FAILED' });
  }
};

// Add to verifyDeliveryOTP in OrderController
await User.findByIdAndUpdate(order.consumer, {
  $inc: { loyaltyPoints: Math.floor(order.totalAmount) },
  $addToSet: { orderHistory: order._id }
});

exports.updateProfile = async (req, res) => {
  try {
    const updates = Object.keys(req.body);
    const allowedUpdates = ['name', 'phone', 'address'];
    const isValid = updates.every(update => allowedUpdates.includes(update));
    
    if (!isValid) return res.status(400).json({ error: 'INVALID_UPDATES' });
    
    const user = await User.findByIdAndUpdate(req.user.id, req.body, {
      new: true,
      runValidators: true
    });
    
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const isMatch = await bcrypt.compare(req.body.oldPassword, user.password);
    
    if (!isMatch) return res.status(401).json({ error: 'INVALID_CREDENTIALS' });
    
    user.password = req.body.newPassword;
    await user.save();
    
    res.json({ message: 'Password updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'PASSWORD_UPDATE_FAILED' });
  }
};

exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .select('-password -__v');
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: 'PROFILE_FETCH_FAILED' });
  }
};