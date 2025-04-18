// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, unused_import, library_prefixes, avoid_print, unused_element

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_table/config.dart';
import 'package:green_table/widgets/food_listing_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/food_item.dart';
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
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    socket = IO.io(Config.baseUrl, IO.OptionBuilder().setTransports(['websocket']).build());
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
  int _selectedIndex = 0;
  bool isDarkMode = false;
  Color primaryGreen = Colors.green[700]!;

  final List<Widget> _widgetOptions = <Widget>[
    AvailablePickupsPage(),
    PastOrdersPage(),
    OrdersPage(
      restaurantId: '',
    ),
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
          title: const Text('FooD for GooD'),
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
              label: 'Ongoing Pickups',
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
  final String restaurantId;

  const OrdersPage({required this.restaurantId, super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  void _navigateToFoodDetail(Map<String, dynamic> foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(foodItem['name'])),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${foodItem['description']}'),
                Text('Price: ${foodItem['price']}'),
                Text('Quantity: ${foodItem['quantity']}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAddToCart(Map<String, dynamic> foodItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${foodItem['name']} added to cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String userEmail = '';
  String restaurantId = '';
  String restaurantName = '';
  List<Map<String, dynamic>> foodItems = []; // To hold food item details

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController timeOfCookingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchFoodItems();
  }

  // Fetch user details (email and restaurantId) from SharedPreferences or API
  Future<void> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserEmail = prefs.getString('userEmail');

    if (storedUserEmail != null) {
      // Fetch restaurant data based on the stored email
      final response = await http.get(
        Uri.parse(
            'https://green-table.onrender.com/api/restaurant/all'), // Get all restaurants
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
              restaurantName = restaurant['name']; // Get the restaurant Name
            });
            break;
          }
        }
      } else {
        // Handle any errors that might occur while fetching data
        setState(() {
          userEmail = storedUserEmail;
          restaurantId = 'Error fetching restaurant ID';
          restaurantName = 'Unknown Restaurant';
        });
      }
    } else {
      // If no email is found in SharedPreferences
      setState(() {
        userEmail = 'Unknown User';
        restaurantId = 'Unknown Restaurant';
        restaurantName = 'Unknown Restaurant';
      });
    }
  }

  // Fetch food items from the server
  Future<void> _fetchFoodItems() async {
    if (restaurantId.isNotEmpty) {
      const maxRetries = 3;
      http.Response response = http.Response('', 500); // Initialize with default
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          response = await http.get(
            Uri.parse('${Config.baseUrl}/food/$restaurantId'),
          );
          if (response.statusCode == 200) break;
        } catch (e) {
          response = http.Response('', 500); // Ensure assignment on error
          if (attempt == maxRetries) {
            debugPrint('Failed to fetch food items after $maxRetries attempts: $e');
            final prefs = await SharedPreferences.getInstance();
            final lastUpdate = prefs.getInt('lastFoodUpdate') ?? 0;
            if (DateTime.now().millisecondsSinceEpoch - lastUpdate > 86400000) {
              await prefs.remove('cachedFoodItems');
            }
            await _loadFoodItemsFromLocal();
            return;
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (response.statusCode == 200) {
        final List<dynamic> foods = jsonDecode(response.body);

        setState(() {
          foodItems = foods.where((food) {
            return food['restaurantId'] == restaurantId; // Compare restaurantId
          }).map((food) {
            return {
              'restaurantName': food['restaurantName'],
              'foodItems': food['foodItems'],
              'description': food['description'],
              'expiryDate': food['expiryDate'],
              'quantity': food['quantity'],
              'price': food['price'],
              'category': food['category'],
            };
          }).toList();
        });

        // Save the food items to local storage
        _saveFoodItemsToLocal(foodItems);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastFoodUpdate', DateTime.now().millisecondsSinceEpoch);
      } else {
        // If API call fails, load from local storage
        await _loadFoodItemsFromLocal();
      }
    } else {
      // Load food items from local storage if restaurantId is empty
      _loadFoodItemsFromLocal();
    }
  }

  // Add a new food item listing
  Future<void> _addFoodItem(Map<String, dynamic> newFoodItem) async {
    if (restaurantId.isEmpty || restaurantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restaurant details are missing.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://green-table.onrender.com/api/food/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'restaurantId': restaurantId,
          'restaurantName': restaurantName,
          // Here we ensure that foodItems is an array (list) of food names
          'foodName': nameController
              .text, // Put the name from the controller as a single item in the list
          'description': descriptionController.text,
          'price': double.parse(priceController.text),
          'quantity': int.parse(quantityController.text),
          'expiryDate':
              expiryDateController.text, // Ensure it's in the correct format
          'category': categoryController.text,
          'timeOfCooking': DateFormat('yyyy-MM-dd HH:mm')
              .parse(
                  '${expiryDateController.text} ${timeOfCookingController.text}')
              .toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        _fetchFoodItems(); // Refresh the list of food items
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Food item added successfully!')),
        );
      } else {
        // Log error details from response body
        debugPrint('Failed to add food item: ${response.body}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add food item')));
      }
    } catch (e) {
      debugPrint('Error adding food item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while adding food item')));
    }
  }

  Future<void> _saveFoodItemsToLocal(
      List<Map<String, dynamic>> foodList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> foodItemsJson = foodList
        .map((foodItem) => jsonEncode(foodItem))
        .toList(); // Encode each food item to JSON string
    await prefs.setStringList(
        'foodItems', foodItemsJson); // Save as list of strings
  }

  Future<void> _loadFoodItemsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? foodItemsJson = prefs.getStringList('foodItems');

    if (foodItemsJson != null) {
      setState(() {
        foodItems = foodItemsJson
            .map((foodItemJson) =>
                jsonDecode(foodItemJson) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Show DatePicker to select expiry date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default to current date
      firstDate: DateTime(2000), // Earliest date
      lastDate: DateTime(2101), // Latest date
    );
    if (pickedDate != null) {
      // Format the selected date to ISO string format
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      expiryDateController.text =
          formattedDate; // Set the selected date in the controller
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    // Show TimePicker to select time of cooking
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Default to current time
    );
    if (pickedTime != null) {
      // Format the selected time to HH:mm format
      String formattedTime = pickedTime.format(context);
      timeOfCookingController.text =
          formattedTime; // Set the selected time in the controller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$restaurantName Details',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Logged-in user email: $userEmail\n'
                'Restaurant ID: $restaurantId\n'
                'Restaurant Name: $restaurantName',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Form to add a new food item
              // Add New Food Listing Section
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Food Listing',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    // Form to add a new food item
                    _buildInputField(
                        nameController, "Food Name", Icons.fastfood),
                    _buildInputField(
                        descriptionController,
                        "Description(Veg/Non-veg,Jain,Vegan etc.)",
                        Icons.description),
                    _buildInputField(
                        priceController, "Price", Icons.currency_rupee,
                        keyboardType: TextInputType.number),
                    _buildInputField(
                        quantityController,
                        "Quantity(In grams/kg or Serves 2 etc.)",
                        Icons.format_list_numbered,
                        keyboardType: TextInputType.number),
                    _buildDatePickerField(expiryDateController, "Expiry Date"),
                    _buildTimePickerField(
                        timeOfCookingController, "Time of Cooking"),
                    _buildInputField(
                        categoryController, "Category", Icons.category),

                    ElevatedButton(
                      onPressed: _addFoodItemHandler,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
                        backgroundColor: Theme.of(context).primaryColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Add Food Item',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Past Listings done by $restaurantId",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              foodItems.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        final food = foodItems[index];
                        return FoodListingCard(
                          foodItem: FoodItem.fromMap(food),
                          onTap: () => _navigateToFoodDetail(food),
                          onAddToCart: () => _handleAddToCart(food),
                          textStyle: Theme.of(context).textTheme.bodyMedium!,
                        );
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String labelText, IconData iconData,
      {TextInputType keyboardType = TextInputType.text}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(iconData, color: Theme.of(context).primaryColor),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                    labelText: labelText, border: InputBorder.none),
                keyboardType: keyboardType,
              ),
              
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
      TextEditingController controller, String labelText) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: _buildInputField(
          controller,
          "$labelText (Tap on the calendar icon)",
          Icons.calendar_today), // Prevent typing
    );
  }

  Widget _buildTimePickerField(
      TextEditingController controller, String labelText) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: _buildInputField(controller, "$labelText (Tap on the clock icon)",
          Icons.access_time), // Prevent typing
    );
  }

  void _addFoodItemHandler() {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty ||
        expiryDateController.text.isEmpty ||
        timeOfCookingController.text.isEmpty ||
        categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      final double price = double.parse(priceController.text);
      final int quantity = int.parse(quantityController.text);

      Map<String, dynamic> newFoodItem = {
        'foodName': (String name) => nameController.text,
        'description': descriptionController.text,
        'category': categoryController.text,
        'price': price,
        'quantity': quantity,
        'expiryDate': expiryDateController.text,
        'timeOfCooking': DateFormat('yyyy-MM-dd HH:mm')
            .parse(
                '${expiryDateController.text} ${timeOfCookingController.text}')
            .toIso8601String(),
      };

      _addFoodItem(newFoodItem);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid number input')));
    }
  }
}
