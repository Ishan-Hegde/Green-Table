require('dotenv').config();

module.exports = {
    JWT_SECRET: process.env.JWT_SECRET,
    OTP_EXPIRY: 5 * 60 * 1000, // 5 minutes
    KYC_REQUIRED_FIELDS: ['restaurantName', 'ownerName', 'address', 'licenseNumber'],
};
