// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ShoppingListPage extends StatelessWidget {
//   const ShoppingListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Shopping List')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('shopping_list')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final items = snapshot.data!.docs;

//           if (items.isEmpty) {
//             return const Center(child: Text('Your shopping list is empty.'));
//           }

//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final item = items[index];
//               return Dismissible(
//                 key: Key(item.id),
//                 background: Container(color: Colors.red),
//                 onDismissed: (_) async {
//                   await item.reference.delete();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Removed from shopping list')),
//                   );
//                 },
//                 child: ListTile(
//                   leading: Image.network(
//                     item['image_url'] ?? '',
//                     width: 50,
//                     height: 50,
//                     errorBuilder: (_, __, ___) =>
//                         const Icon(Icons.image_not_supported),
//                   ),
//                   title: Text(item['name']),
//                   subtitle: Text('${item['price']} UGX'),
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

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  // Example static shopping list data with location info
  List<Map<String, dynamic>> items = [
    {
      'name': 'Fresh Milk 1L',
      'price': 4500,
      'image_url':
          'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=50&q=80',
      'checked': false,
      'location': {'floor': 1, 'shelf': 5, 'position': 'middle'},
    },
    {
      'name': 'Brown Bread',
      'price': 3500,
      'image_url':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=50&q=80',
      'checked': false,
      'location': {'floor': 1, 'shelf': 2, 'position': 'top'},
    },
    {
      'name': 'Eggs (Tray of 30)',
      'price': 12000,
      'image_url':
          'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=50&q=80',
      'checked': false,
      'location': {'floor': 2, 'shelf': 21, 'position': 'bottom'},
    },
  ];

  void _clearAll() {
    setState(() {
      items.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All items cleared')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('Your shopping list is empty.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final location = item['location'] as Map<String, dynamic>?;

                String locationText = '';
                if (location != null) {
                  locationText =
                      'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Position: ${location['position'].toString().toUpperCase()}';
                }

                return Dismissible(
                  key: Key(item['name']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      items.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from shopping list'),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    elevation: 0.1,
                    child: CheckboxListTile(
                      value: item['checked'] as bool? ?? false,
                      onChanged: (checked) {
                        setState(() {
                          item['checked'] = checked ?? false;
                        });
                      },
                      title: Text(
                        item['name'],
                        style: TextStyle(
                          decoration: (item['checked'] ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item['price']} UGX'),
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
                      secondary: Image.network(
                        item['image_url'] ?? '',
                        width: 50,
                        height: 50,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: items.isNotEmpty
          ? FloatingActionButton(
              tooltip: 'Clear All',
              onPressed: () {
                _clearAll();
              },
              child: const Icon(Icons.delete),
            )
          : null,
    );
  }
}
