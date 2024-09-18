import 'package:flutter/material.dart';

class ConsumerFoodListScreen extends StatelessWidget {
  const ConsumerFoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Food Listings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Image.network('image_url'), // Restaurant image
            title: const Text('Restaurant A'),
            subtitle: const Text('Pizza - 2 servings'),
            trailing: const Text('Pickup'),
          ),
          // Add more listings
        ],
      ),
    );
  }
}
