// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final firestore = FirebaseFirestore.instance;
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: firestore
//             .collection('notifications')
//             .where('user_id', isEqualTo: currentUser?.uid) // personal
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No notifications yet.'));
//           }

//           final notifications = snapshot.data!.docs;

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final data = notifications[index].data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 6),
//                 child: ListTile(
//                   leading: Icon(
//                     _getIconForType(data['type']),
//                     color: Colors.blue,
//                   ),
//                   title: Text(data['type']?.toString().toUpperCase() ?? 'INFO'),
//                   subtitle: Text(data['message'] ?? 'No details'),
//                   trailing: Text(
//                     _formatTimestamp(data['timestamp']),
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   IconData _getIconForType(String? type) {
//     switch (type) {
//       case 'expiry':
//         return Icons.warning;
//       case 'restock':
//         return Icons.inventory;
//       case 'discount':
//         return Icons.local_offer;
//       case 'promotion':
//         return Icons.star;
//       case 'shelf_change':
//         return Icons.swap_horiz;
//       default:
//         return Icons.notifications;
//     }
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) return '';
//     final dt = timestamp.toDate();
//     return '${dt.day}/${dt.month}/${dt.year}';
//   }
// }

import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example static notifications data
    final notifications = [
      {
        'type': 'expiry',
        'message': 'Your milk will expire in 2 days.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'type': 'restock',
        'message': 'Bread is back in stock!',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'type': 'discount',
        'message': '10% off on all cereals this week.',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'type': 'promotion',
        'message': 'Buy 1 Get 1 Free on selected juices.',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'type': 'shelf_change',
        'message': 'Eggs have moved to Shelf B2.',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final data = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      _getIconForType(data['type'] as String?),
                      color: Colors.blue,
                    ),
                    title: Text(
                      (data['type']?.toString().toUpperCase() ?? 'INFO'),
                    ),
                    subtitle: Text(
                      (data['message'] ?? 'No details').toString(),
                    ),
                    trailing: Text(
                      _formatTimestamp(data['timestamp'] as DateTime?),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForType(String? type) {
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

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
