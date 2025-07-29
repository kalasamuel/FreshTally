import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final String supermarketId;
  final bool hideAddButton;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    required this.supermarketId,
    this.hideAddButton = false,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _isAdding = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addToShoppingList(Map<String, dynamic> product) async {
    setState(() => _isAdding = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Please sign in to add items')),
        );
        return;
      }

      // Adjusted Firestore path to include supermarketId
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection(
            'supermarkets',
          ) // New collection for supermarkets under customer
          .doc(widget.supermarketId) // Specific supermarket document
          .collection(
            'shopping-list',
          ) // Shopping list specific to this supermarket
          .add({
            'productId': widget.productId,
            'supermarketId': widget
                .supermarketId, // Redundant but good for quick querying if needed
            'name':
                product['name'] ?? 'Unknown Product', // Adjusted to productName
            'current_price': product['current_price'] ?? 0,
            'discountedPrice':
                product['discountedPrice'] ?? product['cuurent_price'] ?? 0,
            'imageUrl': product['imageUrl'] ?? '', // Adjusted to imageUrl
            'location': product['location'] ?? {},
            'description': product['description'] ?? '',
            'isChecked': false, // Adjusted to isChecked for consistency
            'addedAt': FieldValue.serverTimestamp(), // Adjusted to addedAt
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Added to shopping list')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to add: $e')));
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Product not found.'));
          }

          final product = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          // Adjusted variable names to be consistent with 'name', 'imageUrl', 'isChecked', 'addedAt'
          final productName = product['name'] ?? 'Unknown Product';
          final price = (product['current_price'] ?? 0).toDouble();
          final discountedPrice = (product['discountedPrice'] ?? price)
              .toDouble();
          final discountPercentage = (product['discountPercentage'] ?? 0)
              .toDouble(); // Adjusted to discountPercentage
          final imageUrl = product['imageUrl'] ?? '';
          final description = product['description'] ?? '';
          final discountExpiry = (product['discountExpiry'] as Timestamp?)
              ?.toDate(); // Adjusted to discountExpiry
          final location = product['location'] as Map<String, dynamic>? ?? {};

          String locationText = '';
          if (location.isNotEmpty) {
            locationText =
                'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Position: ${location['position']?.toString().toUpperCase() ?? 'N/A'}';
          }

          final isDiscounted =
              discountPercentage > 0 && discountedPrice < price;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  Center(
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 100),
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    productName, // Used productName
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                /// Prices
                Center(
                  child: isDiscounted
                      ? Column(
                          children: [
                            Text(
                              'UGX ${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'UGX ${discountedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discount: ${discountPercentage.toStringAsFixed(0)}%', // Used discountPercentage
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Text(
                          'UGX ${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),
                const Divider(),

                const Text(
                  'Description:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description.isNotEmpty
                      ? description
                      : 'No description available.',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Location in Store:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (locationText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationText,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Text('Location not specified.'),

                const SizedBox(height: 24),
                if (!widget.hideAddButton)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isAdding
                            ? null
                            : () => _addToShoppingList(product),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: _isAdding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Add to Shopping List'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
