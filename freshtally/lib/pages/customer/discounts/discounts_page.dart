import 'package:flutter/material.dart';

class DiscountsPage extends StatelessWidget {
  const DiscountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discounts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              '🔥 Hot Discounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: const Text('Milk'),
                subtitle: const Text('Was \$2 → Now \$1'),
                trailing: const Icon(Icons.local_offer, color: Colors.orange),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Bread'),
                subtitle: const Text('Was \$1.50 → Now \$1'),
                trailing: const Icon(Icons.local_offer, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
