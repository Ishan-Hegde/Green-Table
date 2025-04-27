let ioInstance;

const initializeSocket = (io) => {
  ioInstance = io;
  
  io.on('connection', (socket) => {
    console.log(`Socket connected: ${socket.id}`);
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