// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class DiscountsAndPromotionsPage extends StatelessWidget {
//   const DiscountsAndPromotionsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final firestore = FirebaseFirestore.instance;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Discounts & Promotions')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: firestore
//             .collection('products')
//             .where('is_discounted', isEqualTo: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No discounts available now.'));
//           }

//           final products = snapshot.data!.docs;

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index].data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   leading: product['image_url'] != null
//                       ? Image.network(
//                           product['image_url'],
//                           width: 50,
//                           height: 50,
//                           fit: BoxFit.cover,
//                         )
//                       : const Icon(Icons.image_not_supported),
//                   title: Text(product['name']),
//                   subtitle: Text(
//                     'Price: ${product['price']} UGX\nCategory: ${product['category']}',
//                   ),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () {
//                     // TODO: Navigate to Product Details
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class DiscountsAndPromotionsPage extends StatelessWidget {
  final String? highlightProductName;
  const DiscountsAndPromotionsPage({super.key, this.highlightProductName});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'name': 'Chocolate Bar',
        'price': 2000,
        'category': 'Snacks',
        'image_url':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=50&q=80',
        'location': {'floor': 1, 'shelf': 3, 'position': 'top'},
      },
      {
        'name': 'Fresh Milk 1L',
        'price': 3500,
        'category': 'Dairy',
        'image_url':
            'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=50&q=80',
        'location': {'floor': 1, 'shelf': 5, 'position': 'middle'},
      },
      {
        'name': 'Apple Juice 500ml',
        'price': 1800,
        'category': 'Drinks',
        'image_url':
            'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=50&q=80',
        'location': {'floor': 2, 'shelf': 8, 'position': 'bottom'},
      },
    ];

    final highlightIndex = highlightProductName == null
        ? -1
        : products.indexWhere(
            (p) =>
                p['name'].toString().toLowerCase() ==
                highlightProductName!.toLowerCase(),
          );

    final scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (highlightIndex >= 0 && scrollController.hasClients) {
        scrollController.animateTo(
          highlightIndex * 120.0, // Approximate card height
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: products.isEmpty
          ? const Center(child: Text('No discounts available now.'))
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final location = product['location'] as Map<String, dynamic>?;

                String locationText = '';
                if (location != null) {
                  locationText =
                      'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Position: ${location['position'].toString().toUpperCase()}';
                }

                final isHighlighted = index == highlightIndex;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: isHighlighted ? 8 : 2,
                  color: isHighlighted ? Colors.yellow.shade100 : null,
                  child: ListTile(
                    leading: product['image_url'] != null
                        ? Image.network(
                            product['image_url'].toString(),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(product['name'].toString()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${product['price']} UGX'),
                        Text('Category: ${product['category']}'),
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
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to Product Details
                    },
                  ),
                );
              },
            ),
    );
  }
}
