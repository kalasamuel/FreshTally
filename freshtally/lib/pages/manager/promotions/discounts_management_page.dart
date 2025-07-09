import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountsManagementPage extends StatefulWidget {
  const DiscountsManagementPage({Key? key}) : super(key: key);

  @override
  State<DiscountsManagementPage> createState() => _DiscountsManagementPageState();
}

class _DiscountsManagementPageState extends State<DiscountsManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discounted Products')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('is_discounted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No discounts applied yet.'));
          }
          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty
                      ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discount: ${product['discountPercentage'] ?? 0}%'),
                      if (product['discountExpiry'] != null)
                        Text('Expires: '
                            '${(product['discountExpiry'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDiscountDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDiscountDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String productName = '';
    double discount = 0;
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Discount Manually'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter product name' : null,
                    onSaved: (value) => productName = value!.trim(),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Discount %'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter discount %';
                      final d = double.tryParse(value);
                      if (d == null || d <= 0 || d > 100) return 'Enter a valid % (1-100)';
                      return null;
                    },
                    onSaved: (value) => discount = double.parse(value!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(expiryDate == null
                            ? 'No expiry date chosen'
                            : 'Expiry: ${expiryDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            expiryDate = picked;
                            // Rebuild dialog to show new date
                            Navigator.of(context).pop();
                            _showAddDiscountDialog(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (expiryDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please pick an expiry date.')),
                    );
                    return;
                  }
                  // Find product by name
                  final query = await FirebaseFirestore.instance
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
                    'discountPercentage': discount,
                    'discountExpiry': Timestamp.fromDate(expiryDate!),
                    'is_discounted': true,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Discount applied to "$productName"!')),
                  );
                }
              },
              child: const Text('Apply Discount'),
            ),
          ],
        );
      },
    );
  }
} 