import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('Product Image')),
            ),
            const SizedBox(height: 12),
            const Text(
              'Milk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Price: \$1.50'),
            const Text('Shelf: A1'),
            const Text(
              'Expires in 3 days',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text('Add to List')),
            const SizedBox(height: 20),
            const Text('Ratings'),
            Row(
              children: List.generate(
                5,
                (i) => const Icon(Icons.star, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
