import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 1),
                // Title
                const Text(
                  'Log In or Sign Up',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Logo
                const Icon(
                  Icons.restaurant_rounded,
                  size: 72,
                  color: Color.fromARGB(255, 63, 161, 63),
                ),
                const SizedBox(height: 40),

                // Email TextField
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password TextField
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Social Media Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Google sign-in logic
                      },
                      child: Image.asset(
                        'assets/images/google_logo.png',
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        // Apple sign-in logic
                      },
                      child: Image.asset(
                        'assets/images/apple_logo.png',
                        height: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Continue Button
                ElevatedButton(
                  onPressed: () {
                    // Sign in logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Terms and Privacy Policy
                Text(
                  'By continuing, you agree to Green Table\'s Terms of Service and acknowledge Noble\'s Privacy Policy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
