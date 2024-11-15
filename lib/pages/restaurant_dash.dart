// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, unused_import, library_prefixes, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'login_page.dart'; // Import your LoginPage
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RestaurantApp extends StatefulWidget {
  const RestaurantApp({super.key});

  @override
  _RestaurantAppState createState() => _RestaurantAppState();
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RestaurantApp(),
  ));
}

class _RestaurantAppState extends State<RestaurantApp> {
  int _selectedIndex = 0;
  bool isDarkMode = false;
  Color primaryGreen = Colors.green[700]!;

  final List<Widget> _widgetOptions = <Widget>[
    AvailablePickupsPage(),
    PastOrdersPage(),
    OrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleDarkMode() => setState(() => isDarkMode = !isDarkMode);

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00B200),
          shadowColor: Colors.blueAccent,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00B200),
          shadowColor: Colors.blueAccent,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FooD FOR GooD'),
          centerTitle: true,
          shadowColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Add notification logic here
              },
            ),
          ],
        ),
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: 'Available Pickups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Past Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Orders',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor:
              isDarkMode ? Colors.greenAccent : const Color(0xFF00B200),
          selectedFontSize: 16,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          selectedIconTheme: const IconThemeData(size: 26),
          onTap: _onItemTapped,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              const SizedBox(height: 70),
              ListTile(
                leading: Icon(Icons.dark_mode,
                    color: isDarkMode
                        ? Colors.yellowAccent
                        : Colors.lightBlueAccent),
                title: const Text('Dark Mode'),
                trailing: Switch(
                    value: isDarkMode, onChanged: (value) => _toggleDarkMode()),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out'),
                onTap: _showSignOutConfirmation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page to show available pickups
class AvailablePickupsPage extends StatelessWidget {
  final List<Map<String, String>> availablePickups = [
    {'name': 'Taj Lands End', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'Balaji', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'Alibaug', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'The Great Indian Dhaba', 'time': '2:30 PM', 'items': '10 items'},
    {'name': "McDonald's", 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'Food Factory', 'time': '2:30 PM', 'items': '10 items'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: availablePickups.length,
      itemBuilder: (context, index) {
        final pickup = availablePickups[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 4,
          child: ListTile(
            title: Text(pickup['name']!),
            subtitle: Text('${pickup['time']} - ${pickup['items']}'),
          ),
        );
      },
    );
  }
}

// Page to show past orders with download invoice option.
class PastOrdersPage extends StatelessWidget {
  final List<Map<String, String>> pastOrders = List.generate(5, (index) {
    return {
      'number': (100000 + Random().nextInt(900000)).toString(),
      'date': '2023-09-${index + 1}',
      'items': index % 2 == 0 ? 'Pizza, Burger' : 'Sushi, Taco',
      'status': 'Completed',
    };
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pastOrders.length,
      itemBuilder: (context, index) {
        final order = pastOrders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 4,
          child: ListTile(
            title: Text('Order No.: ${order['number']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${order['date']}'),
                Text('Items: ${order['items']}'),
                Text('Status: ${order['status']}'),
              ],
            ),
            trailing: Icon(
              Icons.check_circle_outline,
              color: (order['status'] == 'Completed'
                  ? const Color(0xFF00B200)
                  : Colors.red),
            ),
            onTap: () => _showOrderDetails(context, order),
          ),
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, String> order) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Order No.: ${order['number']}'),
              Text('Date: ${order['date']}'),
              Text('Items: ${order['items']}'),
              Text('Status: ${order['status']}'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _downloadInvoice(context, order);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download Invoice'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _downloadInvoice(BuildContext context, Map<String, String> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice downloaded successfully!')),
    );
  }
}

// Page for restaurant to manage orders
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String userEmail = '';
  String restaurantId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details (email and restaurantId) from SharedPreferences or API
  Future<void> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserEmail = prefs.getString('userEmail');

    if (storedUserEmail != null) {
      // Fetch restaurant data based on the stored email
      final response = await http.get(
        Uri.parse(
            'https://green-table-backend.onrender.com/api/restaurant/all'), // Get all restaurants
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON data
        final List<dynamic> restaurants = jsonDecode(response.body);

        // Find the restaurant corresponding to the stored email
        for (var restaurant in restaurants) {
          if (restaurant['email'] == storedUserEmail) {
            setState(() {
              userEmail = storedUserEmail;
              restaurantId = restaurant['_id']; // Get the restaurant ID
            });
            break;
          }
        }
      } else {
        // Handle any errors that might occur while fetching data
        setState(() {
          userEmail = storedUserEmail;
          restaurantId = 'Error fetching restaurant ID';
        });
      }
    } else {
      // If no email is found in SharedPreferences
      setState(() {
        userEmail = 'Unknown User';
        restaurantId = 'Unknown Restaurant';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders for $restaurantId")),
      body: Center(
        child: Text(
          'Logged-in user email: $userEmail\nRestaurant ID: $restaurantId',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
