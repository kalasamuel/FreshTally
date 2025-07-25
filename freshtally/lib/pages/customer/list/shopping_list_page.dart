import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
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
        final snapshot = await FirebaseFirestore.instance
            .collection('shopping_list')
            .get();
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
    await FirebaseFirestore.instance
        .collection('shopping_list')
        .doc(docId)
        .update({'checked': checked});
  }

  Future<void> _deleteItem(String docId) async {
    await FirebaseFirestore.instance
        .collection('shopping_list')
        .doc(docId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Removed from shopping list')));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shopping_list')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data?.docs ?? [];

        return Scaffold(
          body: items.isEmpty
              ? const Center(child: Text('Your shopping list is empty.'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;
                    final checked = data['checked'] ?? false;

                    final location = data['location'] as Map<String, dynamic>?;

                    String locationText = '';
                    if (location != null) {
                      locationText =
                          'Floor: ${location['floor']}, Shelf: ${location['shelf']}, Position: ${location['position'].toString().toUpperCase()}';
                    }

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteItem(item.id),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        elevation: 0.1,
                        child: CheckboxListTile(
                          value: checked,
                          onChanged: (val) =>
                              _updateChecked(item.id, val ?? false),
                          title: Text(
                            data['name'] ?? '',
                            style: TextStyle(
                              decoration: checked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${data['price']} UGX'),
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
                            data['image_url'] ?? '',
                            width: 60,
                            height: 60,
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
                  onPressed: _clearAll, // Now calls the modified _clearAll
                  child: const Icon(Icons.delete),
                )
              : null,
        );
      },
    );
  }
}
