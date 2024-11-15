// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, library_prefixes, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token storage
import 'login_page.dart'; // Import your LoginPage
import 'dart:math';
import 'package:green_table/pages/map_screen/map_screen.dart'; // Import the MapScreen
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // Adjust height of the AppBar
          child: AppBar(
            title: const Text('FooD for GooD'),
            centerTitle: true,
            shadowColor: Colors.blueAccent.shade700,
            actions: [
              IconButton(
                icon: const Icon(Icons.location_pin),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                },
              ),
            ],
          ),
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
  final List<Map<String, dynamic>> _restaurants = [
    // Sample static data or empty list initially, data will be fetched from the backend
  ];

  List<Map<String, dynamic>> _filteredRestaurants = [];
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = _restaurants; // Initialize with all restaurants
    _initializeSocket();
  }

  void _initializeSocket() {
    socket =
        IO.io('https://green-table-backend.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    // Listen for new food availability
    socket.on('newFoodAvailable', (data) {
      print('Received new food item: $data');
      setState(() {
        // Check if restaurant exists by restaurantId
        String restaurantId = data['restaurantId'];
        Map<String, dynamic> restaurant = _restaurants.firstWhere(
          (r) => r['restaurantId'] == restaurantId,
          orElse: () => {} as Map<String, dynamic>, // Default if not found
        );
        if (restaurant.isNotEmpty) {
          // Ensure the 'foodItems' list exists and is initialized
          if (restaurant['foodItems'] == null) {
            restaurant['foodItems'] = [];
          }
          // Add the new food item
          restaurant['foodItems'].add({
            'name': data['name'],
            'description': data['description'],
            'price': data['price'],
            'quantity': data['quantity'],
            'expiryDate': data['expiryDate'],
            'timeOfCooking': data['timeOfCooking'],
          });
        } else {
          // If restaurant doesn't exist, create a new one
          _restaurants.add({
            'restaurantId': restaurantId,
            'restaurantName': data['restaurantName'],
            'foodItems': [
              {
                'name': data['name'],
                'description': data['description'],
                'price': data['price'],
                'quantity': data['quantity'],
                'expiryDate': data['expiryDate'],
                'timeOfCooking': data['timeOfCooking'],
              },
            ],
          });
        }
        _filteredRestaurants = _restaurants;
      });
    });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRestaurants = _restaurants; // Show all when query is empty
      });
    } else {
      setState(() {
        _filteredRestaurants = _restaurants
            .where((restaurant) => restaurant['restaurantName']!
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Image.asset(
                          'assets/images/pizza.png', // Static image for the restaurant (you can make this dynamic)
                          height: 50,
                          width: 50,
                        ),
                        title: Text(
                          restaurant['restaurantName']!,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                      // Display the food items for each restaurant
                      if (restaurant['foodItems'] != null)
                        ...restaurant['foodItems'].map<Widget>((item) {
                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Text(
                                'Description: ${item['description']}, Price: \$${item['price']}'),
                            trailing: Text('Qty: ${item['quantity']}'),
                            onTap: () {
                              // Navigate to food item details page (or order page)
                            },
                          );
                        }).toList(),
                    ],
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
