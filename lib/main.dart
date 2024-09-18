import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/restaurant_food_list_screen.dart';
import 'screens/consumer_food_list_screen.dart';
import 'screens/order_summary_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Table',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins', // Assuming you're using Poppins font
      ),
      // Set the initial route to the splash screen
      initialRoute: '/',
      // Define routes to navigate between screens
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/restaurant': (context) => const RestaurantFoodListScreen(),
        '/consumer': (context) => const ConsumerFoodListScreen(),
        '/order-summary': (context) => const OrderSummaryScreen(),
      },
    );
  }
}
