import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final _firestore = FirebaseFirestore.instance;
  final _currencyFormat = NumberFormat.currency(symbol: 'UGX ');
  bool _isLoadingAi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Suggestions'),
        actions: [
          IconButton(
            icon: _isLoadingAi
                ? const CircularProgressIndicator()
                : const Icon(Icons.auto_awesome),
            onPressed: _generateAiSuggestions,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('supermarkets')
            .doc(widget.supermarketName)
            .collection('products')
            .where('stock', isGreaterThan: 0) // Only products in stock
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;
          if (products.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildProductCard(doc, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown Product';
    final price = (data['price'] ?? 0).toDouble();
    final currentDiscount = (data['discountPercentage'] ?? 0).toInt();
    final expiryDate = (data['expiryDate'] as Timestamp?)?.toDate();
    final salesVelocity = (data['salesVelocity'] ?? 0).toDouble();
    final stock = (data['stock'] ?? 0).toInt();
    final category = data['category'] ?? 'Uncategorized';

    // AI recommendation factors
    final daysToExpiry = expiryDate != null
        ? expiryDate.difference(DateTime.now()).inDays
        : 999;
    final aiRecommendedDiscount = _calculateAiDiscount(
      daysToExpiry: daysToExpiry,
      salesVelocity: salesVelocity,
      stock: stock,
      category: category,
    );

    return Card(
      margin: const EdgeInsets.all(8),
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
                      borderRadius: BorderRadius.circular(12),
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
            Text('Category: $category'),
            Text('Price: ${_currencyFormat.format(price)}'),
            if (expiryDate != null)
              Text(
                'Expires: ${DateFormat('MMM dd, yyyy').format(expiryDate)} '
                '($daysToExpiry days)',
                style: TextStyle(color: daysToExpiry <= 10 ? Colors.red : null),
              ),
            Text('Stock: $stock units'),
            Text('Sales Velocity: ${salesVelocity.toStringAsFixed(1)}/day'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Recommendation:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${aiRecommendedDiscount}% discount',
                        style: TextStyle(
                          color: aiRecommendedDiscount > 15
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'New price: ${_currencyFormat.format(price * (1 - aiRecommendedDiscount / 100))}',
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _applyDiscount(
                    doc.reference,
                    aiRecommendedDiscount,
                    price,
                    name,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply AI Suggestion'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAiDiscount({
    required int daysToExpiry,
    required double salesVelocity,
    required int stock,
    required String category,
  }) {
    // AI logic for discount calculation
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

  Future<void> _applyDiscount(
    DocumentReference productRef,
    int discount,
    double originalPrice,
    String productName,
  ) async {
    try {
      await productRef.update({
        'discountPercentage': discount,
        'discountedPrice': originalPrice * (1 - discount / 100),
        'lastDiscountUpdate': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied $discount% discount to $productName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply discount: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateAiSuggestions() async {
    setState(() => _isLoadingAi = true);

    try {
      // In a real app, you would call your AI/ML service here
      // This is a simulation that updates all products with AI suggestions
      final products = await _firestore
          .collection('supermarkets')
          .doc(widget.supermarketName)
          .collection('products')
          .get();

      for (final doc in products.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expiryDate = (data['expiryDate'] as Timestamp?)?.toDate();
        final daysToExpiry = expiryDate != null
            ? expiryDate.difference(DateTime.now()).inDays
            : 999;
        final salesVelocity = (data['salesVelocity'] ?? 0).toDouble();
        final stock = (data['stock'] ?? 0).toInt();
        final category = data['category'] ?? 'Uncategorized';

        final aiDiscount = _calculateAiDiscount(
          daysToExpiry: daysToExpiry,
          salesVelocity: salesVelocity,
          stock: stock,
          category: category,
        );

        await doc.reference.update({
          'aiRecommendedDiscount': aiDiscount,
          'aiLastCalculated': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI suggestions generated for all products'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI suggestion failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoadingAi = false);
    }
  }
}
