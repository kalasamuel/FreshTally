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
import 'package:freshtally/pages/shelfStaff/settings/settings_page.dart';

class DiscountsAndPromotionsPage extends StatelessWidget {
  final String? highlightProductName;

  const DiscountsAndPromotionsPage({super.key, this.highlightProductName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> discounts = [
      {
        'category': 'Hot Deals',
        'items': [
          {
            'image': 'https://placehold.co/60x60/E0E0E0/FFFFFF?text=Chocolate',
            'title': '50% OFF Chocolate Bar',
            'description': 'Enjoy half price on all chocolate bars!',
            'originalPrice': 'UGX 5,000',
            'discountedPrice': 'UGX 2,500',
            'expiry': 'Expires in 3 days',
          },
          {
            'image': 'https://placehold.co/60x60/E0E0E0/FFFFFF?text=Milk',
            'title': 'Buy 1 Get 1 Free – Fresh Milk 1L',
            'description': 'Limited time offer on fresh milk.',
            'originalPrice': 'UGX 4,000',
            'discountedPrice': 'UGX 4,000 (for 2)',
            'expiry': 'Expires in 5 days',
          },
          {
            'image': 'https://placehold.co/60x60/E0E0E0/FFFFFF?text=Cereal',
            'title': '20% OFF Breakfast Cereal',
            'description': 'Start your day right with discounted cereals.',
            'originalPrice': 'UGX 12,000',
            'discountedPrice': 'UGX 9,600',
            'expiry': 'Expires in 7 days',
          },
        ],
      },
      {
        'category': 'Weekly Specials',
        'items': [
          {
            'image': 'https://placehold.co/60x60/E0E0E0/FFFFFF?text=Rice',
            'title': 'Rice (5kg) - UGX 15,000',
            'description': 'Special price for bulk rice purchase.',
            'originalPrice': 'UGX 18,000',
            'discountedPrice': 'UGX 15,000',
            'expiry': 'Valid this week only',
          },
          {
            'image': 'https://placehold.co/60x60/E0E0E0/FFFFFF?text=Oil',
            'title': 'Cooking Oil (3L) - UGX 10,000',
            'description': 'Great savings on essential cooking oil.',
            'originalPrice': 'UGX 13,000',
            'discountedPrice': 'UGX 10,000',
            'expiry': 'Valid this week only',
          },
        ],
      },
      {
        'category': 'Seasonal Offers',
        'items': [
          {
            'image': 'https://placehold.co/60x60/E0E0E0/FFFFFF?text=Fruits',
            'title': 'Fresh Fruits - 15% OFF',
            'description': 'Seasonal fruits at a reduced price.',
            'originalPrice': 'Varies',
            'discountedPrice': '15% Off',
            'expiry': 'Limited stock',
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Offers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ...discounts.map((categoryData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryData['category'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...categoryData['items'].map<Widget>((item) {
                        return _buildDiscountItem(
                          context,
                          image: item['image'],
                          title: item['title'],
                          description: item['description'],
                          originalPrice: item['originalPrice'],
                          discountedPrice: item['discountedPrice'],
                          expiry: item['expiry'],
                          isHighlighted:
                              highlightProductName != null &&
                              item['title'].toLowerCase().contains(
                                highlightProductName!.toLowerCase(),
                              ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountItem(
    BuildContext context, {
    required String image,
    required String title,
    required String description,
    required String originalPrice,
    required String discountedPrice,
    required String expiry,
    bool isHighlighted = false,
  }) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isHighlighted
            ? const BorderSide(color: Color(0xFF4CAF50), width: 2.0)
            : BorderSide.none,
      ),
      color: isHighlighted ? const Color(0xFFE8F5E9) : const Color(0xFFF5F6FA),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original: $originalPrice',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      'Discounted: $discountedPrice',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                Text(
                  expiry,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
