import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Still needed for currency formatting

class SmartPromotionsSuggestionsPage extends StatelessWidget {
  // supermarketName is kept for consistency in the constructor, but not used for data fetching
  final String supermarketName;

  SmartPromotionsSuggestionsPage({super.key, required this.supermarketName});

  // Hardcoded static product data for demonstration
  static final List<Map<String, dynamic>> _staticProducts = [
    {
      'name': 'Organic Milk (1L)',
      'price': 4500.0,
      'discountPercentage': 0, // Initial discount
      'expiryDate': DateTime.now().add(const Duration(days: 5)),
      'salesVelocity': 1.5, // units/day
      'stock': 70, // units
      'category': 'Dairy',
    },
    {
      'name': 'Artisan Bread',
      'price': 6000.0,
      'discountPercentage': 0,
      'expiryDate': DateTime.now().add(const Duration(days: 2)),
      'salesVelocity': 0.8,
      'stock': 25,
      'category': 'Baked Goods',
    },
    {
      'name': 'Premium Coffee Beans',
      'price': 18000.0,
      'discountPercentage': 0,
      'expiryDate': DateTime.now().add(const Duration(days: 120)),
      'salesVelocity': 0.3,
      'stock': 15,
      'category': 'Beverages',
    },
    {
      'name': 'Fresh Strawberries',
      'price': 7500.0,
      'discountPercentage': 0,
      'expiryDate': DateTime.now().add(const Duration(days: 3)),
      'salesVelocity': 3.0,
      'stock': 40,
      'category': 'Produce',
    },
    {
      'name': 'Canned Tuna',
      'price': 3500.0,
      'discountPercentage': 0,
      'expiryDate': DateTime.now().add(const Duration(days: 365)),
      'salesVelocity': 1.0,
      'stock': 100,
      'category': 'Canned Goods',
    },
    {
      'name': 'Assorted Chocolates',
      'price': 10000.0,
      'discountPercentage': 0,
      'expiryDate': DateTime.now().add(const Duration(days: 90)),
      'salesVelocity': 0.5,
      'stock': 30,
      'category': 'Snacks',
    },
  ];

  // Hardcoded static product suggestions (customers also buy)
  static final Map<String, List<String>> _staticProductSuggestions = {
    'Organic Milk (1L)': ['Cereal', 'Coffee Powder', 'Sugar'],
    'Artisan Bread': ['Butter', 'Jam', 'Cheese'],
    'Premium Coffee Beans': ['Coffee Maker', 'Milk Frother', 'Sugar'],
    'Fresh Strawberries': ['Yogurt', 'Whipped Cream', 'Pancake Mix'],
    'Canned Tuna': ['Mayonnaise', 'Bread', 'Salad Greens'],
    'Assorted Chocolates': ['Wine', 'Flowers', 'Gift Wrap'],
  };

  final _currencyFormat = NumberFormat.currency(symbol: 'UGX ');

  // AI logic for discount calculation (retained from original)
  int _calculateAiDiscount({
    required int daysToExpiry,
    required double salesVelocity,
    required int stock,
    required String category,
  }) {
    double discount = 0;

    // Factor 1: Expiry date urgency
    if (daysToExpiry <= 7) {
      discount += 30; // High discount for expiring soon
    } else if (daysToExpiry <= 14) {
      discount += 15;
    } else if (daysToExpiry <= 30) {
      discount += 5;
    }

    // Factor 2: Slow moving products
    if (salesVelocity < 2) {
      discount += 10 + (2 - salesVelocity) * 5;
    }

    // Factor 3: High stock levels
    if (stock > 50) {
      discount += 5 + (stock / 50).floor() * 2;
    }

    // Factor 4: Category-based adjustments
    switch (category.toLowerCase()) {
      case 'dairy':
      case 'meat':
      case 'produce':
        discount += 5; // Perishable goods get higher discounts
        break;
      case 'canned goods':
      case 'dry goods':
        discount -= 3; // Non-perishables get smaller discounts
        break;
    }

    // Clamp between 5% and 50% discount
    return discount.clamp(5, 50).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        title: const Text(
          'Smart Promotions Suggestions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        // Removed actions as there's no dynamic AI generation button
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info banner
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2196F3), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI-powered suggestions for discounts and associated products.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Suggestions list
            Expanded(
              child: _staticProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products available for suggestions.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add products to see smart promotion suggestions.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 0,
                      ),
                      itemCount: _staticProducts.length,
                      itemBuilder: (context, index) {
                        final data = _staticProducts[index];
                        final productName = data['name'] ?? 'Unknown Product';

                        final name = data['name'] ?? 'Unknown Product';
                        final price = (data['price'] ?? 0).toDouble();
                        final currentDiscount =
                            (data['discountPercentage'] ?? 0).toInt();
                        final expiryDate =
                            data['expiryDate']
                                as DateTime?; // Directly use DateTime
                        final salesVelocity = (data['salesVelocity'] ?? 0)
                            .toDouble();
                        final stock = (data['stock'] ?? 0).toInt();
                        final category = data['category'] ?? 'Uncategorized';

                        final daysToExpiry = expiryDate != null
                            ? expiryDate.difference(DateTime.now()).inDays
                            : 999;
                        final aiRecommendedDiscount = _calculateAiDiscount(
                          daysToExpiry: daysToExpiry,
                          salesVelocity: salesVelocity,
                          stock: stock,
                          category: category,
                        );

                        final List<String> associatedProducts =
                            _staticProductSuggestions[productName] ?? [];

                        return Card(
                          elevation: 0.1,
                          margin: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (currentDiscount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '$currentDiscount% OFF',
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Category: $category',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  'Price: ${_currencyFormat.format(price)}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                if (expiryDate != null)
                                  Text(
                                    'Expires: ${DateFormat('MMM dd, yyyy').format(expiryDate)} '
                                    '(${daysToExpiry < 0 ? 'Expired' : '$daysToExpiry days'})',
                                    style: TextStyle(
                                      color:
                                          daysToExpiry <= 10 &&
                                              daysToExpiry >= 0
                                          ? Colors.red
                                          : (daysToExpiry < 0
                                                ? Colors.red.shade900
                                                : Colors.black54),
                                    ),
                                  ),
                                Text(
                                  'Stock: $stock units',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  'Sales Velocity: ${salesVelocity.toStringAsFixed(1)}/day',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AI Discount Recommendation:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '$aiRecommendedDiscount% discount',
                                      style: TextStyle(
                                        color:
                                            aiRecommendedDiscount >
                                                currentDiscount
                                            ? Colors
                                                  .red
                                                  .shade700 // Suggest higher discount
                                            : Colors
                                                  .green
                                                  .shade700, // Suggest lower or same
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'New price: ${_currencyFormat.format(price * (1 - aiRecommendedDiscount / 100))}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (associatedProducts.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Customers also buy:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 6.0,
                                            runSpacing: 6.0,
                                            children: associatedProducts
                                                .map(
                                                  (item) => Chip(
                                                    label: Text(item),
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    labelStyle: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Removed the "Apply AI Suggestion" button as it's a static screen
                                // and there's no backend to apply changes to.
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
