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

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConsumerApp(),
    );
  }
}

class _ConsumerAppState extends State<ConsumerApp> {
  int _selectedIndex = 0;

  // Navigation items
  final List<Widget> _widgetOptions = <Widget>[
    FoodForGoodPage(),
    AvailablePickupsPage(),
    PastOrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green[700], // Header background color
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(55),
                bottomRight: Radius.circular(55),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      // Add logic for menu button, if needed
                    },
                  ),
                  const Text(
                    'FooD for GooD',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // Add notification logic
                    },
                  ),
                ],
              ),
            ),
          ),
          // Body content below AppBar
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
        selectedItemColor: Colors.green[700],
        selectedFontSize: 16,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedIconTheme: const IconThemeData(size: 26),
        onTap: _onItemTapped,
      ),
    );
  }
}

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
        _filteredRestaurants = _restaurants;
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
          // Reduced padding around the search bar
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
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
                    title: Text(restaurant['name']!),
                    subtitle: Text(restaurant['items']!),
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
    {'name': 'Amrut Sagar', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'BBQ Nation', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'Sai Palace', 'time': '2:30 PM', 'items': '10 items'},
    {'name': 'Global Fusion', 'time': '2:30 PM', 'items': '10 items'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: availablePickups.length,
        itemBuilder: (context, index) {
          final pickup = availablePickups[index];
          return ListTile(
            title: Text(pickup['name']!),
            subtitle: Text('${pickup['time']} - ${pickup['items']}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Accept pickup logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
              ),
              child: const Text('Accept'),
            ),
          );
        },
      ),
    );
  }
}

// Page 3: Past Orders
class PastOrdersPage extends StatelessWidget {
  final List<Map<String, String>> pastOrders = [
    {'name': 'Taj Lands End', 'status': 'Successful'},
    {'name': 'Balaji', 'status': 'Successful'},
    {'name': 'Amrut Sagar', 'status': 'Successful'},
    {'name': 'BBQ Nation', 'status': 'Successful'},
    {'name': 'Sai Palace', 'status': 'Successful'},
    {'name': 'Global Fusion', 'status': 'Successful'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: pastOrders.length,
        itemBuilder: (context, index) {
          final order = pastOrders[index];
          return ListTile(
            title: Text(order['name']!),
            subtitle: Text('Order status: ${order['status']}'),
            trailing: Icon(Icons.check_circle, color: Colors.green[600]),
          );
        },
      ),
    );
  }
}
