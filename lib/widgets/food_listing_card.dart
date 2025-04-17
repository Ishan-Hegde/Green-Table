import 'package:flutter/material.dart';
import 'package:green_table/models/food_item.dart';
import 'package:intl/intl.dart';

class FoodListingCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const FoodListingCard({
    super.key,
// Remove duplicate key parameter since it's already defined in super.key
    required this.foodItem,
    this.onTap,
    this.onAddToCart,
  });

  // ignore: empty_constructor_bodies
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            if (foodItem.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  foodItem.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 50),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          foodItem.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${foodItem.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Restaurant Name
                  Text(
                    foodItem.restaurantName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    foodItem.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Quantity and Expiry Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity: ${foodItem.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Expires: ${DateFormat('MMM d, y').format(foodItem.expiryDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: DateTime.now().isAfter(foodItem.expiryDate)
                                  ? Colors.red
                                  : null,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Add to Cart Button
                  if (onAddToCart != null && foodItem.isAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: foodItem.quantity > 0 ? onAddToCart : null,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  // Unavailable or Out of Stock Message
                  if (!foodItem.isAvailable || foodItem.quantity <= 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        !foodItem.isAvailable
                            ? 'Currently Unavailable'
                            : 'Out of Stock',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}