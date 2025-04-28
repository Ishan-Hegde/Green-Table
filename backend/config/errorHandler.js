module.exports = (err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'SERVER_ERROR',
    message: process.env.NODE_ENV === 'production' 
      ? 'Internal server error' 
      : err.message
  });
};