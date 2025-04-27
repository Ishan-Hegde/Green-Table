import 'dart:convert';
import 'package:green_table/config.dart';
import 'package:http/http.dart' as http;
import 'package:green_table/models/food_item.dart';

class FoodListingService {
  static const String baseUrl = Config.baseUrl;

  // Get all food listings
  Future<List<FoodItem>> getAllFoodListings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/food/live'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FoodItem.fromJson(json)).toList();
      }
      throw Exception('Failed to load food listings');
    } catch (e) {
      throw Exception('Error fetching food listings: $e');
    }
  }

  // Get food listings by restaurant
  Future<List<FoodItem>> getFoodListingsByRestaurant(String restaurantId) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/food/$restaurantId'), // Corrected endpoint
        headers: {'Content-Type': 'application/json'}
      );
      
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((i) => FoodItem.fromJson(i))
            .toList();
      }
      throw Exception('Failed with status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Food fetch error: $e');
    }
  }

  // Create new food listing
  Future<FoodItem> createFoodListing(FoodItem foodItem) async {
    try {
      final response = await http.post(
        Uri.parse(Config.addFoodListing),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(foodItem.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return FoodItem.fromJson(responseData['data']);
      }
      throw Exception('Failed to create food listing');
    } catch (e) {
      throw Exception('Error creating food listing: $e');
    }
  }

  // Update food listing
  Future<FoodItem> updateFoodListing(String id, FoodItem foodItem) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/food/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(foodItem.toJson()),
      );
      if (response.statusCode == 200) {
        return FoodItem.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to update food listing');
    } catch (e) {
      throw Exception('Error updating food listing: $e');
    }
  }

  // Delete food listing
  Future<void> deleteFoodListing(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/food/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete food listing');
      }
    } catch (e) {
      throw Exception('Error deleting food listing: $e');
    }
  }

  // Search food listings
  Future<List<FoodItem>> searchFoodListings(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food/search?q=$query'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FoodItem.fromJson(json)).toList();
      }
      throw Exception('Failed to search food listings');
    } catch (e) {
      throw Exception('Error searching food listings: $e');
    }
  }

  Future<Map<String, dynamic>> getFoodItemWithOrders(String foodId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/food/$foodId/orders'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load food item orders');
    } catch (e) {
      throw Exception('Food order tracking error: $e');
    }
  }
}