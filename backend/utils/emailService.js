const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    },
    tls: {
        rejectUnauthorized: false
    }
});

const sendEmail = async ({to, subject, text, html}) => {
    try {
        const info = await transporter.sendMail({
            from: `"Green Table" <${process.env.EMAIL_USER}>`,
            to,
            subject,
            text,
            html
        });
        console.log('Email sent:', info.messageId);
        return true;
    } catch (error) {
        console.error("Email send error:", error);
        return false;
    }
};

const sendOTP = async (email, otp) => {
    return sendEmail({
        to: email,
        subject: 'Your Green Table Verification Code',
        html: `<div>
            <h2>Account Verification</h2>
            <p>Your OTP code is: <strong>${otp}</strong></p>
            <p>This code expires in 5 minutes.</p>
        </div>`
    });
};

module.exports = {
    sendEmail,
    sendOTP
};