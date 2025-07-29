import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Freshtally/pages/customer/product/products_details_page.dart';

class NotificationsPage extends StatefulWidget {
  final String supermarketId;
  final String userId;

  const NotificationsPage({
    super.key,
    required this.supermarketId,
    required this.userId,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _showWelcomeNotification = false;

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstVisit = prefs.getBool('${widget.userId}_first_visit') ?? true;

    if (isFirstVisit) {
      setState(() {
        _showWelcomeNotification = true;
      });
      await prefs.setBool('${widget.userId}_first_visit', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supermarket Notifications'),
        centerTitle: true,
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    return Column(
      children: [
        if (_showWelcomeNotification) _buildWelcomeNotification(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('supermarketId', isEqualTo: widget.supermarketId)
                .where('targetAudience', isEqualTo: 'customers')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load notifications: ${snapshot.error}',
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No new notifications',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildNotificationCard(context, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeNotification() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_emotions, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'WELCOME!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _showWelcomeNotification = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Thanks for choosing our supermarket! '
              'Here you\'ll find all the latest deals and updates.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bell icon to get notified about new discounts.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final type = data['type'] as String? ?? 'general';
    final message = data['message'] as String? ?? 'New notification';
    final timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final productId = data['productId'] as String?;
    final productName = data['productName'] as String? ?? 'product';

    if (type == 'discount') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: productId != null
              ? () => _navigateToProduct(context, productId)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.discount, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'DISCOUNT ALERT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message.isNotEmpty
                      ? message
                      : '$productName is now on discount! Tap to view.',
                  style: const TextStyle(fontSize: 14),
                ),
                if (productId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap to view product',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconForType(type)),
                const SizedBox(width: 8),
                Text(
                  type.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatTime(timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _navigateToProduct(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          productId: productId,
          supermarketId: widget.supermarketId,
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'alert':
        return Icons.notification_important;
      case 'promotion':
        return Icons.local_offer;
      case 'new_arrival':
        return Icons.new_releases;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
