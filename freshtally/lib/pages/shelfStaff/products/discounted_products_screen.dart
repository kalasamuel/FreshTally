import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiscountedProductsScreen extends StatelessWidget {
  final String supermarketId;

  const DiscountedProductsScreen({super.key, required this.supermarketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discounted Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(supermarketId)
            .collection('products')
            .where('discounted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No discounted products at the moment.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed';
              final price = data['price'] ?? 0;
              final discount = data['discountPercent'] ?? 0;

              return ListTile(
                leading: const Icon(Icons.local_offer, color: Colors.redAccent),
                title: Text(name, style: const TextStyle(fontSize: 18)),
                subtitle: Text(
                  'Price: UGX $price\nDiscount: $discount%',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(
                  Icons.label_important,
                  color: Colors.orange,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
