import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  String _selectedFilter = 'All';
  final _filters = const ['All', 'Staff', 'Expiry'];

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    final base = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true);
    switch (_selectedFilter) {
      case 'Staff':
        return base.where('type', isEqualTo: 'staff_signup').snapshots();
      case 'Expiry':
        return base.where('type', isEqualTo: 'promo_expiry').snapshots();
      default:
        return base.snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _filterRow(),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _stream(),
                builder: (ctx, snap) {
                  if (snap.hasError) {
                    return const Center(
                      child: Text('Error loading notifications'),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('Nothing here yet'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final n = docs[i].data();
                      return _buildCard(n, docs[i].id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterRow() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: _filters.map(_buildFilterChip).toList()),
  );

  Widget _buildFilterChip(String label) {
    final selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: const Color(0xFF4CAF50),
        onSelected: (_) => setState(() => _selectedFilter = label),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> n, String docId) {
    final type = n['type'] as String;
    final createdAt = n['createdAt'] as Timestamp?;
    final time = createdAt != null
        ? DateFormat('MMM d, h:mm a').format(createdAt.toDate())
        : '';
    final title = n['title'] ?? '';
    final message = n['message'] ?? '';
    final payload = n['payload'] as Map<String, dynamic>? ?? {};

    IconData icon;
    Color cardColor, borderColor, iconColor;

    switch (type) {
      case 'staff_signup':
        icon = Icons.person_add_alt_1;
        cardColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF81C784);
        iconColor = const Color(0xFF388E3C);
        break;
      case 'promo_expiry':
        icon = Icons.timer;
        cardColor = const Color(0xFFFFF3E0);
        borderColor = const Color(0xFFFFB74D);
        iconColor = const Color(0xFFF57C00);
        break;
      default:
        icon = Icons.notifications;
        cardColor = Colors.white;
        borderColor = Colors.grey.shade200;
        iconColor = Colors.blueGrey;
    }

    // quick actions
    final buttons = <Widget>[
      TextButton(
        onPressed: () => FirebaseFirestore.instance
            .collection('notifications')
            .doc(docId)
            .update({'isRead': true}),
        child: const Text('Mark read'),
      ),
    ];

    if (type == 'staff_signup') {
      buttons.insert(
        0,
        TextButton(
          onPressed: () {
            Clipboard.setData(
              ClipboardData(text: payload['verificationCode'] ?? ''),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Code copied')));
          },
          child: const Text('Copy code'),
        ),
      );
    } else if (type == 'promo_expiry') {
      buttons.insert(
        0,
        TextButton(onPressed: () {}, child: const Text('View')),
      );
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            if (type == 'staff_signup' &&
                payload['verificationCode'] != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                'Code: ${payload['verificationCode']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(spacing: 8, children: buttons),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
