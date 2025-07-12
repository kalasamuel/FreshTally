import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freshtally/pages/customer/product/products_details_page.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

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
                hintText: 'Search...',
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
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }

                final filtered = snapshot.data!.docs.where((doc) {
                  final name = doc['name']?.toString().toLowerCase() ?? '';
                  return name.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final productData = product.data() as Map<String, dynamic>;
                    final productId = product.id;

                    final name = productData['name'] ?? '';
                    final price = productData['price'] ?? '';
                    final imageUrl = productData['image_url'] ?? '';
                    // final location =
                    //     productData['location'] as Map<String, dynamic>?;

                    // String locationText = '';
                    // if (location != null) {
                    //   locationText =
                    //       'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Position: ${location['position'].toString().toUpperCase()}';
                    // }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      elevation: 0.1,
                      child: ListTile(
                        leading: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                        title: Text(name),
                        // subtitle: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text('$price UGX'),
                        //     if (locationText.isNotEmpty)
                        //       Padding(
                        //         padding: const EdgeInsets.only(top: 6.0),
                        //         child: Container(
                        //           padding: const EdgeInsets.symmetric(
                        //             horizontal: 8,
                        //             vertical: 4,
                        //           ),
                        //           decoration: BoxDecoration(
                        //             color: Colors.green.shade50,
                        //             borderRadius: BorderRadius.circular(8),
                        //             border: Border.all(
                        //               color: Colors.green.shade400,
                        //               width: 1,
                        //             ),
                        //           ),
                        //           child: Row(
                        //             mainAxisSize: MainAxisSize.min,
                        //             children: [
                        //               const Icon(
                        //                 Icons.location_on,
                        //                 color: Colors.green,
                        //                 size: 18,
                        //               ),
                        //               const SizedBox(width: 4),
                        //               Text(
                        //                 locationText,
                        //                 style: const TextStyle(
                        //                   color: Colors.green,
                        //                   fontWeight: FontWeight.bold,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //   ],
                        // ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(productId: productId),
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
