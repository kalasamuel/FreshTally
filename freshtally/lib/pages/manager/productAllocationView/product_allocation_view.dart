import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAllocationView extends StatefulWidget {
  final String supermarketId; // Add supermarketId parameter

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
    return Scaffold(
      appBar: AppBar(title: const Text('Product Locations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
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
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Updated to use supermarket-specific products collection
              stream: _firestore
                  .collection('supermarkets')
                  .doc(widget.supermarketId)
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final product = doc.data() as Map<String, dynamic>;
                  final name = product['name']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
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
                            // Product Name
                            Text(
                              product['name'] ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Category
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

                            // Price and Supplier
                            Row(
                              children: [
                                Text(
                                  '${product['price']?.toStringAsFixed(2) ?? 'N/A'} UGX',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (product['discountPercentage'] != null &&
                                    product['discountPercentage'] > 0)
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

                            if (location == null)
                              const Text('No location data available')
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
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          'Floor ${location['floor']}, Shelf ${location['shelf']}, '
          '${_formatPosition(location['position'])}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  String _formatPosition(String position) {
    if (position.isEmpty) return position;
    return position[0].toUpperCase() + position.substring(1).toLowerCase();
  }
}
