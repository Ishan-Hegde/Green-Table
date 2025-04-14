const Location = require('../models/Location');

// Update User Location
exports.updateLocation = async (req, res) => {
    try {
        const { userId, latitude, longitude } = req.body;

        let location = await Location.findOneAndUpdate({ userId }, { latitude, longitude, updatedAt: Date.now() }, { new: true, upsert: true });

        res.json({ message: 'Location updated successfully', location });
    } catch (error) {
        res.status(500).json({ message: 'Error updating location', error });
    }
};

// Get User Location
exports.getUserLocation = async (req, res) => {
    try {
        const { userId } = req.params;
        const location = await Location.findOne({ userId });

        if (!location) return res.status(404).json({ message: 'Location not found' });

        res.json(location);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching location', error });
    }
};
