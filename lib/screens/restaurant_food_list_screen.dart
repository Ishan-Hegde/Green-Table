import 'package:flutter/material.dart';

class RestaurantFoodListScreen extends StatelessWidget {
  const RestaurantFoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food List'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.food_bank),
            title: const Text('Pizza'),
            subtitle: const Text('5 meals left'),
            trailing: ElevatedButton(
              onPressed: () {
                // Post meal action
              },
              child: const Text('Post'),
            ),
          ),
          // Add more items
        ],
      ),
    );
  }
}
