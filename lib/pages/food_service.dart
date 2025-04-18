import 'dart:convert';
import 'package:green_table/config.dart';
import 'package:http/http.dart' as http;

class FoodService {
  // Replace with the actual URL of your backend API
  final String baseUrl = Config.baseUrl;

  Future<List<dynamic>> getFoodListings(String restaurantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/food/$restaurantId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> foodListings = json.decode(response.body);
      return foodListings;
    } else {
      throw Exception('Failed to load food listings for restaurant $restaurantId. Status: ${response.statusCode} Body: ${response.body}');
    }
  }
}