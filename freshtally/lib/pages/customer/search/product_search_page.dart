// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:freshtally/pages/customer/product/products_details_page.dart';

// class ProductSearchPage extends StatefulWidget {
//   const ProductSearchPage({super.key});

//   @override
//   State<ProductSearchPage> createState() => _ProductSearchPageState();
// }

// class _ProductSearchPageState extends State<ProductSearchPage> {
//   String query = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Search Products')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               decoration: const InputDecoration(
//                 hintText: 'Search...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (val) {
//                 setState(() {
//                   query = val.trim().toLowerCase();
//                 });
//               },
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('products')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final products = snapshot.data!.docs.where((doc) {
//                   final name = doc['name'].toString().toLowerCase();
//                   return name.contains(query);
//                 }).toList();

//                 if (products.isEmpty) {
//                   return const Center(child: Text('No products found.'));
//                 }

//                 return ListView.builder(
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     final product = products[index];
//                     return ListTile(
//                       leading: Image.network(
//                         product['image_url'] ?? '',
//                         width: 50,
//                         height: 50,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.image_not_supported),
//                       ),
//                       title: Text(product['name']),
//                       subtitle: Text('${product['price']} UGX'),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 ProductDetailsPage(product: product),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:freshtally/pages/customer/product/products_details_page.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  String query = '';

  // Example static product data with location info
  final List<Map<String, dynamic>> allProducts = [
    {
      'name': 'Fresh Milk 1L',
      'price': 4500,
      'image_url':
          'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=50&q=80',
      'description': 'Delicious fresh milk, 1 liter pack.',
      'location': {'floor': 1, 'shelf': 5, 'position': 'middle'},
    },
    {
      'name': 'Brown Bread',
      'price': 3500,
      'image_url':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=50&q=80',
      'description': 'Whole wheat brown bread.',
      'location': {'floor': 1, 'shelf': 2, 'position': 'top'},
    },
    {
      'name': 'Eggs (Tray of 30)',
      'price': 12000,
      'image_url':
          'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=50&q=80',
      'description': 'Farm fresh eggs, tray of 30.',
      'location': {'floor': 2, 'shelf': 21, 'position': 'bottom'},
    },
    {
      'name': 'Apple Juice 500ml',
      'price': 2500,
      'image_url':
          'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=50&q=80',
      'description': 'Refreshing apple juice, 500ml bottle.',
      'location': {'floor': 1, 'shelf': 7, 'position': 'middle'},
    },
    {
      'name': 'Rice 2kg',
      'price': 14000,
      'image_url':
          'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=50&q=80',
      'description': 'Premium long grain rice, 2kg bag.',
      'location': {'floor': 2, 'shelf': 15, 'position': 'top'},
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter products by query
    final products = allProducts.where((product) {
      final name = product['name'].toString().toLowerCase();
      return name.contains(query);
    }).toList();

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
            child: products.isEmpty
                ? const Center(child: Text('No products found.'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final location =
                          product['location'] as Map<String, dynamic>?;

                      String locationText = '';
                      if (location != null) {
                        locationText =
                            'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Position: ${location['position'].toString().toUpperCase()}';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: Image.network(
                            product['image_url'] ?? '',
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          title: Text(product['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product['price']} UGX'),
                              if (locationText.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.shade400,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          locationText,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsPage(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
