import 'package:flutter/material.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({Key? key}) : super(key: key);

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  List<Map<String, dynamic>> discounts = [
    {
      'name': 'Chocolate Bar',
      'discountPercentage': 20.0,
      'discountExpiry': DateTime.now().add(const Duration(days: 5)),
      'imageUrl':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=50&q=80',
    },
    {
      'name': 'Fresh Milk 1L',
      'discountPercentage': 15.0,
      'discountExpiry': DateTime.now().add(const Duration(days: 3)),
      'imageUrl':
          'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=50&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promotions & Discounts')),
      body: discounts.isEmpty
          ? const Center(child: Text('No discounts applied yet.'))
          : ListView.builder(
              itemCount: discounts.length,
              itemBuilder: (context, index) {
                final product = discounts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading:
                        product['imageUrl'] != null &&
                            product['imageUrl'].toString().isNotEmpty
                        ? Image.network(
                            product['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(
                      product['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discount: ${product['discountPercentage'] ?? 0}%',
                        ),
                        if (product['discountExpiry'] != null)
                          Text(
                            'Expires: ${(product['discountExpiry'] as DateTime).toLocal().toString().split(' ')[0]}',
                          ),
                      ],
                    ),
                  ),
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
    String imageUrl = '';
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Discount Manually'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter product name'
                            : null,
                        onSaved: (value) => productName = value!.trim(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Discount %',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter discount %';
                          final d = double.tryParse(value);
                          if (d == null || d <= 0 || d > 100)
                            return 'Enter a valid % (1-100)';
                          return null;
                        },
                        onSaved: (value) => discount = double.parse(value!),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Image URL (optional)',
                        ),
                        onSaved: (value) => imageUrl = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expiryDate == null
                                  ? 'No expiry date chosen'
                                  : 'Expiry: ${expiryDate!.toLocal().toString().split(' ')[0]}',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 7),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  expiryDate = picked;
                                });
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (expiryDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please pick an expiry date.'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        discounts.add({
                          'name': productName,
                          'discountPercentage': discount,
                          'discountExpiry': expiryDate,
                          'imageUrl': imageUrl,
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Discount applied to \"$productName\"!',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Apply Discount'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
