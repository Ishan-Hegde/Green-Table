const express = require('express');
const authRoutes = require('./authRoutes');
const foodRoutes = require('./foodRoutes');
const locationRoutes = require('./locationRoutes'); // Remove this line
const orderRoutes = require('./orderRoutes');

const app = express();
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/location', locationRoutes); // Remove this line
app.use('/api/orders', orderRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
