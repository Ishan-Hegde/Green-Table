const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const { body, param, validationResult } = require('express-validator');

// Add auth middleware import
const { auth } = require('../middleware/auth');

router.post('/add', 
  [
    body('restaurantId').isMongoId(),
    body('foodName').trim().notEmpty(),
    body('price').isFloat({ gt: 0 }),
    body('quantity').isInt({ min: 1 }),
    body('dietaryType').isIn(['vegetarian', 'non-vegetarian', 'vegan', 'jain']),
    body('servesPeople').isInt({ min: 1 }),
    body('foodCategory').notEmpty(),
    body('ingredients').isArray({ min: 1 }),
    body('timeOfCooking').isISO8601(),
    body('expiryDate').isISO8601()
  ],
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
  foodController.createFoodItem
);
router.post('/claim', 
  auth,
  body('foodId').isMongoId(),
  body('quantity').isInt({ min: 1 }),
  foodController.claimFoodItem
);
router.get('/available', foodController.getLiveFoodItems);
router.get('/:restaurantId', 
  auth,
  param('restaurantId').isMongoId(),
  foodController.getFoodItemsByRestaurant
);

module.exports = router;
