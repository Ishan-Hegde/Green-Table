const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/authRoutes');
const consumerRoutes = require('./routes/consumerRoutes');
const restaurantRoutes = require('./routes/restaurantRoutes');
const orderRoutes = require('./routes/orderRoutes');
const foodRoutes = require('./routes/foodRoutes');
const { initializeSocket } = require('./utils/socketManager'); // Remove this line
require('dotenv').config();  // This should be at the very top
const config = require('./config/config');
const app = express();
const cookieParser = require('cookie-parser');
app.use(cookieParser());

// Middleware
app.use(express.json());

// Database connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/consumer', consumerRoutes);
app.use('/api/restaurant', restaurantRoutes);

// Add after other route declarations
app.use('/api/orders', orderRoutes);

// Mount food routes under /api prefix
app.use('/api/food', foodRoutes);

// Error handling middleware (keep existing)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

// Home route
app.get('/', (req, res) => {
  res.send('Welcome to Green Table Backend');
});

const PORT = process.env.PORT || 5000;
// Add at top
const { Server } = require('socket.io');

// Add after app initialization
const server = require('http').createServer(app);
const io = require('socket.io')(server, {
  cors: {
    origin: "http://localhost:5000", // Update with your client origin
    methods: ["GET", "POST"],
    credentials: true
  },
  transports: ['websocket', 'polling']
});

// Remove duplicate middleware
app.use((req, res, next) => {
  req.io = io;
  next();
});

// Remove the duplicate initializeSocket call at the bottom
// server.listen(...) remains as the last line
app.set('io', io); 

// Add before routes
app.use((req, res, next) => {
  req.io = io;
  next();
});

// Add socket connection handling
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  
  socket.on('join-room', (roomId) => {
    socket.join(roomId);
    console.log(`Socket ${socket.id} joined room ${roomId}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));

initializeSocket(io);
