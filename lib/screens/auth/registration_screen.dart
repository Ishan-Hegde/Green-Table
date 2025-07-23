// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:green_table/api/auth_api.dart';
// ignore: unused_import
import 'package:green_table/pages/login_page.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

// Add this state variable
class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _otpVerified = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
// New controller
  String _selectedRole = 'consumer';

  Future<void> _showOTPDialog() async {
    final otpController = TextEditingController();
    bool _isVerified = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('OTP Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isVerified)
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            if (_isVerified)
              const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 16),
                  Text('OTP Verified Successfully!',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
          ],
        ),
        actions: [
          if (!_isVerified)
            TextButton(
              onPressed: () async {
                try {
                  final response = await AuthAPI.verifyOTP(
                    email: _emailController.text,
                    otp: otpController.text,
                  );

                  if (response['success'] == true) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('username', _emailController.text);
                    await prefs.setString('password', _passwordController.text);

                    setState(() {
                      _isVerified = true;
                      _otpVerified = true;
                    });
                    // Close dialog after 2 seconds
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(response['message'] ??
                              'OTP verification failed')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Verification error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Verify'),
            ),
        ],
      ),
    );
  }

  // Modify the existing _register method
  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await AuthAPI.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
          role: _selectedRole,
        );

        if (response['success']) {
          await _showOTPDialog();
        } else {
          final errorMessage = response['error']?['message'] ??
              response['message'] ??
              'Registration failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                        'Register Here!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Hero(
                        tag: 'app-logo',
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 64,
                          color: Color(0xFF00B200),
                        ),
                      ),
                      const SizedBox(height: 35),
                      ToggleButtons(
                        isSelected: [
                          _selectedRole == 'consumer',
                          _selectedRole == 'restaurant'
                        ],
                        onPressed: (int index) {
                          setState(() {
                            _selectedRole =
                                index == 0 ? 'consumer' : 'restaurant';
                          });
                        },
                        color: Colors.black,
                        selectedColor: Colors.white,
                        fillColor: const Color(0xFF00B200),
                        borderColor: const Color(0xFF00B200),
                        selectedBorderColor: const Color(0xFF00B200),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
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
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                prefixIcon: const Icon(Icons.person,
                                    color: Color(0xFF00B200)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Name is required' : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email,
                                    color: Color(0xFF00B200)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Email is required' : null,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock,
                                    color: Color(0xFF00B200)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Password is required'
                                  : null,
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await AuthAPI.register(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      role: _selectedRole,
                                      phone: _phoneController.text,
                                    );

                                    await _showOTPDialog();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 120.0, vertical: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),

                            // Add this widget above the login button
                            if (_otpVerified)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '✓ OTP Verified! Please login below',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/login'),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 32, 81, 35),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration
                                              .none, // Remove default underline
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          height: 1.5,
                                          width:
                                              34, // Adjust width to match text
                                          color: Colors
                                              .green[900], // Darker underline
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
