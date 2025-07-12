import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SmartPromotionsSuggestionsPage extends StatefulWidget {
  const SmartPromotionsSuggestionsPage({super.key});

  @override
  State<SmartPromotionsSuggestionsPage> createState() =>
      _SmartPromotionsSuggestionsPageState();
}

class _SmartPromotionsSuggestionsPageState
    extends State<SmartPromotionsSuggestionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Discount Suggestions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where(
              'expiryDate',
              isLessThanOrEqualTo: Timestamp.fromDate(
                DateTime.now().add(const Duration(days: 10)),
              ),
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading suggestions.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(
              child: Text('No smart suggestions at the moment.'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              final String name = data['name'] ?? '';
              final double price = (data['price'] ?? 0).toDouble();
              final Timestamp expiryTimestamp = data['expiryDate'];
              final String salesVelocity = data['salesVelocity'] ?? 'Unknown';
              final int discount = (data['discountPercentage'] ?? 0).toInt();

              final DateTime expiryDate = expiryTimestamp.toDate();
              final String reason =
                  DateTime.now().difference(expiryDate).inDays <= -10
                  ? 'Expiring soon'
                  : 'Slow sales';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Price: UGX ${price.toStringAsFixed(0)}'),
                      Text(
                        'Expiry: ${expiryDate.toLocal().toString().split(' ')[0]}',
                      ),
                      Text('Sales Velocity: $salesVelocity'),
                      Text(
                        'Reason: $reason',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      if (discount > 0)
                        Text(
                          'Current Discount: $discount%',
                          style: const TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () =>
                        _showEditDiscountDialog(context, doc, data),
                    child: const Text('Edit Discount'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDiscountDialog(
    BuildContext context,
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) {
    final formKey = GlobalKey<FormState>();
    int discount = (data['discountPercentage'] ?? 0).toInt();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Discount for ${data['name']}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: discount.toString(),
              decoration: const InputDecoration(labelText: 'Discount %'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a discount';
                }
                final d = int.tryParse(value);
                if (d == null || d < 0 || d > 100) {
                  return 'Enter 0–100';
                }
                return null;
              },
              onSaved: (value) {
                discount = int.parse(value!);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  final double price = (data['price'] ?? 0).toDouble();
                  final discountedPrice = (price * (1 - discount / 100)).clamp(
                    0,
                    price,
                  );

                  await doc.reference.update({
                    'discountPercentage': discount,
                    'discountedPrice': discountedPrice,
                  });

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Updated discount to $discount% for ${data['name']}',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
