const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

module.exports = {
  sendOrderUpdate: async (user, order) => {
    const msg = {
      to: user.email,
      from: 'notifications@greentable.com',
      subject: `Order ${order.status}`,
      text: `Your order #${order._id} is now ${order.status}`
    };
    await sgMail.send(msg);
  },
  
  sendSMS: async (phone, message) => {
    // Twilio integration here
  }
};