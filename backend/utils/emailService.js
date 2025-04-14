const nodemailer = require('nodemailer');
const bcrypt = require('bcryptjs');

const sendEmail = async (userEmail, hashedPassword, subject, text) => {
    // In a real scenario, we can't decrypt bcrypt hashes. Instead, we should use OAuth for email authentication.
    // This is a simplified example assuming we store an unhashed version securely.
    
    const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: userEmail,
            pass: hashedPassword // WARNING: Bcrypt is not reversible, we need another secure way to store credentials
        }
    });

    const mailOptions = {
        from: userEmail,
        to: userEmail,
        subject,
        text
    };

    await transporter.sendMail(mailOptions);
};

module.exports = sendEmail;
