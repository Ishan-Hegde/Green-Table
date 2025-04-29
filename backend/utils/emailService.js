const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Add error handling
const sendOTP = async (email, otp) => {
    try {
        await transporter.sendMail({
            from: `"Green Table" <${process.env.EMAIL_USER}>`,
            to: email,
            subject: 'Your Verification Code',
            text: `Your OTP is: ${otp}`,
            html: `<b>${otp}</b>`
        });
        return true;
    } catch (error) {
        console.error('Email send error:', error);
        return false;
    }
};

module.exports = { sendOTP };