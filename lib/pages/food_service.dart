import 'dart:convert';
import 'package:green_table/config.dart';
import 'package:http/http.dart' as http;

class FoodService {
  // Replace with the actual URL of your backend API
  final String baseUrl = Config.baseUrl;

  Future<List<dynamic>> getFoodListings(String restaurantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/food/$restaurantId'), // Include the restaurantId in the endpoint URL
      headers: {
        'Content-Type': 'application/json',
        // Add any authentication token if needed, e.g., 'Authorization': 'Bearer <token>'
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the food listings
      List<dynamic> foodListings = json.decode(response.body);
      return foodListings;
    } else {
      // If the server returns an error response, throw an exception
      throw Exception('Failed to load food listings');
    }
  }
}
