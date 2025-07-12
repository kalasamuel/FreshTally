import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freshtally/pages/customer/product/products_details_page.dart';
import 'package:intl/intl.dart';

class DiscountsAndPromotionsPage extends StatelessWidget {
  final String? highlightProductName;

  const DiscountsAndPromotionsPage({super.key, this.highlightProductName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('discountPercentage', isGreaterThan: 0)
              .orderBy('discountExpiry')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading discounts.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!.docs;

            if (products.isEmpty) {
              return const Center(
                child: Text('No active discounts at the moment.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Offers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...products.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? '';
                    final imageUrl = data['imageUrl'] ?? '';
                    final originalPrice = (data['price'] ?? 0).toDouble();
                    final discountedPrice = (data['discountedPrice'] ?? 0)
                        .toDouble();
                    final discount = (data['discountPercentage'] ?? 0)
                        .toDouble();
                    final expiry = (data['discountExpiry'] as Timestamp)
                        .toDate();
                    final daysLeft = expiry.difference(DateTime.now()).inDays;

                    return _buildDiscountItem(
                      context,
                      image: imageUrl,
                      productId: doc.id,
                      title: name,
                      description: '$discount% OFF!',
                      originalPrice: 'UGX ${originalPrice.toStringAsFixed(0)}',
                      discountedPrice:
                          'UGX ${discountedPrice.toStringAsFixed(0)}',
                      expiry: daysLeft >= 0
                          ? 'Expires in $daysLeft days'
                          : 'Expired',
                      isHighlighted:
                          highlightProductName != null &&
                          name.toLowerCase().contains(
                            highlightProductName!.toLowerCase(),
                          ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscountItem(
    BuildContext context, {
    required String image,
    required String title,
    required String productId,
    required String description,
    required String originalPrice,
    required String discountedPrice,
    required String expiry,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(productId: productId),
          ),
        );
      },
      child: Card(
        elevation: 0.1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isHighlighted
              ? const BorderSide(color: Color(0xFF4CAF50), width: 2.0)
              : BorderSide.none,
        ),
        color: isHighlighted
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFF5F6FA),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
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
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Original: $originalPrice',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        'Discounted: $discountedPrice',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    expiry,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
