import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load notifications.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>? ?? {};
              final type = data['type']?.toString() ?? 'info';
              final message = data['message']?.toString() ?? 'No details';
              final timestamp =
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(_getIconForType(type), color: Colors.blue),
                  title: Text(
                    type.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(message),
                  trailing: Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'expiry':
        return Icons.warning;
      case 'restock':
        return Icons.inventory;
      case 'discount':
        return Icons.local_offer;
      case 'promotion':
        return Icons.star;
      case 'shelf_change':
        return Icons.swap_horiz;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
