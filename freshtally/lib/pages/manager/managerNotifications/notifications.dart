import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManagerNotificationCenterPage extends StatefulWidget {
  const ManagerNotificationCenterPage({
    super.key,
    required this.supermarketName,
  });

  final String supermarketName;

  @override
  State<ManagerNotificationCenterPage> createState() =>
      _ManagerNotificationCenterPageState();
}

class _ManagerNotificationCenterPageState
    extends State<ManagerNotificationCenterPage> {
  String _selectedFilter = 'All';
  final _filters = const ['All', 'Staff', 'Promotions'];
  bool _hasIndexError = false;
  bool _isLoading = true;

  Stream<QuerySnapshot> _createStream() {
    try {
      Query query = FirebaseFirestore.instance
          .collection('notifications')
          .where('supermarketName', isEqualTo: widget.supermarketName)
          .orderBy('createdAt', descending: true);

      if (_selectedFilter == 'Staff') {
        query = query.where('type', isEqualTo: 'staff_signup');
      } else if (_selectedFilter == 'Promotions') {
        query = query.where('type', isEqualTo: 'promo_expiry');
      }

      return query.snapshots().handleError((error) {
        if (error.toString().contains('index')) {
          if (mounted) {
            setState(() {
              _hasIndexError = true;
              _isLoading = false;
            });
          }
        }
        return Stream.empty();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasIndexError = true;
          _isLoading = false;
        });
      }
      return Stream.empty();
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
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
            _buildFilterRow(),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_hasIndexError)
              _buildIndexErrorWidget()
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _createStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No notifications available'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
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

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              selectedColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFF5F6FA),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                    _isLoading = true;
                    _hasIndexError = false;
                  });
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              avatar: _selectedFilter == filter
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIndexErrorWidget() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Index Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This query requires a Firestore index to work properly.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // This would typically use url_launcher package
                  debugPrint('Redirect to Firebase console to create index');
                },
                child: const Text('Create Index'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasIndexError = false;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(DocumentSnapshot doc) {
    if (!doc.exists) return const SizedBox();

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final type = (data['type'] ?? '').toString().toLowerCase();
    final title = data['title'] ?? 'Notification';
    final message = data['message'] ?? '';
    final timestamp = data['createdAt'] as Timestamp?;
    final formattedTime = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
        : '';

    final payload = data['payload'] as Map<String, dynamic>? ?? {};
    final staffName = payload['staffName'] ?? '';
    final code = payload['verificationCode'] ?? '';
    final supermarket = payload['supermarketName'] ?? '';

    final List<String> details = [];
    if (type == 'staff_signup') {
      details.addAll([
        message,
        if (staffName.isNotEmpty) 'Staff: $staffName',
        if (code.isNotEmpty) 'Verification Code: $code',
        if (supermarket.isNotEmpty) 'Supermarket: $supermarket',
      ]);
    } else {
      details.add(message);
      if (data['expiryDate'] != null) {
        details.add(
          'Expires: ${DateFormat('MMM d, y').format((data['expiryDate'] as Timestamp).toDate())}',
        );
      }
    }

    final style = _getNotificationStyle(type);

    return Card(
      elevation: 0.1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: style.borderColor),
      ),
      color: style.cardColor,
      child: InkWell(
        onTap: () => _showNotificationDetails(context, doc),
        borderRadius: BorderRadius.circular(16),
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
                  if (data['read'] == false)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
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
                      color: detail.toLowerCase().contains('code')
                          ? Colors.blue
                          : Colors.black87,
                      fontWeight: detail.toLowerCase().contains('code')
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
      ),
    );
  }

  void _showNotificationDetails(BuildContext context, DocumentSnapshot doc) {
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final type = (data['type'] ?? '').toString().toLowerCase();

    if (type == 'staff_signup') {
      _showStaffSignupDialog(context, doc);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(data['title'] ?? 'Notification Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data['message'] ?? ''),
                if (data['expiryDate'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Expires: ${DateFormat('MMM d, y h:mm a').format((data['expiryDate'] as Timestamp).toDate())}',
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

    if (data['read'] == false) {
      doc.reference.update({'read': true});
    }
  }

  Future<void> _showStaffSignupDialog(
    BuildContext context,
    DocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final payload = data['payload'] as Map<String, dynamic>? ?? {};

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staff Signup Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Message:', data['message'] ?? ''),
              const SizedBox(height: 16),
              _buildDetailRow('Staff Name:', payload['staffName'] ?? ''),
              _buildDetailRow('Supermarket:', payload['supermarketName'] ?? ''),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Verification Code:',
                payload['verificationCode'] ?? '',
                isImportant: true,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Status:',
                (data['read'] ?? false) ? 'Viewed' : 'New',
                isImportant: true,
                color: (data['read'] ?? false) ? Colors.grey : Colors.green,
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
            '$label ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isImportant ? (color ?? Colors.blue) : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
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
          borderColor: Colors.grey.shade200,
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
