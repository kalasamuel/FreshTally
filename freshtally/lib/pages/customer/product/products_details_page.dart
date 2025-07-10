// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProductDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> product;

//   const ProductDetailsPage({super.key, required this.product});

//   @override
//   Widget build(BuildContext context) {
//     final name = product['name'];
//     final price = product['price'];
//     final category = product['category'];
//     final expiryDate = (product['expiry_date'] as Timestamp).toDate();
//     final imageUrl = product['image_url'];

//     return Scaffold(
//       appBar: AppBar(title: Text(name)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             if (imageUrl != null)
//               Image.network(imageUrl, height: 200, fit: BoxFit.cover),
//             const SizedBox(height: 16),
//             Text(
//               name,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text('Price: $price UGX', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 8),
//             Text('Category: $category'),
//             const SizedBox(height: 8),
//             Text(
//               'Expires on: ${expiryDate.day}-${expiryDate.month}-${expiryDate.year}',
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () => _addToShoppingList(context),
//               icon: const Icon(Icons.add),
//               label: const Text('Add to Shopping List'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addToShoppingList(BuildContext context) async {
//     await FirebaseFirestore.instance.collection('shopping_list').add({
//       'product_id': product['product_id'],
//       'name': product['name'],
//       'price': product['price'],
//       'image_url': product['image_url'],
//       'added_at': Timestamp.now(),
//     });

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Added to shopping list')));
//   }
// }

import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? '';
    final price = product['price'] ?? '';
    final category = product['category'] ?? 'General';
    final expiryDate = product['expiry_date'] as DateTime?; // Can be null
    final imageUrl = product['image_url'];
    final description = product['description'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(imageUrl, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Price: $price UGX', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Category: $category'),
            if (expiryDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expires on: ${expiryDate.day}-${expiryDate.month}-${expiryDate.year}',
              ),
            ],
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _addToShoppingList(context),
              icon: const Icon(Icons.add),
              label: const Text('Add to Shopping List'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToShoppingList(BuildContext context) async {
    // Simulate adding to shopping list (no Firebase)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to shopping list')));
  }
}
