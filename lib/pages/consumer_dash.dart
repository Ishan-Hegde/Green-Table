// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, library_prefixes, avoid_print, unnecessary_nullable_for_final_variable_declarations, unused_element

import 'dart:convert';

// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_table/config.dart';
// ignore: unused_import
import 'package:green_table/pages/restaurant_dash.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token storage
import 'login_page.dart'; // Import your LoginPage
import 'dart:math';
import 'package:green_table/pages/map_screen/map_screen.dart'; // Import the MapScreen
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

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
  final List<Map<String, dynamic>> _cartItems = []; // Add cart state here

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      FoodForGoodPage(cartItems: _cartItems),
      AvailablePickupsPage(),
      PastOrdersPage(),
    ];
  }

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
                    MaterialPageRoute(builder: (context) => MapScreen(initialPosition: LatLng(19.0760, 72.8777))),
                  );
                },
              ),
IconButton(
  icon: const Icon(Icons.shopping_cart),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CartScreen(initialCartItems: _cartItems)),
  ),
)
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
  final List<Map<String, dynamic>> cartItems;
  
  const FoodForGoodPage({super.key, required this.cartItems});

  @override
  _FoodForGoodPageState createState() => _FoodForGoodPageState();
}

class _FoodForGoodPageState extends State<FoodForGoodPage> {
  List<Map<String, dynamic>> _restaurants = [];
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _fetchRestaurants();
  }

  void _initializeSocket() {
    socket =
        IO.io('https://green-table-ni1h.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    // Listen for new food availability
    socket.on('newFoodAvailable', (data) {
      print('Received new food item: $data');
      setState(() {
        String restaurantId = data['restaurantId'];
        Map<String, dynamic> restaurant = _restaurants.firstWhere(
          (r) => r['restaurantId'] == restaurantId,
          orElse: () => ({
            'restaurantId': restaurantId,
            'restaurantName': data['restaurantName'],
            'foodItems': [], // Ensure initialization with empty list
          }),
        );

        // Now we can safely add the food item
        restaurant['foodItems'].add({
          'name': data['name'],
          'description': data['description'],
          'price': data['price'],
          'quantity': data['quantity'],
          'expiryDate': data['expiryDate'],
          'timeOfCooking': data['timeOfCooking'],
        });
      });
    });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  Future<void> _fetchRestaurants() async {
    final response = await http.get(Uri.parse(
        '${Config.baseUrl}/food/available')); // Changed to direct food endpoint

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> foodListings = responseData['data'] ?? [];
      
      // Group food items by restaurant
      final Map<String, List<dynamic>> restaurantMap = {};
      for (var food in foodListings) {
        final restaurantId = food['restaurantId'];
        if (!restaurantMap.containsKey(restaurantId)) {
          restaurantMap[restaurantId] = [];
        }
        restaurantMap[restaurantId]!.add(food);
      }

      setState(() {
        _restaurants = restaurantMap.entries.map((entry) => {
          'id': entry.key,
          'restaurantId': entry.key,
          'restaurantName': entry.value.isNotEmpty 
              ? entry.value.first['restaurantName'] 
              : 'Unknown Restaurant',
          'foodItems': entry.value,
        }).toList();
      });
    }
  }

  Future<void> _fetchFoodListings(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        // Uri.parse('${Config.baseUrl}/food?restaurantId=$restaurantId'), // Changed endpoint format
        Uri.parse('${Config.baseUrl}/food?restaurantId=$restaurantId'), // Changed endpoint format
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body); // Parse as Map
        final List<dynamic> foodItems = responseData['foodItems'] ?? [];
        
        setState(() {
          final restaurantIndex = _restaurants.indexWhere(
            (r) => r['restaurantId'] == restaurantId
          );
          
          if (restaurantIndex != -1) {
            // Add all food items from the response
            for (final item in foodItems) {
              _restaurants[restaurantIndex]['foodItems'].add({
                'name': item['name'],
                'description': item['description'],
                'price': item['price'],
                'quantity': item['quantity'],
                'expiryDate': item['expiryDate'],
                'timeOfCooking': item['timeOfCooking'],
              });
            }
          }
        });
      } else {
        print('Failed to load food items: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching food items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection failed')),
      );
    }
  }

  void _showFoodListings(Map<String, dynamic> restaurant) {
    // Fetch food items for the selected restaurant before showing them
    _fetchFoodListings(restaurant['id'] ?? '');  // Use 'id' instead of 'restaurantId'

    showModalBottomSheet(
      context: context,
      builder: (context) => FoodListingsWidget(restaurant: restaurant),
    );
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
// Show all when query is empty
      });
    } else {
      setState(() {
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
      child: ListView.builder(
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: ExpansionTile(
              title: Text(
                restaurant['restaurantName'] ?? 'Unknown Restaurant',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (restaurant['foodItems'] != null)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: restaurant['foodItems'].length,
                          itemBuilder: (context, foodIndex) {
                            final foodItem = restaurant['foodItems'][foodIndex];
                            return ListTile(
                              title: Text(foodItem['foodName'] ?? 'Unnamed Item'),  // Changed from 'name'
                              subtitle: Text(
                                foodItem['description'] ?? 'No description',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.cartItems.contains(foodItem) 
                                      ? Colors.grey 
                                      : const Color(0xFF00B200),
                                ),
                                onPressed: () {
                                  if (!widget.cartItems.contains(foodItem)) {
                                    setState(() {
                                      widget.cartItems.add(foodItem);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Claimed ${foodItem['foodName']}'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  widget.cartItems.contains(foodItem) ? 'Claimed' : 'Claim',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              leading: const Icon(Icons.fastfood),
                            );
                          },
                        ),
                      if (restaurant['foodItems'] == null || 
                          restaurant['foodItems'].isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No food items available'),
                        )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class FoodListingsWidget extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final _cartItems = <Map<String, dynamic>>[];
  
  late BuildContext context;

  FoodListingsWidget({super.key, required this.restaurant});

  void _addToCart(Map<String, dynamic> item) {
    _cartItems.add(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${item['name']} to cart')),
    );
  }

  void _placeOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.post(
      Uri.parse('https://green-table-ni1h.onrender.com/api/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'restaurantId': restaurant['restaurantId'],
        'items': _cartItems,
        'status': 'pending',
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      _cartItems.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${restaurant['name']} - Food Listings',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: restaurant['foodItems']?.length ?? 0,
              itemBuilder: (context, index) {
                final item = restaurant['foodItems']?[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(item?['name'] ?? 'Unnamed Item'),
                    subtitle: Text(item?['description'] ?? ''),
                    trailing: TextButton.icon(
                      icon: Icon(Icons.local_offer),
                      label: Text('Claim'),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF00B200),
                      ),
                      onPressed: () => _addToCart(item!),
                    ),
                  ),
                );
              },
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
                    downloadInvoice(context, order);
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
  void downloadInvoice(BuildContext context, Map<String, String> order) {
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

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialCartItems;
  
  const CartScreen({super.key, required this.initialCartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.initialCartItems);
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] ?? 0.0));
  }

  Future<void> _placeOrder() async {
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': _cartItems,
          'status': 'pending'
        }),
      );

      if (response.statusCode == 201 && mounted) {
        setState(() => _cartItems.clear());
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_cartItems[index]['foodName'] ?? 'Unnamed Item'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeItem(index),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total: \$${_calculateTotal().toStringAsFixed(2)}'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _placeOrder,
        child: const Icon(Icons.check),
      ),
    );
  }
}
