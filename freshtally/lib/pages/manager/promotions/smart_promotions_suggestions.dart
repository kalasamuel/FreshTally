import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Freshtally/pages/manager/promotions/testpromo.dart';

class SmartPromotionsSuggestionsPage extends StatefulWidget {
  final String supermarketName;

  const SmartPromotionsSuggestionsPage({
    super.key,
    required this.supermarketName,
  });

  @override
  State<SmartPromotionsSuggestionsPage> createState() =>
      _SmartPromotionsSuggestionsPageState();
}

class _SmartPromotionsSuggestionsPageState
    extends State<SmartPromotionsSuggestionsPage> {
  final _currencyFormat = NumberFormat.currency(symbol: 'UGX ');
  late PromotionModel _promotionModel;
  bool _isLoading = true; // To show loading state

  // Hardcoded static product data for demonstration
  // In a real application, this would come from a backend or local database
  static final List<Map<String, dynamic>> _staticProducts = [
    {
      'name': 'Organic Milk (1L)',
      'price': 4500.0,
      'discountPercentage': 0, // Initial discount (will be overwritten by ML)
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

  final List<Map<String, dynamic>> _promotions = [];

  @override
  void initState() {
    super.initState();
    _promotionModel = PromotionModel();
    _initModelAndCalculatePromotions();
  }

  Future<void> _initModelAndCalculatePromotions() async {
    await _promotionModel.loadModel();
    _calculatePromotions();
    setState(() {
      _isLoading = false;
    });
  }

  void _calculatePromotions() {
    _promotions.clear();
    for (var productData in _staticProducts) {
      final productName = productData['name'] ?? 'Unknown Product';
      final price = (productData['price'] ?? 0).toDouble();
      final expiryDate = productData['expiryDate'] as DateTime?;
      final salesVelocity = (productData['salesVelocity'] ?? 0).toDouble();
      final stock = (productData['stock'] ?? 0).toInt();
      final category = productData['category'] ?? 'Uncategorized';

      final daysToExpiry = expiryDate != null
          ? expiryDate.difference(DateTime.now()).inDays
          : 999;

      // Use the ML model for discount prediction
      final aiRecommendedDiscount = _promotionModel.predictDiscount(
        daysToExpiry: daysToExpiry,
        salesVelocity: salesVelocity,
        stock: stock,
        category: category,
      );

      // Use the ML model for associated products (or keep static for now if your model doesn't do this)
      final List<String> associatedProducts = _promotionModel
          .predictAssociatedProducts(productName);

      _promotions.add({
        'name': productName,
        'price': price,
        'aiRecommendedDiscount': aiRecommendedDiscount,
        'expiryDate': expiryDate,
        'daysToExpiry': daysToExpiry,
        'stock': stock,
        'salesVelocity': salesVelocity,
        'category': category,
        'associatedProducts': associatedProducts,
      });
    }
  }

  @override
  void dispose() {
    _promotionModel.dispose();
    super.dispose();
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
      ),
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _promotions.isEmpty
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
                      itemCount: _promotions.length,
                      itemBuilder: (context, index) {
                        final data = _promotions[index];
                        final name = data['name'];
                        final price = data['price'];
                        final aiRecommendedDiscount =
                            data['aiRecommendedDiscount'];
                        final expiryDate = data['expiryDate'] as DateTime?;
                        final daysToExpiry = data['daysToExpiry'];
                        final stock = data['stock'];
                        final salesVelocity = data['salesVelocity'];
                        final category = data['category'];
                        final List<String> associatedProducts =
                            data['associatedProducts'];

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
                                    if (aiRecommendedDiscount > 0)
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
                                          '$aiRecommendedDiscount% OFF',
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
                                        color: Colors
                                            .green
                                            .shade700, // Now always green, as it's the AI's best recommendation
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
