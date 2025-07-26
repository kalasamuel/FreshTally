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
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText:
                    'Search products in this supermarket...', // More specific hint
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  query = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // MODIFIED: Incorporate supermarketId and name filtering directly into the Firestore query
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where(
                    'supermarketId',
                    isEqualTo: widget.supermarketId,
                  ) // Filter by supermarketId
                  .where(
                    'name',
                    isGreaterThanOrEqualTo: query,
                  ) // Start of case-insensitive search
                  .where(
                    'name',
                    isLessThanOrEqualTo: '$query\uf8ff',
                  ) // End of case-insensitive search
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong: ${snapshot.error}'),
                  ); // Better error message
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // This message will appear if no products are found for the given supermarketId
                  // or if no products match the search query within that supermarket.
                  return const Center(
                    child: Text('No products found in this supermarket.'),
                  );
                }

                // With the Firestore query filtering, you no longer need the client-side `where` clause.
                // The `snapshot.data!.docs` will already contain only the relevant products.
                final filtered = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final productData = product.data() as Map<String, dynamic>;
                    final productId = product.id;

                    final name = productData['name'] ?? '';
                    final price = productData['price'] ?? '';
                    final imageUrl = productData['image_url'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      elevation: 0.1,
                      child: ListTile(
                        leading: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 51,
                                height: 51,
                                fit: BoxFit
                                    .cover, // Added fit for better image display
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 51,
                              ), // Placeholder if no image URL
                        title: Text(name),
                        subtitle: Text('$price UGX'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(
                                productId: productId,
                                supermarketId:
                                    widget.supermarketId, // Pass supermarketId
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
