import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

class AuthAPI {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    return {
      'success': response.statusCode == 201,
      'data': jsonDecode(response.body)
    };
  }

  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('https://green-table-ni1h.onrender.com/api/auth/verify-otp'),
      body: jsonEncode({'email': email, 'otp': otp}),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resendOTP(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://green-table-ni1h.onrender.com/api/auth/register'),
      body: jsonEncode({
        'email': email,
        'password': password,
        'resend': true
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }
}