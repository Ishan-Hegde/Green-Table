//Server.js

const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

// Load environment variables
dotenv.config();

// Create Express app
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL,
    methods: ['GET', 'POST']
  }
});

const authRoutes = require('./routes/authRoutes');
const kycRoutes = require('./routes/kycRoutes');
const foodRoutes = require('./routes/foodRoutes');
const restaurantRoutes = require('./routes/restaurantRoutes');
const consumerRoutes = require('./routes/consumer');
const locationRoutes = require('./routes/locationRoutes');

const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // Needed for form-data text fields

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.error('MongoDB connection error:', err));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/kyc', kycRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/restaurant', restaurantRoutes);
app.use('/api/consumer', consumerRoutes);
app.use('/api/location', locationRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

// WebSocket connection handler
io.on('connection', (socket) => {
  console.log('New client connected:', socket.id);
  
  socket.on('joinOrderRoom', (orderId) => {
    socket.join(orderId);
    console.log(`Socket ${socket.id} joined order room ${orderId}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
