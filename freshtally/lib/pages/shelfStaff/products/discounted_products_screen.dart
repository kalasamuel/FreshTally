import 'package:Freshtally/pages/customer/product/products_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Promotion {
  final String promotionId;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double originalPrice;
  final double discountPercentage;
  final double discountedPrice;
  final DateTime discountExpiry;
  final DateTime createdAt;

  Promotion({
    required this.promotionId,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.discountExpiry,
    required this.createdAt,
  });

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      promotionId: doc.id,
      productId: data['productId'] ?? '',
      productName: data['name'] ?? 'Unnamed Promotion',
      productImageUrl: data['imageUrl'], // Using 'imageUrl' from Promotion
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      discountedPrice: (data['discountedPrice'] ?? 0).toDouble(),
      discountExpiry: (data['discountExpiry'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

// --- DiscountedProductsScreen Widget ---
class DiscountedProductsScreen extends StatelessWidget {
  final String supermarketId;

  const DiscountedProductsScreen({super.key, required this.supermarketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Consistent background color
      appBar: AppBar(
        backgroundColor: const Color(
          0xFFFFFFFF,
        ), // AppBar background color matching ShelfMappingPage
        elevation: 0.0, // No shadow
        title: const Text(
          'Discounted Products',
          style: TextStyle(
            fontSize: 24, // Larger font size
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Darker text color
          ),
        ),
        centerTitle: true, // Center the title
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ), // Back button color
      ),
      body: SafeArea(
        // Use SafeArea for consistent padding
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('supermarkets')
              .doc(supermarketId)
              .collection(
                'promotions',
              ) // Fetch from the 'promotions' subcollection
              .where(
                'discountPercentage',
                isGreaterThan: 0,
              ) // Ensure there's a discount
              .where(
                'discountExpiry',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
              ) // Only show active promotions
              .orderBy(
                'discountExpiry',
                descending: false,
              ) // Order by expiry date
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No active discounted products at the moment for this supermarket.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Map the QuerySnapshot documents to Promotion objects
            final promotions = snapshot.data!.docs
                .map((doc) => Promotion.fromFirestore(doc))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ), // Consistent padding
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promotion = promotions[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(
                          productId: promotion.productId,
                          supermarketId: supermarketId,
                          hideAddButton: true,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0.1, // Slight elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rounded corners
                    ),
                    color: const Color(
                      0xFFF5F6FA,
                    ), // Background color matching input fields
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ), // Spacing between cards
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Product Image (if available) or a placeholder icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  (promotion.productImageUrl != null &&
                                      promotion.productImageUrl!.isNotEmpty)
                                  ? Image.network(
                                      promotion.productImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                    )
                                  : const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promotion
                                      .productName, // Use promotion's product name
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Original: UGX ${promotion.originalPrice.toStringAsFixed(0)}', // Use promotion's original price
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration
                                        .lineThrough, // Strikethrough for original price
                                  ),
                                ),
                                Text(
                                  'Discounted: UGX ${promotion.discountedPrice.toStringAsFixed(0)}', // Use promotion's discounted price
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                      0xFFE91E63,
                                    ), // Red accent for discounted price
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Expires: ${DateFormat('MMM dd, yyyy').format(promotion.discountExpiry)}', // Use promotion's expiry date
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Discount percentage badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4CAF50,
                              ), // Green background for badge
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${promotion.discountPercentage.toStringAsFixed(0)}%', // Use promotion's discount percentage
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
