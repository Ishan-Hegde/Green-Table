// lib/config.dart

class Config {
  // Replace with your Render app URL
  static const String baseUrl = 'https://your-app-name.onrender.com/api/auth/';

  static String getLoginUrl(bool isConsumerSelected) {
    return '${baseUrl}login'; // Assuming the endpoint for login is the same for both consumer and restaurant logins.
  }
}
