import 'package:flutter/material.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
      ),
      body: Column(
        children: [
          const ListTile(
            title: Text('Pizza - 2 servings'),
            subtitle: Text('Restaurant A'),
            trailing: Text('Total: \$10'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/payment');
            },
            child: const Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Column(
        children: [
          const TextField(
            decoration: InputDecoration(labelText: 'Card Number'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'CVV'),
          ),
          ElevatedButton(
            onPressed: () {
              // Process payment
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }
}
