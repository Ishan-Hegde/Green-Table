import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_table/models/food_item.dart';

class OrderService {
  static const String baseUrl = 'https://green-table-ni1h.onrender.com/api';

  Future<void> createOrder(FoodItem item, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'foodItemId': item.id,
          'quantity': quantity,
          'status': 'pending'
        }),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Order creation error: $e');
    }
  }

  Future<String> getOrderStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId/status'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body)['status'];
      }
      throw Exception('Failed to fetch order status');
    } catch (e) {
      throw Exception('Order status error: $e');
    }
  }
}