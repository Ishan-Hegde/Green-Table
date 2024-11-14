import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodService {
  final String baseUrl;

  FoodService(this.baseUrl);

  Future<List<Map<String, dynamic>>> getFoodListings(
      String restaurantId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/food/$restaurantId'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load food listings');
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      throw Exception('Failed to load food listings');
    }
  }
}
