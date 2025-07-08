import 'package:flutter/material.dart';

class ExpiredProductDetailsPage extends StatelessWidget {
  const ExpiredProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expired Product Details')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Replace with real data count
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text('Product ${index + 1}'),
              subtitle: const Text('Expired on: 2024-06-10'),
              trailing: const Icon(Icons.warning, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
