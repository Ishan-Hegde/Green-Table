// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token storage
import 'consumer_dash.dart'; // Assuming your ConsumerApp is in this file
import 'restaurant_dash.dart'; // Import your Restaurant dashboard page
import 'package:green_table/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool isConsumerSelected = true;
  bool _autoFilled = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    
    // Fixed WidgetsBinding callback implementation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _emailController.text = args['email'] ?? '';
          _passwordController.text = args['password'] ?? '';
          _autoFilled = true;
        });
      }
    });
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _autoFilled = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _useSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _autoFilled = true;
    });
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // Navigate to respective dashboard based on selection if already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isConsumerSelected ? const ConsumerApp() : const RestaurantApp(),
        ),
      );
    }
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true; // Show loading indicator while making the request
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill out all fields.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(Config.getLoginUrl(isConsumerSelected)),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = jsonDecode(response.body);
        String token = responseJson['token'];

        // Save token and email to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userEmail', _emailController.text);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => isConsumerSelected
                  ? const ConsumerApp()
                  : const RestaurantApp(),
            ),
          );
        }

      } else {
        final responseJson = jsonDecode(response.body);
        _showErrorDialog(responseJson['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showErrorDialog(
          'Failed to connect to the server. Please try again later. Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'Welcome to Green Table!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Icon(
                    Icons.restaurant_rounded,
                    size: 64,
                    color: Color(0xFF00B200),
                  ),
                  const SizedBox(height: 35),

                  // Toggle Buttons for Consumer and Restaurant
                  ToggleButtons(
                    isSelected: [isConsumerSelected, !isConsumerSelected],
                    onPressed: (int index) {
                      setState(() {
                        isConsumerSelected =
                            index == 0; // Update selection based on index
                      });
                    },
                    color: Colors.black, // Text color when not selected
                    selectedColor: Colors.white, // Text color when selected
                    fillColor: const Color(
                        0xFF00B200), // Background color when selected
                    borderColor: const Color(
                        0xFF00B200), // Border color for unselected buttons
                    selectedBorderColor: const Color(
                        0xFF00B200), // Border color for selected buttons
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10.0)), // Rounded corners
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Consumer'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Restaurant'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF00B200)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    enabled: !_autoFilled, // Disable if auto-filled
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF00B200)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    enabled: !_autoFilled, // Disable if auto-filled
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => loginUser(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 120.0, vertical: 17),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Continue',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  // TextButton(
                  //   onPressed: _useSavedCredentials,
                  //   child: Text(
                  //     'Use Saved Credentials',
                  //     style: TextStyle(
                  //       color: Colors.blue[700],
                  //       fontSize: 14,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                        "By continuing, you agree to Green Table's Terms of Service and acknowledge Noble's Privacy Policy.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
