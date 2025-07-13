import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManagerNotificationCenterPage extends StatefulWidget {
  const ManagerNotificationCenterPage({
    super.key,
    required this.managerSupermarketName,
  });

  final String managerSupermarketName;

  @override
  State<ManagerNotificationCenterPage> createState() =>
      _ManagerNotificationCenterPageState();
}

class _ManagerNotificationCenterPageState
    extends State<ManagerNotificationCenterPage> {
  String get _mySupermarket => widget.managerSupermarketName;
  String _selectedFilter = 'All';
  final _filters = const ['All', 'Staff', 'Promotions'];

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    final base = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    switch (_selectedFilter) {
      case 'Staff':
        return base
            .where('type', isEqualTo: 'staff_signup')
            .where('supermarketName', isEqualTo: _mySupermarket)
            .snapshots();
      case 'Promotions':
        return base.where('type', isEqualTo: 'promo_expiry').snapshots();
      default:
        return base.snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () => _showNotificationDetails(
                        context,
                        snapshot.data!.docs[index],
                      ),
                      child: _buildNotificationCard(snapshot.data!.docs[index]),
                    ),
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
        backgroundColor: const Color(0xFFF5F6FA),
        onSelected: (_) => setState(() => _selectedFilter = label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        avatar: selected
            ? const Icon(Icons.check_circle, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  Widget _buildNotificationCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = (data['type'] ?? '').toLowerCase();
    final title = data['title'] ?? '';
    final message = data['message'] ?? '';
    final timestamp = data['createdAt'] as Timestamp?;
    final formattedTime = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
        : '';

    // For staff signup, include verification code in details
    List<String> details = [];
    if (type == 'staff_signup') {
      final payload = data['payload'] as Map<String, dynamic>? ?? {};
      final staffName = payload['staffName'] ?? data['staffName'] ?? '';
      final code =
          payload['verificationCode'] ?? data['verificationCode'] ?? '';

      details.addAll([
        message,
        if (staffName.isNotEmpty) 'Staff: $staffName',
        if (code.isNotEmpty) 'Code: $code',
      ]);
    } else {
      details = List<String>.from(data['details'] ?? []);
    }

    // Visual styling based on type
    final style = _getNotificationStyle(type);

    return Card(
      elevation: 0.1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: style.borderColor),
      ),
      color: style.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(style.icon, color: style.iconColor),
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
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $detail',
                  style: TextStyle(
                    color:
                        detail.toLowerCase().contains('expire') ||
                            detail.toLowerCase().contains('hour') ||
                            detail.toLowerCase().contains('code')
                        ? Colors.blue
                        : Colors.black87,
                    fontWeight:
                        detail.toLowerCase().contains('hour') ||
                            detail.toLowerCase().contains('code')
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
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

  void _showNotificationDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] ?? '';
    final title = data['title'] ?? 'Notification Details';
    final details = List<String>.from(data['details'] ?? []);

    // Special handling for staff signup notifications
    if (type == 'staff_signup') {
      _showStaffSignupDialog(context, doc);
      return;
    }

    // Default dialog for other notifications
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(detail),
                ),
              ),
              if (data['discountExpiry'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Expires: ${DateFormat('MMM d, y h:mm a').format((data['discountExpiry'] as Timestamp).toDate())}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStaffSignupDialog(
    BuildContext context,
    DocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>;
    final payload = data['payload'] as Map<String, dynamic>? ?? {};

    // Get verification details from payload or directly from data
    final verificationCode =
        payload['verificationCode'] ?? data['verificationCode'] ?? '';
    final staffName =
        payload['staffName'] ?? data['staffName'] ?? 'New Staff Member';
    final supermarketName =
        payload['supermarketName'] ??
        data['supermarketName'] ??
        'Your Supermarket';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final expiresAt =
        (payload['expiresAt'] as Timestamp?)?.toDate() ??
        (data['expiresAt'] as Timestamp?)?.toDate();
    final isUsed = payload['isUsed'] ?? data['isUsed'] ?? false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staff Signup Verification'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['message'] ?? 'New staff member requires verification:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Staff Name:', staffName),
              _buildDetailRow('Supermarket:', supermarketName),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Verification Code:',
                verificationCode,
                isImportant: true,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Status:',
                isUsed ? 'Used (Expired)' : 'Active',
                isImportant: true,
                color: isUsed ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Created:',
                createdAt != null
                    ? DateFormat('MMM d, h:mm a').format(createdAt)
                    : 'N/A',
              ),
              _buildDetailRow(
                'Expires:',
                expiresAt != null
                    ? DateFormat('MMM d, h:mm a').format(expiresAt)
                    : 'N/A',
              ),
              const SizedBox(height: 16),
              const Text(
                'Please provide this code to the staff member for verification.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    // Mark as read when dialog is closed if not already read
    if (!(data['read'] ?? false)) {
      await doc.reference.update({'read': true});
    }
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isImportant = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isImportant ? (color ?? Colors.blue) : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                color: isImportant ? (color ?? Colors.blue) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  NotificationStyle _getNotificationStyle(String type) {
    switch (type) {
      case 'promo_expiry':
        return NotificationStyle(
          icon: Icons.local_offer,
          iconColor: Colors.red,
          cardColor: const Color(0xFFFFF0F0),
          borderColor: const Color(0xFFFFCCCC),
        );
      case 'staff_signup':
        return NotificationStyle(
          icon: Icons.person_add,
          iconColor: Colors.purple,
          cardColor: const Color(0xFFF3E5F5),
          borderColor: const Color(0xFFE1BEE7),
        );
      default:
        return NotificationStyle(
          icon: Icons.info_outline,
          iconColor: Colors.blue,
          cardColor: Colors.white,
          borderColor: Colors.transparent,
        );
    }
  }
}

class NotificationStyle {
  final IconData icon;
  final Color iconColor;
  final Color cardColor;
  final Color borderColor;

  NotificationStyle({
    required this.icon,
    required this.iconColor,
    required this.cardColor,
    required this.borderColor,
  });
}
