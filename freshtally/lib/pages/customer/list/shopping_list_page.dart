import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShoppingListPage extends StatefulWidget {
  final String supermarketId; // Make sure to receive supermarketId
  const ShoppingListPage({
    super.key,
    required this.supermarketId,
  }); // Update constructor

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  // Method to get the shopping list items, fetching product details and filtering by supermarketId
  Stream<List<Map<String, dynamic>>> _getShoppingListItems() {
    // This assumes you have a document for the user's shopping list (e.g., using a fixed ID or user's actual ID).
    // You'll need to replace 'user_shopping_list_doc_id' with the actual document ID for the user's shopping list.
    // For a real app, you'd likely get the current user's ID from Firebase Auth.
    final String userId =
        'test_user_id'; // <--- IMPORTANT: Replace with actual user ID

    return FirebaseFirestore.instance
        .collection('shoppingLists') // Main collection for all shopping lists
        .doc(userId) // Document representing a specific user's shopping list
        .collection('items') // Subcollection of items in that user's list
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> items = [];
          for (var doc in snapshot.docs) {
            final itemData = doc.data();
            final productId = itemData['productId'];
            final quantity =
                itemData['quantity'] ??
                1; // Default quantity to 1 if not specified
            final checked =
                itemData['checked'] ??
                false; // Get checked status from shopping list item

            if (productId != null) {
              // Fetch product details for this item
              final productDoc = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .get();

              if (productDoc.exists) {
                final productData = productDoc.data();
                // Ensure the product belongs to the selected supermarket
                if (productData != null &&
                    productData['supermarketId'] == widget.supermarketId) {
                  items.add({
                    'id': doc.id, // ID of the shopping list item document
                    'productName': productData['name'],
                    'price': productData['price'],
                    'imageUrl': productData['image_url'],
                    'quantity': quantity,
                    'checked': checked,
                    'location':
                        productData['location'], // Include location from product data
                    'productId':
                        productId, // Add product ID for potential future use (e.g., product details page)
                  });
                }
              }
            }
          }
          return items;
        });
  }

  Future<void> _clearAll() async {
    // Show confirmation dialog first
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete all items from your shopping list? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    // Only proceed with deletion if the user confirmed
    if (confirmDelete == true) {
      try {
        final String userId =
            'test_user_id'; // <--- IMPORTANT: Replace with actual user ID
        final shoppingListRef = FirebaseFirestore.instance
            .collection('shoppingLists')
            .doc(userId)
            .collection('items');

        final snapshot = await shoppingListRef.get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All items cleared')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear all items: $e')),
        );
      }
    }
  }

  Future<void> _updateChecked(String docId, bool checked) async {
    final String userId =
        'test_user_id'; // <--- IMPORTANT: Replace with actual user ID
    await FirebaseFirestore.instance
        .collection('shoppingLists')
        .doc(userId)
        .collection('items')
        .doc(docId)
        .update({'checked': checked});
  }

  Future<void> _deleteItem(String docId) async {
    final String userId =
        'test_user_id'; // <--- IMPORTANT: Replace with actual user ID
    await FirebaseFirestore.instance
        .collection('shoppingLists')
        .doc(userId)
        .collection('items')
        .doc(docId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Removed from shopping list')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getShoppingListItems(), // Use the new stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('Your shopping list for this supermarket is empty.'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final String docId =
                  item['id']; // Get the shopping list item's ID
              final String productName =
                  item['productName'] ?? 'Unknown Product';
              final double price = (item['price'] ?? 0).toDouble();
              final String imageUrl = item['imageUrl'] ?? '';
              final int quantity = item['quantity'] ?? 1;
              final bool checked = item['checked'] ?? false;
              final Map<String, dynamic>? location =
                  item['location'] as Map<String, dynamic>?;

              String locationText = '';
              if (location != null) {
                locationText =
                    'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Pos: ${location['position'].toString().toUpperCase()}';
              }

              return Dismissible(
                key: Key(
                  docId,
                ), // Use the shopping list item's ID for Dismissible key
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteItem(docId),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  elevation: 0.1,
                  child: CheckboxListTile(
                    value: checked,
                    onChanged: (val) => _updateChecked(docId, val ?? false),
                    title: Text(
                      '$productName (x$quantity)', // Show quantity
                      style: TextStyle(
                        decoration: checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UGX ${price.toStringAsFixed(0)}'),
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
                    secondary: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit
                                .cover, // Added fit for better image display
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ), // Placeholder if no image URL
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<List<Map<String, dynamic>>>(
        stream:
            _getShoppingListItems(), // Check if the list is empty to show/hide FAB
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return Container(); // Hide FAB while loading or on error
          }
          final items = snapshot.data ?? [];
          return items.isNotEmpty
              ? FloatingActionButton(
                  tooltip: 'Clear All',
                  onPressed: _clearAll,
                  child: const Icon(Icons.delete),
                )
              : Container(); // Hide FAB if no items
        },
      ),
    );
  }
}
