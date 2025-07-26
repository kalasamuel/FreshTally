import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Freshtally/pages/customer/product/products_details_page.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

class DiscountsAndPromotionsPage extends StatefulWidget {
  final String? highlightProductName;
  final String supermarketId; // Add this field

  const DiscountsAndPromotionsPage({
    super.key,
    this.highlightProductName,
    required this.supermarketId, // Make it required
  });

  @override
  State<DiscountsAndPromotionsPage> createState() =>
      _DiscountsAndPromotionsPageState();
}

class _DiscountsAndPromotionsPageState
    extends State<DiscountsAndPromotionsPage> {
  // Method to get the stream with the supermarketId filter
  Stream<QuerySnapshot> _getSupermarketDiscounts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where(
          'supermarketId',
          isEqualTo: widget.supermarketId,
        ) // Crucial filter
        .where(
          'discountPercentage',
          isGreaterThan: 0,
        ) // Only show products with discounts
        .orderBy('discountExpiry', descending: false) // Order by expiry
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      // AppBar is typically handled by the parent CustomerHomePage, but adding it here
      // if this page can be navigated to independently. If it's only a tab, remove this AppBar.
      appBar: AppBar(
        title: const Text('Discounts & Promotions'),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              _getSupermarketDiscounts(), // Use the method that includes the filter
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading discounts: ${snapshot.error}'),
              );
            }

            final products = snapshot.data!.docs;

            if (products.isEmpty) {
              return const Center(
                child: Text(
                  'No active discounts available for this supermarket.',
                ),
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
                    final imageUrl =
                        data['image_url'] ??
                        ''; // Corrected to 'image_url' based on previous context
                    final originalPrice = (data['price'] ?? 0).toDouble();
                    final discountedPrice = (data['discountedPrice'] ?? 0)
                        .toDouble();
                    final discount = (data['discountPercentage'] ?? 0)
                        .toDouble();
                    final expiryTimestamp =
                        data['discountExpiry'] as Timestamp?;
                    final expiry = expiryTimestamp?.toDate();
                    final daysLeft = expiry != null
                        ? expiry.difference(DateTime.now()).inDays
                        : -1;

                    return _buildDiscountItem(
                      context,
                      image: imageUrl,
                      productId: doc.id,
                      title: name,
                      description: '${discount.toStringAsFixed(0)}% OFF!',
                      originalPrice: 'UGX ${originalPrice.toStringAsFixed(0)}',
                      discountedPrice:
                          'UGX ${discountedPrice.toStringAsFixed(0)}',
                      expiry: daysLeft >= 0
                          ? 'Expires in $daysLeft days'
                          : 'Expired',
                      isHighlighted:
                          widget.highlightProductName != null &&
                          name.toLowerCase().contains(
                            widget.highlightProductName!.toLowerCase(),
                          ),
                      supermarketId:
                          widget.supermarketId, // Pass supermarketId here
                    );
                  }), // Add .toList() here
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
    required String supermarketId, // Receive supermarketId here
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              productId: productId,
              supermarketId: supermarketId, // Use the received supermarketId
            ),
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
                            width: 61,
                            height: 61,
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
