const fetch = require('node-fetch');
require('dotenv').config();

const calculateETA = async (origin, destination) => {
  try {
    const apiKey = process.env.GMAPS_API_KEY;
    const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${origin[0]},${origin[1]}&destination=${destination[0]},${destination[1]}&key=${apiKey}`;
    
    const response = await fetch(url);
    const data = await response.json();

    if (data.routes[0]?.legs[0]?.duration?.value) {
      return data.routes[0].legs[0].duration.value;
    }
    throw new Error('No route found');
  } catch (error) {
    console.error('ETA calculation error:', error);
    throw new Error('Failed to calculate ETA');
  }
};

module.exports = { calculateETA };