import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingListPage extends StatefulWidget {
  final String supermarketId;
  const ShoppingListPage({super.key, required this.supermarketId});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Adjusted to use the new shopping-list path under specific supermarket
  Stream<List<Map<String, dynamic>>> _getShoppingListItems() {
    final String userId = _currentUser!.uid;

    return _firestore
        .collection('customers')
        .doc(userId)
        .collection(
          'supermarkets',
        ) // Navigate into the supermarkets subcollection
        .doc(
          widget.supermarketId,
        ) // Reference the specific supermarket document
        .collection(
          'shopping-list',
        ) // Access the shopping-list subcollection for this supermarket
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> items = [];
          for (var doc in snapshot.docs) {
            final itemData = doc.data();
            final productId = itemData['productId'];
            // Using consistent naming for quantity and checked
            final quantity = itemData['quantity'] ?? 1;
            final isChecked =
                itemData['isChecked'] ?? false; // Adjusted to isChecked

            if (productId != null && productId.isNotEmpty) {
              final productDoc = await _firestore
                  .collection(
                    'supermarkets',
                  ) // Products are global under 'supermarkets'
                  .doc(
                    widget.supermarketId,
                  ) // Specific supermarket for the product
                  .collection('products') // Specific products collection
                  .doc(productId)
                  .get();

              if (productDoc.exists) {
                final productData = productDoc.data();
                items.add({
                  'id': doc.id,
                  'name':
                      productData?['name'] ??
                      'Unknown Product', // Adjusted to productName
                  'current_price': (productData?['current_price'] ?? 0)
                      .toDouble(),
                  'imageUrl':
                      productData?['imageUrl'] ?? '', // Adjusted to imageUrl
                  'quantity': quantity,
                  'isChecked': isChecked, // Adjusted to isChecked
                  'location': productData?['location'],
                  'productId': productId,
                });
              } else {
                debugPrint(
                  'Product $productId not found in "products" collection of supermarket ${widget.supermarketId}.',
                );
              }
            }
          }
          return items;
        });
  }

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
            'Are you sure you want to delete all items from your shopping list for this supermarket? This action cannot be undone.',
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
        // Adjusted Firestore path for clearing all items
        final shoppingListItemsSnapshot = await _firestore
            .collection('customers')
            .doc(userId)
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('shopping-list')
            .get();

        final writeBatch = _firestore.batch();
        for (final doc in shoppingListItemsSnapshot.docs) {
          writeBatch.delete(doc.reference);
        }
        await writeBatch.commit();

        if (!mounted) return;
        _showSnackBar(
          '✅ All items cleared from your shopping list for this supermarket.',
        );
      } catch (e) {
        if (!mounted) return;
        _showSnackBar('❌ Failed to clear all items: $e', isError: true);
        debugPrint('Failed to clear shopping list: $e');
      }
    }
  }

  Future<void> _updateChecked(String docId, bool isChecked) async {
    // Adjusted parameter name
    if (_currentUser == null) {
      _showSnackBar('Login required to update item status.', isError: true);
      return;
    }
    final String userId = _currentUser!.uid;
    try {
      // Adjusted Firestore path for updating item status
      await _firestore
          .collection('customers')
          .doc(userId)
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('shopping-list')
          .doc(docId)
          .update({'isChecked': isChecked}); // Adjusted field name
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update item status: $e', isError: true);
      debugPrint('Error updating shopping list item $docId: $e');
    }
  }

  Future<void> _deleteItem(String docId) async {
    if (_currentUser == null) {
      _showSnackBar('Login required to delete item.', isError: true);
      return;
    }
    final String userId = _currentUser!.uid;
    try {
      // Adjusted Firestore path for deleting an item
      await _firestore
          .collection('customers')
          .doc(userId)
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('shopping-list')
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

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getShoppingListItems(),
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

          final items = snapshot.data ?? [];

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
              final String docId = item['id'];
              // Using consistent naming
              final String productName = item['name'];
              final double price = item['current_price'];
              final String imageUrl = item['imageUrl'];
              final int quantity = item['quantity'];
              final bool isChecked = item['isChecked']; // Adjusted to isChecked
              final Map<String, dynamic>? productLocation = item['location'];

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
                key: Key(docId),
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
                  ),
                  child: CheckboxListTile(
                    value: isChecked, // Using isChecked
                    onChanged: (val) => _updateChecked(docId, val ?? false),
                    title: Text(
                      '$productName (x$quantity)',
                      style: TextStyle(
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null, // Using isChecked
                        color: isChecked
                            ? Colors.grey
                            : Colors.black87, // Using isChecked
                        fontWeight: FontWeight.w600,
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
                                    child: Text(
                                      locationText,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
            return Container();
          }
          final items = snapshot.data ?? [];
          return items.isNotEmpty
              ? FloatingActionButton(
                  tooltip: 'Clear All',
                  onPressed: _clearAll,
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.delete_forever),
                )
              : Container();
        },
      ),
    );
  }
}
