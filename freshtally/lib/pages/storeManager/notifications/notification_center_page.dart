import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('notifications')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final notifications = snapshot.data!.docs;

//           if (notifications.isEmpty) {
//             return const Center(child: Text('No notifications'));
//           }

//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final n = notifications[index];
//               return ListTile(
//                 title: Text(n['type']),
//                 subtitle: Text(n['status']),
//                 trailing: Text(
//                   (n['timestamp'] as Timestamp).toDate().toString(),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example static notifications data
    final notifications = [
      {
        'type': 'Stock Alert',
        'status': 'Low stock on Milk',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
      },
      {
        'type': 'Expiry Warning',
        'status': 'Eggs expiring soon',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'type': 'System',
        'status': 'New update available',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  title: Text(n['type'].toString()),
                  subtitle: Text(n['status'].toString()),
                  trailing: Text(
                    n['timestamp'].toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}
