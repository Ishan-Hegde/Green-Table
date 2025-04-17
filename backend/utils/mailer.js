const nodemailer = require('nodemailer');
const OTP = require('../models/OTP');

const transporter = nodemailer.createTransport({
    service: 'Gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

const sendOTP = async (email, otp) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Your OTP Code',
        text: `Your OTP code is ${otp}. It will expire in 5 minutes.`,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log('OTP sent successfully');
    } catch (error) {
        console.error('Error sending OTP:', error);
    }
};

const generateOTP = () => Math.floor(100000 + Math.random() * 900000);

const verifyOTP = async (email, otp) => {
  const record = await OTP.findOne({ email, otp }).exec();
  return !!record;
};

module.exports = { sendOTP, generateOTP, verifyOTP };
