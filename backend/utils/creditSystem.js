const calculateCreditScore = (restaurant) => {
  const completedOrders = restaurant.completedOrders || 0;
  const averageRating = restaurant.averageRating || 0;
  
  let score = completedOrders * 2;
  score += averageRating * 10;
  
  // Quarterly bonus
  const currentQuarterOrders = restaurant.quarterlyOrders || 0;
  score += currentQuarterOrders * 5;

  return Math.min(Math.max(score, 0), 100); // Keep between 0-100
};

module.exports = { calculateCreditScore };