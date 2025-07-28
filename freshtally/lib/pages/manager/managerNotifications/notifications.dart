import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerNotificationCenterPage extends StatefulWidget {
  const ManagerNotificationCenterPage({
    super.key,
    required this.supermarketName,
    required this.managerId,
  });

  final String supermarketName;
  final String managerId;

  @override
  State<ManagerNotificationCenterPage> createState() =>
      _ManagerNotificationCenterPageState();
}

class _ManagerNotificationCenterPageState
    extends State<ManagerNotificationCenterPage> {
  bool _hasIndexError = false;
  bool _isLoading = true;
  bool _showWelcomeMessage = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _checkFirstTimeLogin();
  }

  Future<void> _checkFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('${widget.managerId}_first_time') ?? true;

    if (isFirstTime) {
      setState(() {
        _showWelcomeMessage = true;
      });
      await prefs.setBool('${widget.managerId}_first_time', false);
      await _createWelcomeNotification();
    }
  }

  Future<void> _createWelcomeNotification() async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Welcome to FreshTally!',
        'message':
            'Thank you for joining FreshTally. We hope you enjoy using our app to manage your supermarket.',
        'type': 'welcome',
        'supermarketName': widget.supermarketName,
        'recipientId': widget.managerId,
        'createdAt': Timestamp.now(),
        'read': false,
      });
    } catch (e) {
      debugPrint("Error creating welcome notification: $e");
    }
  }

  Stream<QuerySnapshot> _createStream() {
    try {
      Query query = FirebaseFirestore.instance
          .collection('notifications')
          .where('supermarketName', isEqualTo: widget.supermarketName)
          .where('recipientId', isEqualTo: widget.managerId)
          .orderBy('createdAt', descending: true);

      return query.snapshots().handleError((error) {
        debugPrint("Notification stream error: $error");
        if (mounted) {
          setState(() {
            _hasIndexError = error.toString().contains('index');
          });
        }
        return Stream.error(error);
      });
    } catch (e) {
      debugPrint("Error creating stream: $e");
      if (mounted) {
        setState(() {
          _hasIndexError = true;
        });
      }
      return Stream.error(e);
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
            if (_showWelcomeMessage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.green.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.celebration, color: Colors.green[800]),
                            const SizedBox(width: 8),
                            const Text(
                              'Welcome to FreshTally!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Thank you for joining FreshTally',
                          style: TextStyle(color: Colors.black87),
                        ),
                        const Text(
                          '• We hope you enjoy using our app',
                          style: TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Just now',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isLoading && !_hasIndexError)
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

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Stop loading when we have data
                    if (_isLoading && snapshot.hasData) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      });
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
    final isRead = data['read'] ?? false;

    final payload = data['payload'] as Map<String, dynamic>? ?? {};
    final staffName = payload['staffName'] ?? data['staffName'] ?? '';
    final verificationCode = payload['verificationCode'] ?? '';
    final supermarket =
        payload['supermarketName'] ?? data['supermarketName'] ?? '';

    final List<String> details = [];
    if (type == 'staff_signup') {
      details.addAll([
        message,
        if (staffName.isNotEmpty) 'Staff: $staffName',
        if (verificationCode.isNotEmpty) 'Verification Code: $verificationCode',
        if (supermarket.isNotEmpty) 'Supermarket: $supermarket',
      ]);
    } else if (type == 'promo_expiry') {
      details.add(message);
      if (data['expiryDate'] != null) {
        final expiryDate = (data['expiryDate'] as Timestamp).toDate();
        final timeLeft = expiryDate.difference(DateTime.now());
        details.add(
          'Expires: ${DateFormat('MMM d, y').format(expiryDate)} (${timeLeft.inHours} hours left)',
        );
      }
    } else if (type == 'promo_48h_warning') {
      details.add(message);
      if (data['expiryDate'] != null) {
        final expiryDate = (data['expiryDate'] as Timestamp).toDate();
        details.add(
          'Expires soon: ${DateFormat('MMM d, y').format(expiryDate)}',
        );
      }
    } else {
      details.add(message);
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
                  if (!isRead)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
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
    final isRead = data['read'] ?? false;

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
                      type == 'promo_48h_warning'
                          ? 'Expires soon: ${DateFormat('MMM d, y h:mm a').format((data['expiryDate'] as Timestamp).toDate())}'
                          : 'Expires: ${DateFormat('MMM d, y h:mm a').format((data['expiryDate'] as Timestamp).toDate())}',
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

    if (!isRead) {
      doc.reference.update({'read': true});
    }
  }

  Future<void> _showStaffSignupDialog(
    BuildContext context,
    DocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final payload = data['payload'] as Map<String, dynamic>? ?? {};
    final isRead = data['read'] ?? false;

    final staffName = payload['staffName'] ?? data['staffName'] ?? '';
    final verificationCode = payload['verificationCode'] ?? '';
    final supermarket =
        payload['supermarketName'] ?? data['supermarketName'] ?? '';
    final message = data['message'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staff Signup Request'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Message:', message),
              const SizedBox(height: 16),
              _buildDetailRow('Staff Name:', staffName),
              _buildDetailRow('Supermarket:', supermarket),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Verification Code:',
                verificationCode,
                isImportant: true,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Status:',
                isRead ? 'Viewed' : 'New',
                isImportant: true,
                color: isRead ? Colors.grey : Colors.blue,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (verificationCode.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Copy Code'),
            ),
        ],
      ),
    );

    if (!isRead) {
      doc.reference.update({'read': true});
    }
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
        iconColor: Colors.blue,
        cardColor: const Color(0xFFE3F2FD),
        borderColor: const Color(0xFFBBDEFB),
      );
    case 'promo_48h_warning':
      return NotificationStyle(
        icon: Icons.warning,
        iconColor: Colors.orange,
        cardColor: const Color(0xFFFFF3E0),
        borderColor: const Color(0xFFFFE0B2),
      );
    case 'staff_signup':
      return NotificationStyle(
        icon: Icons.person_add,
        iconColor: Colors.blue,
        cardColor: const Color(0xFFE3F2FD),
        borderColor: const Color(0xFFBBDEFB),
      );
    case 'welcome':
      return NotificationStyle(
        icon: Icons.celebration,
        iconColor: Colors.green,
        cardColor: const Color(0xFFE8F5E9),
        borderColor: const Color(0xFFC8E6C9),
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
