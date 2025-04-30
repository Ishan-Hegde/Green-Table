let ioInstance;

const initializeSocket = (io) => {
  ioInstance = io;
  
  // Add to existing connection handler
  io.on('connection', (socket) => {
    socket.on('join-restaurant', (restaurantId) => {
      socket.join(`restaurant_${restaurantId}`);
    });
  
    socket.on('order-status-update', (orderId, status) => {
      io.to(`order_${orderId}`).emit('status-update', status);
    });
  });
};

const emitToRoom = (room, event, data) => {
  if (ioInstance) {
    ioInstance.to(room).emit(event, data);
  }
};

module.exports = {
  initializeSocket,
  emitToRoom
};