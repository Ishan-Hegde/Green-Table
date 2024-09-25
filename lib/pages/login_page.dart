import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            // Added to prevent overflow on smaller screens
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  // Title
                  const Text(
                    'Log In or Sign Up',
                    style: TextStyle(
                      fontSize: 26, // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25), // Increased spacing

                  // Logo
                  const Icon(
                    Icons.restaurant_rounded,
                    size: 64, // Slightly reduced icon size for better spacing
                    color: Color.fromARGB(255, 63, 161, 63),
                  ),
                  const SizedBox(height: 35), // Reduced space

                  // Toggle buttons for Restaurant and Consumer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Restaurant',
                            style: TextStyle(
                              fontSize: 16, // Adjusted text size
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 2,
                            width: 80, // Adjusted width for better fit
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(width: 20), // Reduced spacing
                      Column(
                        children: [
                          const Text(
                            'Consumer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 2,
                            width: 80, // Adjusted width for better fit
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40), // Reduced height to adjust layout

                  // Email TextField
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16), // Adjusted padding for better UX
                    ),
                  ),
                  const SizedBox(height: 15), // Adjusted spacing

                  // Password TextField
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16), // Adjusted padding for consistency
                    ),
                  ),
                  const SizedBox(height: 35), // Adjusted spacing

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
                          height: 36, // Adjusted size for better alignment
                        ),
                      ),
                      const SizedBox(width: 25), // Reduced spacing
                      GestureDetector(
                        onTap: () {
                          // Apple sign-in logic
                        },
                        child: Image.asset(
                          'assets/images/apple_logo.png',
                          height: 36, // Adjusted size for consistency
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25), // Increased spacing for clarity

                  // Continue Button
                  ElevatedButton(
                    onPressed: () {
                      // Sign in logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 125.0,
                          vertical: 16), // Adjusted button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16, // Adjusted font size for consistency
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Adjusted spacing

                  // Terms and Privacy Policy
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Padding for long text
                    child: Text(
                      'By continuing, you agree to Green Table\'s Terms of Service and acknowledge Noble\'s Privacy Policy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10), // Slight padding for readability
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
