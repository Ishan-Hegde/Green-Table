// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token storage
import 'login_page.dart'; // Import your LoginPage
import 'dart:math';
import 'package:green_table/pages/map_screen/map_screen.dart'; // Import the MapScreen

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
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(
              foregroundColor:
                  Colors.green, // Change text color to green for Cancel
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _signOut(); // Call sign out function
            },
            style: TextButton.styleFrom(
              foregroundColor:
                  Colors.red, // Change text color to red for Sign Out
            ),
            child: const Text('Sign Out'),
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
          title: const Text('FooD for GooD'),
          centerTitle: true,
          shadowColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                // Add notification logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MapScreen()), // Navigate to MapScreen on notification click
                );
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
          backgroundColor:
              isDarkMode ? const Color.fromARGB(255, 8, 8, 8) : Colors.white,
          selectedItemColor:
              isDarkMode ? Colors.greenAccent : const Color(0xFF00B200),
          selectedFontSize: 16,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          selectedIconTheme: const IconThemeData(size: 26),
          onTap: _onItemTapped,
        ),
        drawer: Drawer(
          backgroundColor:
              isDarkMode ? const Color.fromARGB(146, 8, 8, 8) : Colors.white,
          width: 260,
          child: Column(
            children: [
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
                    }),
              ),
              ListTile(
                  leading: const Icon(Icons.star, color: Colors.yellow),
                  title: const Text('Favourites'),
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FavoriteItemsPage()),
                      )),
              ListTile(
                  leading: const Icon(Icons.account_box_rounded,
                      color: Colors.blueAccent),
                  title: const Text('Profile'),
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      )),
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

class FavoriteItemsPage extends StatelessWidget {
  final List<Map<String, String>> favoriteItems = [
    {'restaurant': 'Restaurant A', 'details': 'Amazing pasta and pizzas'},
    {'restaurant': 'Restaurant B', 'details': 'Delicious burgers and fries'},
    // Add more favorites if needed
  ];

  void _removeFavorite(BuildContext context, Map<String, String> favorite) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${favorite['restaurant']} removed from favorites.'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Optionally handle Undo action here
          },
        ),
      ),
    );
    // Optionally: Implement your removal logic here, like updating the list or database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Simple back navigation
          },
        ),
      ),
      body: ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          final favorite = favoriteItems[index];
          return ListTile(
            title: Text(favorite['restaurant'] ?? ''),
            subtitle: Text(favorite['details'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFavorite(context, favorite),
            ),
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Change Name'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change Name option selected.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Change Email'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Change Email option selected.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Change Password option selected.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Correct way to go back
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showProfileOptions(context),
          ),
        ],
      ),
      body: Center(child: const Text("Profile Details Here")),
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
    {
      'name': 'Pizzeria',
      'items': '10 items',
      'description': 'Delicious pizza with fresh ingredients.'
    },
    {
      'name': 'Sushi Place',
      'items': '5 items',
      'description': 'Authentic Japanese sushi with a modern twist.'
    },
    {
      'name': 'Burger Joint',
      'items': '8 items',
      'description': 'Juicy burgers made to order.'
    },
    {
      'name': 'BBQ Nation',
      'items': '12 items',
      'description': 'Mouth-watering BBQ and grilled items.'
    },
    {
      'name': 'Taco Stand',
      'items': '7 items',
      'description': 'Authentic Mexican tacos, freshly made.'
    },
    {
      'name': 'Pasta House',
      'items': '9 items',
      'description': 'Homemade pasta with various sauces.'
    },
    {
      'name': 'Burger King',
      'items': '4 items',
      'description': 'Your favorite fast food chain burgers.'
    },
    {
      'name': 'McDonalds',
      'items': '15 items',
      'description': 'Classic fast food, known worldwide.'
    },
    {
      'name': 'KFC',
      'items': '6 items',
      'description': 'Fried chicken made with 11 herbs and spices.'
    },
    {
      'name': 'TWC',
      'items': '1 items',
      'description': 'A local favorite with fresh daily offerings.'
    },
    {
      'name': 'Starbucks',
      'items': '9 items',
      'description': 'Coffeehouse chain known for its signature drinks.'
    },
    {
      'name': 'Tunga International',
      'items': '3 items',
      'description': 'Fine dining with a mix of Indian and global cuisines.'
    },
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
                    ? const Color.fromARGB(
                        255, 15, 15, 15) // Dark mode box color
                    : Colors.white, // Light mode box color
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00B200)
                            .withOpacity(0.3) // Darker shadow for dark mode
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
                    onTap: () {
                      // Navigate to restaurant detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailPage(
                            restaurant: restaurant, // Pass restaurant data
                          ),
                        ),
                      );
                    },
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

// Page to show restaurant details
class RestaurantDetailPage extends StatelessWidget {
  final Map<String, String> restaurant;

  const RestaurantDetailPage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant['name']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              restaurant['description']!,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Items available: ${restaurant['items']}',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF00B200),
              ),
            ),
          ],
        ),
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

// Page 3: Past Orders with Download Invoice Option
class PastOrdersPage extends StatelessWidget {
  final List<Map<String, String>> pastOrders = List.generate(5, (index) {
    return {
      'number': (100000 + Random().nextInt(900000))
          .toString(), // Generate a random 6-digit number
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
              color: order['status'] == 'Completed'
                  ? const Color(0xFF00B200)
                  : Colors.red,
            ),
            onTap: () => _showOrderDetails(context, order),
          ),
        );
      },
    );
  }

  // Function to show the bottom sheet with download option
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
              const Text(
                'Order Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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

  // Function to simulate invoice download
  void _downloadInvoice(BuildContext context, Map<String, String> order) {
    Navigator.pop(context); // Close the bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Invoice for order No. ${order['number']} is being downloaded."),
      ),
    );
    // You can add actual file download logic here using a package like 'flutter_downloader' or 'pdf'.
  }
}
