import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Freshtally/pages/customer/product/products_details_page.dart';
// Import for DateFormat

class DiscountsAndPromotionsPage extends StatefulWidget {
  final String?
  highlightProductName; // For highlighting specific products, if used
  final String supermarketId; // Required: ID of the selected supermarket

  const DiscountsAndPromotionsPage({
    super.key,
    this.highlightProductName,
    required this.supermarketId,
  });

  @override
  State<DiscountsAndPromotionsPage> createState() =>
      _DiscountsAndPromotionsPageState();
}

class _DiscountsAndPromotionsPageState
    extends State<DiscountsAndPromotionsPage> {
  // Helper method to show snackbar messages
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Method to get the stream of discounted products for the specific supermarket
  Stream<QuerySnapshot> _getSupermarketDiscountsStream() {
    // Defensive check: If supermarketId is empty, we cannot query Firestore
    if (widget.supermarketId.isEmpty) {
      debugPrint(
        'DiscountsAndPromotionsPage: supermarketId is empty. Cannot fetch discounts.',
      );
      // Return an empty stream if supermarketId is not valid
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('products')
        .where(
          'supermarketId',
          isEqualTo: widget.supermarketId,
        ) // Filter by current supermarket
        .where(
          'discountPercentage',
          isGreaterThan: 0,
        ) // Only show products with an active discount
        .orderBy(
          'discountExpiry',
          descending: false,
        ) // Order by soonest expiry first
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Top-level defensive check for supermarketId
    if (widget.supermarketId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 16),
                Text(
                  'Supermarket not selected. Please go back and select a supermarket to view discounts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      // AppBar is placed here as it's part of this page's UI
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _getSupermarketDiscountsStream(), // Use the stream method
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // Display a more informative error message
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load discounts: ${snapshot.error}. Please try again.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Display message if no discounts are found
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No active discounts available for this supermarket at the moment. Check back later!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final products = snapshot.data!.docs;

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
                  // Use ListView.builder for efficient rendering of many items
                  ListView.builder(
                    shrinkWrap:
                        true, // Important for ListView inside SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final doc = products[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final name = data['name'] ?? '';
                      final imageUrl =
                          data['image_url'] ?? ''; // Assuming this field name
                      final originalPrice = (data['price'] ?? 0).toDouble();
                      final discountedPrice = (data['discountedPrice'] ?? 0)
                          .toDouble();
                      final discountPercentage =
                          (data['discountPercentage'] ?? 0).toDouble();
                      final expiryTimestamp =
                          data['discountExpiry'] as Timestamp?;
                      final expiry = expiryTimestamp?.toDate();
                      final daysLeft = expiry != null
                          ? expiry.difference(DateTime.now()).inDays
                          : -1;

                      String expiryText;
                      if (daysLeft >= 1) {
                        expiryText =
                            'Expires in $daysLeft day${daysLeft > 1 ? 's' : ''}';
                      } else if (daysLeft == 0) {
                        expiryText = 'Expires Today!';
                      } else {
                        expiryText = 'Expired';
                      }

                      return DiscountCard(
                        title:
                            '$name: UGX ${discountedPrice.toStringAsFixed(0)}',
                        subtitle:
                            'Was UGX ${originalPrice.toStringAsFixed(0)} • $expiryText',
                        cardColor: daysLeft <= 0
                            ? Colors
                                  .red
                                  .shade50 // Fixed: Use .shade50
                            : const Color(0xFFFFE0E6),
                        iconColor: daysLeft <= 0
                            ? Colors.red
                            : const Color(0xFFE91E63),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(
                                productId: doc.id,
                                supermarketId: widget.supermarketId,
                              ),
                            ),
                          );
                        },
                        image: imageUrl, // Pass image for the card
                        discountPercentage:
                            discountPercentage, // Pass discount percentage for display
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Reusing DiscountCard, but adding image and discountPercentage parameters ---
class DiscountCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String image; // Added for product image
  final double discountPercentage; // Added for percentage display
  final Color cardColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const DiscountCard({
    super.key,
    required this.title,
    this.subtitle,
    this.image = '', // Default empty string
    this.discountPercentage = 0.0, // Default 0
    this.cardColor = const Color(0xFFF5F6FA),
    this.iconColor = Colors.black87,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to top
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        width: 70, // Slightly larger image
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          size: 70,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 70,
                        color: Colors.grey,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            decoration: subtitle!.contains('Was UGX')
                                ? TextDecoration.lineThrough
                                : null, // Strikethrough original price
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Display Discount Percentage prominently
                    if (discountPercentage > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${discountPercentage.toStringAsFixed(0)}% OFF!',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
