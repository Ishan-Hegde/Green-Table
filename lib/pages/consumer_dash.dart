// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class ConsumerApp extends StatefulWidget {
  const ConsumerApp({super.key});

  @override
  _ConsumerAppState createState() => _ConsumerAppState();
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ConsumerApp(),
  ));
}

class _ConsumerAppState extends State<ConsumerApp> {
  int _selectedIndex = 0; // Track the selected index for bottom navigation
  bool isDarkMode = false; // Track whether dark mode is on or off

  // Define the primary green color used for the app
  Color primaryGreen = Colors.green[700]!;

  // Navigation items
  final List<Widget> _widgetOptions = <Widget>[
    FoodForGoodPage(),
    AvailablePickupsPage(),
    PastOrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  // Toggle dark mode
  // Toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode; // Toggle dark mode
    });
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
          title: const Text('FooD for GooD'),
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
              icon: Icon(Icons.restaurant),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: 'Nearby',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.greenAccent,
          selectedFontSize: 16,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          selectedIconTheme: const IconThemeData(size: 26),
          onTap: _onItemTapped,
        ),
        // Drawer
        drawer: Drawer(
          child: Column(
            children: [
              // Dark Mode Switch
              const SizedBox(height: 70),
              ListTile(
                leading: Icon(Icons.dark_mode_outlined,
                    color: isDarkMode
                        ? Colors.yellowAccent
                        : Colors.lightBlueAccent),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    _toggleDarkMode(); // Toggle dark mode
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page 1: Food For Good
class FoodForGoodPage extends StatefulWidget {
  @override
  _FoodForGoodPageState createState() => _FoodForGoodPageState();
}

class _FoodForGoodPageState extends State<FoodForGoodPage> {
  final List<Map<String, String>> _restaurants = [
    {'name': 'Pizzeria', 'items': '10 items'},
    {'name': 'Sushi Place', 'items': '5 items'},
    {'name': 'Burger Joint', 'items': '8 items'},
    {'name': 'BBQ Nation', 'items': '12 items'},
    {'name': 'Taco Stand', 'items': '7 items'},
    {'name': 'Pasta House', 'items': '9 items'},
    {'name': 'Burger King', 'items': '4 items'},
    {'name': 'McDonalds', 'items': '15 items'},
    {'name': 'KFC', 'items': '6 items'},
    {'name': 'TWC', 'items': '1 items'},
    {'name': 'Starbucks', 'items': '9 items'},
    {'name': 'Tunga International', 'items': '3 items'},
  ];

  List<Map<String, String>> _filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = _restaurants; // Initialize with all restaurants
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRestaurants = _restaurants; // Show all when query is empty
      });
    } else {
      setState(() {
        _filteredRestaurants = _restaurants
            .where((restaurant) =>
                restaurant['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: TextField(
              onChanged: _filterSearchResults,
              decoration: const InputDecoration(
                labelText: "Search Restaurant",
                hintText: "Enter restaurant name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                ),
              ),
            ),
          ),
          // List of restaurants with shadow effect
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850] // Dark mode box color
                    : Colors.white, // Light mode box color
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                            .withOpacity(0.5) // Darker shadow for dark mode
                        : Colors.black
                            .withOpacity(0.2), // Lighter shadow for light mode
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return ListTile(
                    leading: Image.asset(
                      'assets/images/pizza.png',
                      height: 50,
                      width: 50,
                    ),
                    title: Text(
                      restaurant['name']!,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors
                                .black, // Explicitly set the text color for light/dark mode
                      ),
                    ),
                    subtitle: Text(
                      restaurant['items']!,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[800], // Adjust subtitle color
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Page 2: Available Pickups
class AvailablePickupsPage extends StatelessWidget {
  final List<Map<String, String>> availablePickups = [
    {'name': 'Taj Lands End', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'Balaji', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'Alibaug', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'The Great Indian Dhaba', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'McDonald’s', 'time': '2:30 PM', 'items': '10 items'},
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

// Page 3: Past Orders
class PastOrdersPage extends StatelessWidget {
  final List<Map<String, String>> pastOrders = [
    {'date': '2023-09-01', 'items': 'Pizza, Burger', 'status': 'Completed'},
    {'date': '2023-09-05', 'items': 'Sushi, Taco', 'status': 'Completed'},
    {'date': '2023-09-10', 'items': 'Pasta', 'status': 'Completed'},
  ];

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
            title: Text('Order on ${order['date']}'),
            subtitle: Text('Items: ${order['items']}'),
            trailing: Text(order['status']!),
          ),
        );
      },
    );
  }
}
