import 'package:flutter/material.dart';

class SmartPromotionsSuggestionsPage extends StatelessWidget {
  SmartPromotionsSuggestionsPage({super.key});

  // Mock data for demonstration
  static const List<Map<String, dynamic>> suggestions = [
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
  ];

  Future<void> _applyDiscount(BuildContext context, String productName) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Discount applied to $productName')));
    // Simulate a delay for demonstration
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Discount Suggestions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Discount All Expiring Soon & Slow-Selling'),
              onPressed: () async {
                for (final product in suggestions) {
                  final reason =
                      product['reason']?.toString().toLowerCase() ?? '';
                  final salesVelocity =
                      product['salesVelocity']?.toString().toLowerCase() ?? '';
                  if (reason.contains('expiring') ||
                      reason.contains('low sales') ||
                      salesVelocity.contains('slow')) {
                    await _applyDiscount(context, product['name']);
                  }
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final product = suggestions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
          ),
        ],
      ),
    );
  }
}
