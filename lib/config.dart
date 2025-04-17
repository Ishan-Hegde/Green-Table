// lib/config.dart

class Config {
  // Base URL for the backend API
  static const String baseUrl = 'https://green-table-backend.onrender.com/api';

  // Auth endpoints
  static String getLoginUrl(bool isConsumerSelected) {
    return '$baseUrl/auth/login';
  }

  // Food endpoints
  static const String foodListings = '$baseUrl/food/live';
  static const String addFoodListing = '$baseUrl/food/add';

  // Restaurant endpoints
  static const String restaurantDetails = '$baseUrl/restaurant';

  // Consumer endpoints
  static const String consumerDetails = '$baseUrl/consumer';

  // Location endpoints
  static const String locationUpdate = '$baseUrl/location/update';
  static const String getLocation = '$baseUrl/location';
}
