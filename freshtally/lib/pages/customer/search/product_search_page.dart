import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Freshtally/pages/customer/product/products_details_page.dart';

class ProductSearchPage extends StatefulWidget {
  final String supermarketId;
  const ProductSearchPage({super.key, required this.supermarketId});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  String _searchQuery = ''; // Renamed `query` to `_searchQuery` for clarity
  final TextEditingController _searchController =
      TextEditingController(); // Added a controller for the TextField

  @override
  void initState() {
    super.initState();
    // No need to add listener here as we will use the onChanged callback directly
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Defensive check: if supermarketId is empty, display an error message
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
                  'Supermarket not selected or invalid. Please go back and select a supermarket.',
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
      backgroundColor: const Color(0xFFFFFFFF), // Set background color
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController, // Link controller to TextField
              decoration: InputDecoration(
                hintText:
                    'Search products in ${widget.supermarketId}...', // Dynamic hint
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ), // Added color for consistency
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ), // Rounded corners for consistency
                  borderSide: BorderSide.none, // No border line
                ),
                filled: true,
                fillColor: Colors.grey[200], // Background color for consistency
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ), // Padding
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val
                      .trim()
                      .toLowerCase(); // Update _searchQuery for filtering
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where(
                    'supermarketId',
                    isEqualTo: widget.supermarketId,
                  ) // Filter by supermarketId
                  .where(
                    'name_lower',
                    isGreaterThanOrEqualTo: _searchQuery,
                  ) // Search on lowercase name
                  .where(
                    'name_lower',
                    isLessThanOrEqualTo: '$_searchQuery\uf8ff',
                  )
                  .orderBy(
                    'name_lower',
                  ) // Order for efficient `startAt`/`endAt` queries
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading products: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No products available in this supermarket.'
                            : 'No products found matching "${_searchQuery}" in this supermarket.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final productData = product.data() as Map<String, dynamic>;
                    final productId = product.id;

                    final String name =
                        productData['name'] ?? 'Unnamed Product';
                    final num price =
                        productData['price'] ?? 0; // Use num for flexibility
                    final String imageUrl =
                        productData['image_url'] ??
                        ''; // Assuming 'image_url' field
                    // Optional: Get location info if available
                    // final Map<String, dynamic>? location = productData['location'] as Map<String, dynamic>?;
                    // String locationText = '';
                    // if (location != null) {
                    //   locationText = 'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Position: ${location['position'].toString().toUpperCase()}';
                    // }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      elevation: 0.1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), // Consistent border radius
                      child: ListTile(
                        leading: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 51,
                                height: 51,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  size: 51,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 51,
                                color: Colors.grey,
                              ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'UGX ${price.toStringAsFixed(0)}',
                        ), // Format price
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(
                                productId: productId,
                                supermarketId: widget.supermarketId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
