const express = require('express');
const { updateLocation, getUserLocation } = require('../controllers/locationController');

const router = express.Router();

router.post('/location/update', updateLocation);
router.get('/location', getUserLocation);

module.exports = router;
