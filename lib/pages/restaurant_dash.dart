// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token storage
import 'login_page.dart'; // Import your LoginPage
import 'dart:math';

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
  int _selectedIndex = 0; // Track the selected index for bottom navigation
  bool isDarkMode = false; // Track whether dark mode is on or off

  // Define the primary green color used for the app
  Color primaryGreen = Colors.green[700]!;

  // Navigation items
  final List<Widget> _widgetOptions = <Widget>[
    AvailablePickupsPage(),
    PastOrdersPage(),
    OrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  // Toggle dark mode
  void _toggleDarkMode() => setState(() => isDarkMode = !isDarkMode);

  // Sign out function
  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear the token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Show confirmation dialog for sign out
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
        body: Column(
          children: [
            Expanded(
              child: _widgetOptions[_selectedIndex],
            ),
          ],
        ),
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
                onTap:
                    _showSignOutConfirmation, // Show confirmation dialog on tap
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
      'number': (100000 + Random().nextInt(900000))
          .toString(), // Generate a random order number.
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: const Color(0xFF00B200),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _downloadInvoice(BuildContext context, Map<String, String> order) {
    Navigator.pop(context); // Close the bottom sheet.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Invoice for order No. ${order['number']} is being downloaded."),
      ),
    );
  }
}

// Placeholder for OrdersPage
class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Orders will be displayed here.'));
  }
}
