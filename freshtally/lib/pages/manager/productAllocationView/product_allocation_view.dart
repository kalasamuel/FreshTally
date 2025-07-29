import 'package:Freshtally/pages/customer/product/products_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAllocationView extends StatefulWidget {
  final String supermarketId;

  const ProductAllocationView({super.key, required this.supermarketId});

  @override
  State<ProductAllocationView> createState() => _ProductAllocationViewState();
}

class _ProductAllocationViewState extends State<ProductAllocationView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Defensive check: if supermarketId is empty, display an error message
    if (widget.supermarketId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Locations')),
        body: const Center(
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
      appBar: AppBar(title: const Text('Product Locations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Adjusted stream to perform server-side search on 'name_lower'
              stream: _firestore
                  .collection('supermarkets')
                  .doc(widget.supermarketId)
                  .collection('products')
                  .where(
                    'name_lower', // Assuming 'name_lower' field exists for search
                    isGreaterThanOrEqualTo: _searchQuery,
                  )
                  .where(
                    'name_lower',
                    isLessThanOrEqualTo: '$_searchQuery\uf8ff',
                  )
                  .orderBy(
                    'name_lower',
                  ) // Order by the field used for range query
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No products available in this supermarket.'
                          : 'No products found matching "$_searchQuery".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final product = doc.data() as Map<String, dynamic>;
                    final location =
                        product['location'] as Map<String, dynamic>?;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(
                              productId: doc.id,
                              supermarketId: widget.supermarketId,
                              hideAddButton: true,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'Unnamed Product',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (product['category'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'Category: ${product['category']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Text(
                                    '${(product['current_price'] as num?)?.toStringAsFixed(0) ?? 'N/A'} UGX',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (product['discountPercentage'] != null &&
                                      (product['discountPercentage'] as num) >
                                          0)
                                    Text(
                                      '${product['discountPercentage']}% OFF',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Location:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (location == null ||
                                  (location['floor'] == null &&
                                      location['shelf'] == null &&
                                      location['position'] == null))
                                const Text(
                                  'No location data available',
                                  style: TextStyle(color: Colors.grey),
                                )
                              else
                                _buildLocationDetail(location),
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
        ],
      ),
    );
  }

  Widget _buildLocationDetail(Map<String, dynamic> location) {
    String floor = location['floor']?.toString() ?? 'N/A';
    String shelf = location['shelf']?.toString() ?? 'N/A';
    String position = _formatPosition(location['position']?.toString() ?? '');

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Floor: $floor | Shelf: $shelf | Position: $position',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPosition(String position) {
    if (position.isEmpty) return 'N/A'; // Handle empty position more gracefully
    return position[0].toUpperCase() + position.substring(1).toLowerCase();
  }
}
