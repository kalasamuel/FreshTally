import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SmartSuggestionsPage extends StatelessWidget {
  SmartSuggestionsPage({Key? key}) : super(key: key);

  // Mock data for demonstration
  final List<Map<String, dynamic>> suggestions = [
    {
      'name': 'Milk 1L',
      'expiry': '2024-07-05',
      'salesVelocity': 'Slow',
      'reason': 'Expiring soon',
    },
    {
      'name': 'Whole Wheat Bread',
      'expiry': '2024-06-30',
      'salesVelocity': 'Slow',
      'reason': 'Low sales',
    },
    {
      'name': 'Yogurt Cup',
      'expiry': '2024-07-01',
      'salesVelocity': 'Moderate',
      'reason': 'Expiring soon',
    },
    {
      'name': 'Canned Beans',
      'expiry': '2025-01-01',
      'salesVelocity': 'Very Slow',
      'reason': 'Low sales',
    },
  ];

  Future<void> _applyDiscount(BuildContext context, String productName) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Find the product by name (for demo; in production use product ID)
      final query = await firestore
          .collection('products')
          .where('name', isEqualTo: productName)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product "$productName" not found.')),
        );
        return;
      }
      final doc = query.docs.first.reference;
      await doc.update({
        'discountPercentage': 20.0, // Example: 20% discount
        'discountExpiry': Timestamp.fromDate(
          DateTime.now().add(Duration(days: 7)),
        ),
        'is_discounted': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Discount applied to "$productName"!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to apply discount: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Discount Suggestions')),
      body: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final product = suggestions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(
                Icons.lightbulb_outline,
                color: Colors.orange,
              ),
              title: Text(
                product['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expiry: ${product['expiry']}'),
                  Text('Sales velocity: ${product['salesVelocity']}'),
                  Text(
                    'Reason: ${product['reason']}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _applyDiscount(context, product['name']),
                child: const Text('Apply Discount'),
              ),
            ),
          );
        },
      ),
    );
  }
}
