import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManagerNotificationCenterPage extends StatefulWidget {
  const ManagerNotificationCenterPage({
    super.key,
    required this.managerSupermarketName,
  });

  /// The supermarket this manager belongs to
  final String managerSupermarketName;

  @override
  State<ManagerNotificationCenterPage> createState() =>
      _ManagerNotificationCenterPageState();
}

class _ManagerNotificationCenterPageState
    extends State<ManagerNotificationCenterPage> {
  // Convenience getter
  String get _mySupermarket => widget.managerSupermarketName;

  // Filter state
  String _selectedFilter = 'All';
  final _filters = const ['All', 'Staff', 'Expiry'];

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    final base = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    switch (_selectedFilter) {
      case 'Staff':
        // Only staff sign‑ups for THIS supermarket
        return base
            .where('type', isEqualTo: 'staff_signup')
            .where('supermarketName', isEqualTo: _mySupermarket)
            .snapshots();
      case 'Expiry':
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

  /* ──────────────────────────── UI BUILD ─────────────────────────────── */

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
            _filterRow(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No notifications yet.'));
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) =>
                        _buildNotificationCard(docs[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ────────────────────────── FILTER WIDGETS ─────────────────────────── */

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
        backgroundColor: const Color(0xFFF5F6FA),
        onSelected: (_) => setState(() => _selectedFilter = label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        avatar: selected
            ? const Icon(Icons.check_circle, color: Colors.white, size: 18)
            : null,
        elevation: 0.1,
      ),
    );
  }

  /* ───────────────────────── NOTIFICATION CARD ───────────────────────── */

  Widget _buildNotificationCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = (data['type'] ?? '').toLowerCase();
    final supermarketName = data['supermarketName'] as String? ?? '';

    // Generate/persist 6‑digit code for matching sign‑ups
    String? signupCode = data['signupCode'] as String?;
    if (type == 'staff_signup' &&
        supermarketName == _mySupermarket &&
        signupCode == null) {
      signupCode = _generate6DigitCode();
      doc.reference.update({'signupCode': signupCode});
    }

    final title = data['title'] ?? '';
    final details = List<String>.from(data['details'] ?? []);

    // Show the code at the top, if present
    if (signupCode != null) {
      details.insert(0, '🆔 6‑digit code: $signupCode');
    }

    final timestamp = data['timestamp'] as Timestamp?;
    final formattedTime = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
        : '';

    /* ---------- Visual config per notification type ---------- */
    Color cardColor = Colors.white;
    Color borderColor = Colors.transparent;
    IconData icon = Icons.info_outline;
    Color iconColor = Colors.blue;

    switch (type) {
      case 'promo_expiry':
        icon = Icons.error_outline;
        iconColor = Colors.red;
        cardColor = const Color(0xFFFFF0F0);
        borderColor = const Color(0xFFFFCCCC);
        break;
      case 'supplier':
      case 'batch':
        icon = Icons.store;
        iconColor = Colors.green;
        cardColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFFC8E6C9);
        break;
      case 'staff_signup':
        icon = Icons.person_add;
        iconColor = Colors.purple;
        cardColor = const Color(0xFFF3E5F5);
        borderColor = const Color(0xFFE1BEE7);
        break;
      case 'sync':
        icon = Icons.sync;
        iconColor = Colors.orange;
        cardColor = const Color(0xFFFFF3E0);
        borderColor = const Color(0xFFFFCC80);
        break;
      case 'suggestion':
        icon = Icons.lightbulb_outline;
        iconColor = Colors.teal;
        cardColor = const Color(0xFFE0F2F7);
        borderColor = const Color(0xFFB3E5FC);
        break;
    }

    /* ----------------------------- Card ----------------------------- */
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
                      padding: const EdgeInsets.symmetric(vertical: 2),
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

  /* ────────────────────── 6‑DIGIT CODE GENERATOR ────────────────────── */

  String _generate6DigitCode() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString(); // 100000‑999999
  }
}
