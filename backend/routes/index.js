const express = require('express');
const authRoutes = require('./authRoutes');
const orderRoutes = require('./orderRoutes');

const app = express();
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/api/orders', orderRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
