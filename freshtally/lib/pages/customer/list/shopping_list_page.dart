import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth to get current user ID

class ShoppingListPage extends StatefulWidget {
  final String
  supermarketId; // This is the ID of the currently selected supermarket
  const ShoppingListPage({super.key, required this.supermarketId});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser; // To hold the current authenticated user

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    // Listen for auth state changes (optional, but good for real-time user status)
    // FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //   if (user != _currentUser) {
    //     setState(() {
    //       _currentUser = user;
    //     });
    //   }
    // });
  }

  // Helper method to show snackbar messages
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    // Ensure that the ScaffoldMessenger is available in the current context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Method to get the shopping list items for the current user and selected supermarket
  Stream<List<Map<String, dynamic>>> _getShoppingListItems() {
    // This stream should only be called if _currentUser is not null and supermarketId is not empty.
    // The checks for these conditions will be moved to the StreamBuilder's outer logic.
    final String userId = _currentUser!.uid; // Get the actual user ID

    return _firestore
        .collection(
          'customers',
        ) // Top-level collection for customer shopping lists
        .doc(userId) // Document for the current customer
        .collection('shoppingListItems') // Subcollection for their items
        .snapshots() // Listen for real-time changes
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> items = [];
          for (var doc in snapshot.docs) {
            final itemData = doc.data();
            final productId = itemData['productId'];
            final quantity = itemData['quantity'] ?? 1;
            final checked = itemData['checked'] ?? false;

            if (productId != null && productId.isNotEmpty) {
              // Fetch product details for this item
              final productDoc = await _firestore
                  .collection('products')
                  .doc(productId)
                  .get();

              if (productDoc.exists) {
                final productData = productDoc.data();
                // Crucial: Ensure the product belongs to the currently selected supermarket
                if (productData != null &&
                    productData['supermarketId'] == widget.supermarketId) {
                  items.add({
                    'id':
                        doc.id, // ID of the shopping list item document itself
                    'productName': productData['name'],
                    'price': (productData['price'] ?? 0).toDouble(),
                    'imageUrl':
                        productData['image_url'], // Assuming this field name
                    'quantity': quantity,
                    'checked': checked,
                    'location':
                        productData['location'], // Product's location info
                    'productId': productId, // Original product ID
                  });
                } else {
                  debugPrint(
                    'Product $productId not found or does not belong to supermarket ${widget.supermarketId}',
                  );
                  // Optionally, you might want to remove this invalid item from the user's shopping list here
                  // (e.g., if a product was moved or removed from the supermarket)
                  // await doc.reference.delete();
                }
              } else {
                debugPrint(
                  'Product $productId not found in "products" collection.',
                );
                // Optionally, remove non-existent product from shopping list
                // await doc.reference.delete();
              }
            }
          }
          return items;
        });
  }

  // Clears all items from the current user's shopping list.
  // Note: This function currently clears ALL items from a user's shopping list subcollection.
  // If you intend to only clear items SPECIFIC to the currently selected supermarket,
  // you would need to store `supermarketId` directly on each `shoppingListItem` document
  // and then filter the `shoppingListItemsSnapshot` by `supermarketId`.
  Future<void> _clearAll() async {
    if (_currentUser == null) {
      _showSnackBar('Login required to clear list.', isError: true);
      return;
    }
    final String userId = _currentUser!.uid;

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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final shoppingListItemsSnapshot = await _firestore
            .collection('customers')
            .doc(userId)
            .collection('shoppingListItems')
            .get();

        final writeBatch = _firestore.batch();
        for (final doc in shoppingListItemsSnapshot.docs) {
          // IMPORTANT: If you want to delete only items from THIS supermarket,
          // you need to either:
          // 1. Store supermarketId directly in each shoppingListItem and filter here.
          // 2. Fetch the product details for each item to check its supermarketId before batch deletion.
          // For now, it will delete ALL items in the user's 'shoppingListItems' subcollection.
          writeBatch.delete(doc.reference);
        }
        await writeBatch.commit();

        if (!mounted) return;
        _showSnackBar('✅ All items cleared from your shopping list.');
      } catch (e) {
        if (!mounted) return;
        _showSnackBar('❌ Failed to clear all items: $e', isError: true);
        debugPrint('Failed to clear shopping list: $e');
      }
    }
  }

  // Updates the 'checked' status of a specific item in the shopping list.
  Future<void> _updateChecked(String docId, bool checked) async {
    if (_currentUser == null) {
      _showSnackBar('Login required to update item status.', isError: true);
      return;
    }
    final String userId = _currentUser!.uid;
    try {
      await _firestore
          .collection('customers')
          .doc(userId)
          .collection('shoppingListItems')
          .doc(
            docId,
          ) // docId is the ID of the item in shoppingListItems subcollection
          .update({'checked': checked});
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update item status: $e', isError: true);
      debugPrint('Error updating shopping list item $docId: $e');
    }
  }

  // Deletes a specific item from the shopping list.
  Future<void> _deleteItem(String docId) async {
    if (_currentUser == null) {
      _showSnackBar('Login required to delete item.', isError: true);
      return;
    }
    final String userId = _currentUser!.uid;
    try {
      await _firestore
          .collection('customers')
          .doc(userId)
          .collection('shoppingListItems')
          .doc(docId)
          .delete();
      if (!mounted) return;
      _showSnackBar('Removed from shopping list.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to remove item: $e', isError: true);
      debugPrint('Error deleting shopping list item $docId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Please log in to view your shopping list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (widget.supermarketId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Supermarket not selected. Please go back and select a supermarket first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If logged in and supermarketId is present, proceed with StreamBuilder
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getShoppingListItems(), // Use the new stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading shopping list: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          final items =
              snapshot.data ?? []; // List of enriched shopping list items

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your shopping list for this supermarket is empty. Add some items!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final String docId =
                  item['id']; // ID of the shopping list item document
              final String productName =
                  item['productName'] ?? 'Unknown Product';
              final double price =
                  item['price']; // Price is already double from _getShoppingListItems
              final String imageUrl = item['imageUrl'] ?? '';
              final int quantity = item['quantity'] ?? 1;
              final bool checked = item['checked'] ?? false;
              final Map<String, dynamic>? productLocation =
                  item['location']
                      as Map<String, dynamic>?; // Product's location

              String locationText = '';
              if (productLocation != null &&
                  productLocation['floor'] != null &&
                  productLocation['shelf'] != null) {
                locationText =
                    'Floor: ${productLocation['floor']}, Shelf: ${productLocation['shelf']}';
                if (productLocation['position'] != null &&
                    productLocation['position'].toString().isNotEmpty) {
                  locationText +=
                      ', Pos: ${productLocation['position'].toString().toUpperCase()}';
                }
              }

              return Dismissible(
                key: Key(docId), // Unique key for Dismissible
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteItem(docId),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text(
                          'Are you sure you want to delete "$productName"?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  elevation: 0.1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // Consistent border radius
                  child: CheckboxListTile(
                    value: checked,
                    onChanged: (val) => _updateChecked(docId, val ?? false),
                    title: Text(
                      '$productName (x$quantity)',
                      style: TextStyle(
                        decoration: checked ? TextDecoration.lineThrough : null,
                        color: checked ? Colors.grey : Colors.black87,
                        fontWeight:
                            FontWeight.w600, // Make product name a bit bolder
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UGX ${price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14),
                        ),
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
                                  Flexible(
                                    // Use Flexible to prevent overflow of long location text
                                    child: Text(
                                      locationText,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13, // Adjusted font size
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Add ellipsis if text is too long
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    secondary: imageUrl.isNotEmpty
                        ? ClipRRect(
                            // Clip image to rounded rectangle
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getShoppingListItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError ||
              _currentUser == null ||
              widget.supermarketId.isEmpty) {
            return Container(); // Hide FAB if loading, error, not logged in, or no supermarket
          }
          final items = snapshot.data ?? [];
          return items.isNotEmpty
              ? FloatingActionButton(
                  tooltip: 'Clear All',
                  onPressed: _clearAll,
                  backgroundColor: Colors
                      .red
                      .shade600, // Make clear all more prominent with red
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.delete_forever),
                )
              : Container(); // Hide FAB if no items
        },
      ),
    );
  }
}
