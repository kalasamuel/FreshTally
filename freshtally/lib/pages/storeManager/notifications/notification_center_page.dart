import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  final String supermarketId;

  const NotificationsPage({super.key, required this.supermarketId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<String> _availableFilters = [
    'All',
    'Expiry',
    'Sync',
    'Promotions',
    'Customers', // Added customers filter
  ];
  String _selectedFilter = 'All';
  bool _showNewCustomerWelcome = false;
  String? _newCustomerName;

  @override
  void initState() {
    super.initState();
    _checkForNewCustomers();
  }

  Future<void> _checkForNewCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final lastChecked = prefs.getString('lastCustomerCheck') ?? '';

    final newCustomers = await FirebaseFirestore.instance
        .collection('customers')
        .where('supermarketId', isEqualTo: widget.supermarketId)
        .where('createdAt', isGreaterThan: lastChecked)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (newCustomers.docs.isNotEmpty) {
      final newCustomer = newCustomers.docs.first;
      setState(() {
        _showNewCustomerWelcome = true;
        _newCustomerName = newCustomer['name'] ?? 'a new customer';
      });

      await prefs.setString(
        'lastCustomerCheck',
        DateTime.now().toIso8601String(),
      );

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'new_customer',
        'title': 'New Customer Joined',
        'description': '$_newCustomerName has joined your supermarket!',
        'supermarketId': widget.supermarketId,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'priority': 'low',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showNewCustomerWelcome && _newCustomerName != null)
              _buildNewCustomerNotification(),
            FilterChips(
              filters: _availableFilters,
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) =>
                  setState(() => _selectedFilter = filter),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getNotificationsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No notifications available.'),
                    );
                  }

                  final filteredNotifications = snapshot.data!.docs.where((
                    doc,
                  ) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'] as String? ?? 'general';

                    if (_selectedFilter == 'All') return true;
                    if (_selectedFilter == 'Expiry' &&
                        (type == 'expiry_warning' ||
                            type == 'expired_product')) {
                      return true;
                    }
                    if (_selectedFilter == 'Sync' &&
                        (type == 'sync_reminder' || type == 'sync_error')) {
                      return true;
                    }
                    if (_selectedFilter == 'Promotions' &&
                        type == 'promotion') {
                      return true;
                    }
                    if (_selectedFilter == 'Customers' &&
                        type == 'new_customer') {
                      return true;
                    }
                    return false;
                  }).toList();

                  if (filteredNotifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${_selectedFilter.toLowerCase()} notifications.',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final doc = filteredNotifications[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final String title = data['title'] ?? 'No Title';
                      final String description =
                          data['description'] ?? 'No Description';
                      final Timestamp? timestamp =
                          data['timestamp'] as Timestamp?;
                      final String time = timestamp != null
                          ? DateFormat(
                              'MMM d, HH:mm',
                            ).format(timestamp.toDate())
                          : 'N/A';
                      final String type = data['type'] ?? 'general';
                      final String priority = data['priority'] ?? 'medium';
                      final bool isRead = data['isRead'] ?? false;

                      IconData icon;
                      Color iconColor;
                      Color cardColor;
                      List<ActionButton> buttons = [];

                      switch (type) {
                        case 'expiry_warning':
                          icon = Icons.error_outline;
                          iconColor = Colors.orange;
                          cardColor = Colors.orange[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'Snooze',
                              color: Colors.grey[300]!,
                              onPressed: () => _snoozeNotification(doc.id),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Mark Done',
                              color: Colors.yellow[200]!,
                              onPressed: () => _markNotificationAsRead(doc.id),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Dismiss',
                              color: Colors.green[100]!,
                              onPressed: () => _dismissNotification(doc.id),
                            ),
                          );
                          break;
                        case 'expired_product':
                          icon = Icons.warning;
                          iconColor = Colors.red;
                          cardColor = Colors.red[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'Mark Done',
                              color: Colors.yellow[200]!,
                              onPressed: () => _markNotificationAsRead(doc.id),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Dismiss',
                              color: Colors.green[100]!,
                              onPressed: () => _dismissNotification(doc.id),
                            ),
                          );
                          break;
                        case 'sync_reminder':
                          icon = Icons.sync;
                          iconColor = Colors.green;
                          cardColor = Colors.green[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'Sync Now',
                              color: Colors.blue[100]!,
                              onPressed: () => _triggerSync(doc.id),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Snooze',
                              color: Colors.grey[300]!,
                              onPressed: () => _snoozeNotification(doc.id),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Dismiss',
                              color: Colors.green[100]!,
                              onPressed: () => _dismissNotification(doc.id),
                            ),
                          );
                          break;
                        case 'sync_error':
                          icon = Icons.cloud_off;
                          iconColor = Colors.deepOrange;
                          cardColor = Colors.deepOrange[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'Retry Sync',
                              color: Colors.blue[100]!,
                              onPressed: () => _triggerSync(doc.id),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Dismiss',
                              color: Colors.green[100]!,
                              onPressed: () => _dismissNotification(doc.id),
                            ),
                          );
                          break;
                        case 'promotion':
                          icon = Icons.local_offer;
                          iconColor = Colors.purple;
                          cardColor = Colors.purple[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'View Deal',
                              color: Colors.blue[100]!,
                              onPressed: () =>
                                  _viewPromotion(doc.id, data['productId']),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Dismiss',
                              color: Colors.green[100]!,
                              onPressed: () => _dismissNotification(doc.id),
                            ),
                          );
                          break;
                        case 'new_customer':
                          icon = Icons.person_add;
                          iconColor = Colors.blue;
                          cardColor = Colors.blue[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'View Profile',
                              color: Colors.blue[100]!,
                              onPressed: () => _viewCustomerProfile(
                                doc.id,
                                data['customerId'],
                              ),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Dismiss',
                              color: Colors.green[100]!,
                              onPressed: () => _dismissNotification(doc.id),
                            ),
                          );
                          break;
                        default:
                          icon = Icons.notifications;
                          iconColor = Colors.grey;
                          cardColor = Colors.grey[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'Mark Done',
                              color: Colors.yellow[200]!,
                              onPressed: () => _markNotificationAsRead(doc.id),
                            ),
                          );
                          buttons.add(
                            ActionButton(
                              label: 'Dismiss',
                              color: Colors.green[100]!,
                              onPressed: () => _dismissNotification(doc.id),
                            ),
                          );
                          break;
                      }

                      if (priority == 'high' &&
                          ![
                            'expired_product',
                            'sync_error',
                            'promotion',
                            'new_customer',
                          ].contains(type)) {
                        cardColor = Colors.red[100]!;
                        iconColor = Colors.red;
                      }

                      if (isRead) {
                        cardColor = Colors.grey[200]!;
                        iconColor = Colors.grey;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: NotificationCard(
                          title: title,
                          description: description,
                          time: time,
                          color: cardColor,
                          icon: icon,
                          iconColor: iconColor,
                          buttons: buttons,
                          isRead: isRead,
                        ),
                      );
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

  Widget _buildNewCustomerNotification() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        color: Colors.blue[50],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_add, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'NEW CUSTOMER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () =>
                        setState(() => _showNewCustomerWelcome = false),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_newCustomerName has joined your supermarket!',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome them with special offers to build loyalty.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('supermarketId', isEqualTo: widget.supermarketId)
        .where(
          'type',
          whereIn: [
            'expiry_warning',
            'expired_product',
            'sync_reminder',
            'sync_error',
            'promotion',
            'new_customer',
          ],
        )
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _updateNotificationStatus(
    String notificationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update(updates);
      if (mounted) {
        _showSnackBar('Notification updated.');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update notification: $e', isError: true);
      }
    }
  }

  void _markNotificationAsRead(String notificationId) {
    _updateNotificationStatus(notificationId, {'isRead': true});
  }

  void _dismissNotification(String notificationId) {
    _updateNotificationStatus(notificationId, {
      'isRead': true,
      'isDismissed': true,
    });
  }

  void _snoozeNotification(String notificationId) {
    _updateNotificationStatus(notificationId, {
      'snoozeUntil': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 1)),
      ),
      'isRead': false,
    });
  }

  void _triggerSync(String notificationId) {
    _showSnackBar('Initiating sync process...');
    _markNotificationAsRead(notificationId);
  }

  void _viewPromotion(String notificationId, String? productId) {
    _showSnackBar('Navigating to product details...');
    _markNotificationAsRead(notificationId);
  }

  void _viewCustomerProfile(String notificationId, String? customerId) {
    _showSnackBar('Navigating to customer profile...');
    _markNotificationAsRead(notificationId);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const FilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8.0,
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            selectedColor: Colors.green.shade700,
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (selected) =>
                selected ? onFilterSelected(filter) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? Colors.green.shade700
                    : Colors.grey.shade300,
              ),
            ),
            elevation: isSelected ? 2 : 0,
          );
        }).toList(),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final Color? color;
  final IconData icon;
  final Color iconColor;
  final List<ActionButton> buttons;
  final bool isRead;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    this.color,
    required this.icon,
    required this.iconColor,
    required this.buttons,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: isRead
            ? [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 2)]
            : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
      ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isRead ? Colors.grey : Colors.black87,
                    decoration: isRead ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: isRead ? Colors.grey : Colors.black87,
              fontStyle: isRead ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: buttons
                        .map(
                          (btn) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: btn.color,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: isRead ? null : btn.onPressed,
                              child: Text(btn.label),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });
}
