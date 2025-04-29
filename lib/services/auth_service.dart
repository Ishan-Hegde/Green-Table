import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://green-table-ni1h.onrender.com/api/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userId', data['user']['_id']);
      await prefs.setString('kycStatus', data['user']['kycStatus']);
      await prefs.setString('role', data['user']['role']);
      return data['user'];
    }
    throw Exception('Failed to login');
  }

  static Future<void> uploadKYCDocuments({
    required List<File> documents,
    required String docType,
    required String userId,
  }) async {
    final uri = Uri.parse('https://green-table-ni1h.onrender.com/api/kyc/upload');
    final request = http.MultipartRequest('POST', uri);
    
    for (var doc in documents) {
      request.files.add(await http.MultipartFile.fromPath('documents', doc.path));
    }
    
    request.fields['docType'] = docType;
    request.fields['userId'] = userId;
    
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload documents');
    }
  }

  static Future<String?> getKYCStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('kycStatus');
  }
}