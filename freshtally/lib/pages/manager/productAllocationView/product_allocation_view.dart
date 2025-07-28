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

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name (Adjusted to 'productName' for consistency)
                            Text(
                              product['productName'] ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Category (Adjusted to 'category' for consistency)
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

                            // Price and Discount (Adjusted to 'price' and 'discountPercentage' for consistency)
                            Row(
                              children: [
                                Text(
                                  '${(product['price'] as num?)?.toStringAsFixed(0) ?? 'N/A'} UGX', // Adjusted to num? and toStringAsFixed(0) for consistency
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (product['discountPercentage'] != null &&
                                    (product['discountPercentage'] as num) >
                                        0) // Cast to num for comparison
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

                            // Location Details
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

    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          'Floor: $floor, Shelf: $shelf, Pos: $position', // More descriptive
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  String _formatPosition(String position) {
    if (position.isEmpty) return 'N/A'; // Handle empty position more gracefully
    return position[0].toUpperCase() + position.substring(1).toLowerCase();
  }
}
