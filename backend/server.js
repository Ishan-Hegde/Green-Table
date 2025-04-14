//Server.js

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const authRoutes = require('./routes/authRoutes');
const kycRoutes = require('./routes/kycRoutes');  

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); // Needed for form-data text fields

mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.error('MongoDB connection error:', err));


app.use('/api/auth', authRoutes);
app.use('/api/kyc', kycRoutes);

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
