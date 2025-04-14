const express = require('express');
const { updateLocation, getUserLocation } = require('../controllers/locationController');

const router = express.Router();

router.post('/update', updateLocation);
router.get('/:userId', getUserLocation);

module.exports = router;
