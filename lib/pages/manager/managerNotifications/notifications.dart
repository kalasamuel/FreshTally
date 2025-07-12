import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManagerNotificationCenterPage extends StatefulWidget {
  const ManagerNotificationCenterPage({super.key});

  @override
  State<ManagerNotificationCenterPage> createState() =>
      _ManagerNotificationCenterPageState();
}

class _ManagerNotificationCenterPageState
    extends State<ManagerNotificationCenterPage> {
  String _selectedFilter = 'All';
  // Corrected and expanded the filters to match the UI chips
  final List<String> _filters = const [
    'All',
    'Staff',
    'Expiry',
    'Supplier',
    'Batch',
    'Sync',
    'Suggestion',
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    final base = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy(
          'createdAt',
          descending: true,
        ); // Assuming 'createdAt' for ordering

    switch (_selectedFilter) {
      case 'Staff':
        // Ensure this matches the 'type' field in Firestore for staff notifications
        return base.where('type', isEqualTo: 'staff_signup').snapshots();
      case 'Expiry':
        // Ensure this matches the 'type' field in Firestore for promo expiry notifications
        return base.where('type', isEqualTo: 'promo_expiry').snapshots();
      case 'Supplier':
        return base.where('type', isEqualTo: 'supplier').snapshots();
      case 'Batch':
        return base.where('type', isEqualTo: 'batch').snapshots();
      case 'Sync':
        return base.where('type', isEqualTo: 'sync').snapshots();
      case 'Suggestion':
        return base.where('type', isEqualTo: 'suggestion').snapshots();
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
            const SizedBox(height: 16),
            // Use the _filterRow widget here
            _filterRow(),
            const SizedBox(height: 16),
            Expanded(
              // Use the _stream() method to get the filtered stream
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream(), // Use the dynamic stream based on filter
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No notifications yet.'));
                  }

                  // No need for client-side filtering here, as it's done in _stream()
                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return _buildNotificationCard(doc);
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

  // Renamed for clarity and to indicate it's a widget builder
  Widget _filterRow() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: _filters.map((label) => _buildFilterChip(label)).toList(),
    ),
  );

  Widget _buildFilterChip(String label) {
    final selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFFF5F6FA),
        onSelected: (isSelected) {
          setState(() {
            _selectedFilter = label; // Use 'label' here
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        avatar:
            selected // Use 'selected' for avatar condition
            ? const Icon(Icons.check_circle, color: Colors.white, size: 18)
            : null,
        elevation: 0.1,
      ),
    );
  }

  Widget _buildNotificationCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Ensure the 'type' field matches what's stored in Firestore
    final type = data['type']?.toLowerCase() ?? 'general';
    final title = data['title'] ?? '';
    final details = List<String>.from(data['details'] ?? []);
    final timestamp =
        data['timestamp']
            as Timestamp?; // Use 'timestamp' for consistency if that's the field name

    Color cardColor = Colors.white;
    Color borderColor = Colors.transparent;
    IconData icon = Icons.info_outline;
    Color iconColor = Colors.blue;

    if (type == 'promo_expiry') {
      icon = Icons.error_outline;
      iconColor = Colors.red;
      cardColor = const Color(0xFFFFF0F0);
      borderColor = const Color(0xFFFFCCCC);
    } else if (type == 'supplier' || type == 'batch') {
      icon = Icons.store;
      iconColor = Colors.green;
      cardColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFFC8E6C9);
    } else if (type == 'staff_signup') {
      icon = Icons.person_add; // Example icon for staff
      iconColor = Colors.purple; // Example color for staff
      cardColor = const Color(0xFFF3E5F5); // Light purple
      borderColor = const Color(0xFFE1BEE7); // Purple border
    } else if (type == 'sync') {
      icon = Icons.sync;
      iconColor = Colors.orange;
      cardColor = const Color(0xFFFFF3E0); // Light orange
      borderColor = const Color(0xFFFFCC80); // Orange border
    } else if (type == 'suggestion') {
      icon = Icons.lightbulb_outline;
      iconColor = Colors.teal;
      cardColor = const Color(0xFFE0F2F7); // Light blue
      borderColor = const Color(0xFFB3E5FC); // Blue border
    }

    final formattedTime = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
        : '';

    return Card(
      elevation: 0.1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      color: cardColor,
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
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: detail.toLowerCase().contains('day')
                                ? Colors.red
                                : Colors.black54,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detail,
                              style: TextStyle(
                                color: detail.toLowerCase().contains('day')
                                    ? Colors.red
                                    : Colors.black87,
                                fontSize: 15,
                                fontWeight: detail.toLowerCase().contains('day')
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedTime,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
