# Testing Guide

## Backend Testing

### API Testing with Postman
1. Import the Postman collection from `postman_collection.json`
2. Set up environment variables:
   - `BASE_URL`: http://localhost:5000

### Available Endpoints

#### Authentication
- POST `/api/auth/register`
- POST `/api/auth/login`

#### KYC
- POST `/api/kyc/submit`
- GET `/api/kyc/status/:userId`

#### Food
- GET `/api/food/all`
- POST `/api/food/create`

#### Restaurant
- GET `/api/restaurant/all`
- GET `/api/restaurant/:id`

#### Consumer
- GET `/api/consumer/all`

#### Location
- POST `/api/location/add`
- GET `/api/location/nearby`

### Running Tests
1. Start MongoDB server
2. Run `npm install` to install dependencies
3. Create `.env` file with required environment variables
4. Start the server: `npm start`
5. Run tests using Postman collection

## Frontend Testing

### Widget Tests
1. Navigate to `test/` directory
2. Run `flutter test`

### Integration Tests
1. Navigate to `integration_test/` directory
2. Run `flutter test integration_test`