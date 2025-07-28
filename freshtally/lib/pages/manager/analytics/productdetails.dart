import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final String supermarketId;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    required this.supermarketId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<DocumentSnapshot> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProductDetails();
  }

  Future<DocumentSnapshot> _fetchProductDetails() {
    // Construct the full path to the product document
    return FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(widget.supermarketId)
        .collection('products')
        .doc(widget.productId)
        .get();
  }

  // Helper function to format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('MMM d, yyyy h:mm a').format(timestamp.toDate());
  }

  // Helper function for a detail row
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isLargeText = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for labels
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isLargeText ? 17 : 15,
                color: valueColor ?? Colors.black54,
              ),
              overflow: TextOverflow.clip, // Prevent overflow if text is long
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading product details: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _productFuture =
                              _fetchProductDetails(); // Retry fetch
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor, // Use your app's primary color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Product not found or deleted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          }

          final productData = snapshot.data!.data() as Map<String, dynamic>;
          final String productName = productData['name'] ?? 'N/A';
          final double currentPrice = (productData['current_price'] ?? 0)
              .toDouble();
          final String sku = productData['sku'] ?? 'N/A';
          final Timestamp? createdAt = productData['created_at'] as Timestamp?;
          final Timestamp? lastSoldAt =
              productData['last_sold_at'] as Timestamp?;
          final int stockQuantity =
              productData['stock_quantity'] ??
              0; // Assuming stock_quantity exists
          final Timestamp? expiryDate =
              productData['expiry_date']
                  as Timestamp?; // Assuming expiry_date exists
          final String description =
              productData['description'] ?? 'No description available.';
          final String category = productData['category'] ?? 'Uncategorized';
          final String imageUrl =
              productData['imageUrl'] ?? ''; // Assuming an imageUrl field

          // Determine expiry status for display
          String expiryStatus = 'N/A';
          Color expiryColor = Colors.black54;
          if (expiryDate != null) {
            final now = DateTime.now();
            final daysUntilExpiry = expiryDate.toDate().difference(now).inDays;
            if (daysUntilExpiry < 0) {
              expiryStatus =
                  'Expired (${DateFormat('MMM d, yyyy').format(expiryDate.toDate())})';
              expiryColor = Colors.red.shade700;
            } else if (daysUntilExpiry <= 7) {
              expiryStatus = 'Expiring soon ($daysUntilExpiry days)';
              expiryColor = Colors.orange.shade700;
            } else if (daysUntilExpiry <= 30) {
              expiryStatus = 'Expires in $daysUntilExpiry days';
              expiryColor = Colors.amber.shade700;
            } else {
              expiryStatus = DateFormat(
                'MMM d, yyyy',
              ).format(expiryDate.toDate());
              expiryColor = Colors.green.shade700;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Product Image (if available)
              if (imageUrl.isNotEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                )
              else
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey[500],
                  ),
                ),

              // Product Name
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Current Price
              Text(
                'UGX ${currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).primaryColor, // Use app's primary color
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 40, thickness: 1),

              // Product Details Section
              _buildDetailRow('Product ID', widget.productId),
              _buildDetailRow('Supermarket ID', widget.supermarketId),
              _buildDetailRow('SKU', sku),
              _buildDetailRow('Category', category),
              _buildDetailRow(
                'Stock Quantity',
                stockQuantity.toString(),
                isLargeText: true,
                valueColor: stockQuantity < 10
                    ? Colors.red.shade700
                    : Colors.green.shade700,
              ),
              _buildDetailRow(
                'Expiry Date',
                expiryStatus,
                valueColor: expiryColor,
              ),
              _buildDetailRow('Created At', _formatTimestamp(createdAt)),
              _buildDetailRow('Last Sold At', _formatTimestamp(lastSoldAt)),

              const SizedBox(height: 20),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // You could add actions here, e.g., 'Edit Product', 'View Sales History'
            ],
          );
        },
      ),
    );
  }
}
