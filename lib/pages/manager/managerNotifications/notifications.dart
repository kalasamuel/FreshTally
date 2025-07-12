import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';

class ManagerNotificationsPage extends StatefulWidget {
  final Map<String, dynamic> supermarketInfo;

  const ManagerNotificationsPage({
    Key? key,
    required this.supermarketInfo,
  }) : super(key: key);

  @override
  State<ManagerNotificationsPage> createState() => _ManagerNotificationsPageState();
}

class _ManagerNotificationsPageState extends State<ManagerNotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .where('supermarketId', isEqualTo: widget.supermarketInfo['id'])
            .where('recipientRole', isEqualTo: 'manager')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final notificationId = notifications[index].id;

              return _buildNotificationCard(notification, notificationId);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, String notificationId) {
    final type = notification['type'] ?? '';
    final message = notification['message'] ?? '';
    final timestamp = notification['timestamp'] as Timestamp?;
    final isRead = notification['isRead'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isRead ? 1 : 3,
      color: isRead ? Colors.grey[50] : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRead ? Colors.grey : Colors.green,
          child: Icon(
            _getNotificationIcon(type),
            color: Colors.white,
          ),
        ),
        title: Text(
          _getNotificationTitle(type),
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? Colors.grey[600] : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isRead ? Colors.grey[600] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: type == 'staff_signup_request' 
            ? _buildStaffSignupActions(notification, notificationId)
            : null,
        onTap: () => _handleNotificationTap(notification, notificationId),
      ),
    );
  }

  Widget _buildStaffSignupActions(Map<String, dynamic> notification, String notificationId) {
    final verificationCode = notification['verificationCode'] ?? '';
    final staffEmail = notification['staffEmail'] ?? '';
    final staffName = notification['staffName'] ?? '';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleStaffAction(value, notification, notificationId),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'generate_code',
          child: Row(
            children: [
              Icon(Icons.code, color: Colors.blue),
              SizedBox(width: 8),
              Text('Generate Code'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'view_details',
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.green),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text('Approve'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'reject',
          child: Row(
            children: [
              Icon(Icons.close, color: Colors.red),
              SizedBox(width: 8),
              Text('Reject'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleStaffAction(String action, Map<String, dynamic> notification, String notificationId) async {
    switch (action) {
      case 'generate_code':
        _generateVerificationCode(notification);
        break;
      case 'view_details':
        _showStaffDetails(notification);
        break;
      case 'approve':
        _approveStaffSignup(notification, notificationId);
        break;
      case 'reject':
        _rejectStaffSignup(notification, notificationId);
        break;
    }
  }

  void _generateVerificationCode(Map<String, dynamic> notification) {
    final staffEmail = notification['staffEmail'] ?? '';
    final staffName = notification['staffName'] ?? '';
    
    // Generate a 6-digit code
    final code = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    
    // Store the code in Firestore
    _firestore.collection('verification_codes').add({
      'code': code,
      'supermarketId': widget.supermarketInfo['id'],
      'supermarketName': widget.supermarketInfo['name'],
      'staffEmail': staffEmail,
      'staffName': staffName,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      ),
      'isUsed': false,
    }).then((_) {
      // Send notification to staff with the code
      _firestore.collection('notifications').add({
        'type': 'verification_code',
        'message': 'Your verification code is: $code. Use this code to complete your signup.',
        'recipientEmail': staffEmail,
        'recipientRole': 'staff',
        'supermarketId': widget.supermarketInfo['id'],
        'supermarketName': widget.supermarketInfo['name'],
        'verificationCode': code,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code $code generated and sent to $staffEmail'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating code: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _showStaffDetails(Map<String, dynamic> notification) {
    final staffEmail = notification['staffEmail'] ?? '';
    final staffName = notification['staffName'] ?? '';
    final verificationCode = notification['verificationCode'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staff Signup Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $staffName'),
            const SizedBox(height: 8),
            Text('Email: $staffEmail'),
            const SizedBox(height: 8),
            Text('Verification Code: $verificationCode'),
            const SizedBox(height: 8),
            Text('Supermarket: ${widget.supermarketInfo['name']}'),
          ],
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

  void _approveStaffSignup(Map<String, dynamic> notification, String notificationId) async {
    final staffEmail = notification['staffEmail'] ?? '';
    final staffName = notification['staffName'] ?? '';

    try {
      // Update user role in Firestore
      await _firestore.collection('users').doc(staffEmail).update({
        'role': 'shelf_staff',
        'supermarketId': widget.supermarketInfo['id'],
        'supermarketName': widget.supermarketInfo['name'],
        'isApproved': true,
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Mark notification as read
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'status': 'approved',
      });

      // Send approval notification to staff
      await _firestore.collection('notifications').add({
        'type': 'signup_approved',
        'message': 'Your signup has been approved! You can now access the FreshTally app.',
        'recipientEmail': staffEmail,
        'recipientRole': 'staff',
        'supermarketId': widget.supermarketInfo['id'],
        'supermarketName': widget.supermarketInfo['name'],
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff signup approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving signup: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectStaffSignup(Map<String, dynamic> notification, String notificationId) async {
    final staffEmail = notification['staffEmail'] ?? '';
    final staffName = notification['staffName'] ?? '';

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Staff Signup'),
        content: Text('Are you sure you want to reject $staffName\'s signup request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Mark notification as read
        await _firestore.collection('notifications').doc(notificationId).update({
          'isRead': true,
          'status': 'rejected',
        });

        // Send rejection notification to staff
        await _firestore.collection('notifications').add({
          'type': 'signup_rejected',
          'message': 'Your signup request has been rejected. Please contact your manager for more information.',
          'recipientEmail': staffEmail,
          'recipientRole': 'staff',
          'supermarketId': widget.supermarketInfo['id'],
          'supermarketName': widget.supermarketInfo['name'],
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Staff signup rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting signup: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification, String notificationId) async {
    // Mark notification as read
    if (!(notification['isRead'] ?? false)) {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    }

    // Handle different notification types
    final type = notification['type'] ?? '';
    switch (type) {
      case 'staff_signup_request':
        _showStaffDetails(notification);
        break;
      case 'verification_code':
        _showVerificationCodeDetails(notification);
        break;
      default:
        // Show general notification details
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showVerificationCodeDetails(Map<String, dynamic> notification) {
    final code = notification['verificationCode'] ?? '';
    final message = notification['message'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: $code'),
            const SizedBox(height: 8),
            Text('Message: $message'),
          ],
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

  void _showNotificationDetails(Map<String, dynamic> notification) {
    final message = notification['message'] ?? '';
    final timestamp = notification['timestamp'] as Timestamp?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message: $message'),
            const SizedBox(height: 8),
            Text('Time: ${_formatTimestamp(timestamp)}'),
          ],
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'staff_signup_request':
        return Icons.person_add;
      case 'verification_code':
        return Icons.code;
      case 'signup_approved':
        return Icons.check_circle;
      case 'signup_rejected':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'staff_signup_request':
        return 'Staff Signup Request';
      case 'verification_code':
        return 'Verification Code';
      case 'signup_approved':
        return 'Signup Approved';
      case 'signup_rejected':
        return 'Signup Rejected';
      default:
        return 'Notification';
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
