import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              .collection(
                'products',
              ) // Assuming products are top-level and filtered by supermarketId
              .where('supermarketId', isEqualTo: supermarketId)
              .where(
                'discountPercentage',
                isGreaterThan: 0,
              ) // Filter by discountPercentage > 0
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
                  'No discounted products at the moment for this supermarket.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final products = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ), // Consistent padding
              itemCount: products.length,
              itemBuilder: (context, index) {
                final data = products[index].data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Unnamed Product';
                final originalPrice = (data['price'] ?? 0).toDouble();
                final discountedPrice = (data['discountedPrice'] ?? 0)
                    .toDouble();
                final discountPercentage = data['discountPercentage'] ?? 0;
                final expiryTimestamp = data['discountExpiry'] as Timestamp?;
                final expiryDate = expiryTimestamp?.toDate();

                return Card(
                  elevation: 0.1, // Slight elevation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
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
                                (data['image_url'] != null &&
                                    data['image_url'].isNotEmpty)
                                ? Image.network(
                                    data['image_url'],
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
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Original: UGX ${originalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration
                                      .lineThrough, // Strikethrough for original price
                                ),
                              ),
                              Text(
                                'Discounted: UGX ${discountedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(
                                    0xFFE91E63,
                                  ), // Red accent for discounted price
                                ),
                              ),
                              if (expiryDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Expires: ${DateFormat('MMM dd, yyyy').format(expiryDate)}',
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
                            '-${discountPercentage.toStringAsFixed(0)}%',
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
