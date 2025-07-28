import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting dates

// The NotificationsPage needs to be a StatefulWidget to manage its state,
// including the selected filter and the list of notifications.
class NotificationsPage extends StatefulWidget {
  final String supermarketId;

  const NotificationsPage({super.key, required this.supermarketId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Only include the relevant filters for the manager
  // Added 'Promotions' to the available filters
  final List<String> _availableFilters = [
    'All',
    'Expiry',
    'Sync',
    'Promotions',
  ];
  String _selectedFilter = 'All'; // State for the selected filter chip

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
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
            // Filter Chips - now uses the limited _availableFilters
            FilterChips(
              filters: _availableFilters, // Pass only the relevant filters
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
            const SizedBox(height: 16),
            // Notifications List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Fetch notifications for the specific supermarket
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

                  // Filter notifications based on selected chip and allowed types
                  final filteredNotifications = snapshot.data!.docs.where((
                    doc,
                  ) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type =
                        data['type'] as String? ?? 'general'; // Default type

                    // Define the types relevant for the manager, including 'promotion'
                    const managerRelevantTypes = {
                      'expiry_warning',
                      'expired_product',
                      'sync_reminder',
                      'sync_error',
                      'promotion', // Added promotion type
                    };

                    // First, filter by manager-relevant types
                    if (!managerRelevantTypes.contains(type)) {
                      return false; // Exclude types not relevant to manager
                    }

                    // Then, apply the selected filter chip
                    if (_selectedFilter == 'All') {
                      return true;
                    } else if (_selectedFilter == 'Expiry' &&
                        (type == 'expiry_warning' ||
                            type == 'expired_product')) {
                      return true;
                    } else if (_selectedFilter == 'Sync' &&
                        (type == 'sync_reminder' || type == 'sync_error')) {
                      return true;
                    } else if (_selectedFilter == 'Promotions' &&
                        type == 'promotion') {
                      // Filter for promotions
                      return true;
                    }
                    return false; // Should not be reached if logic is sound
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

                      // Parse notification data
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

                      // Determine icon, color based on type and priority
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
                        case 'sync_error': // New case for sync errors
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
                        case 'promotion': // New case for promotional notifications
                          icon = Icons.local_offer; // Icon for promotions
                          iconColor = Colors.purple; // Color for promotions
                          cardColor = Colors.purple[50]!;
                          buttons.add(
                            ActionButton(
                              label: 'View Deal',
                              color: Colors.blue[100]!,
                              onPressed: () => _viewPromotion(
                                doc.id,
                                data['productId'],
                              ), // Assuming productId is available
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
                        default: // Fallback for any unexpected types (though filtered out by `where` clause)
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

                      // Override color for high priority
                      if (priority == 'high' &&
                          type != 'expired_product' &&
                          type != 'sync_error' &&
                          type != 'promotion') {
                        // Ensure promotion doesn't override its specific high priority
                        cardColor = Colors.red[100]!;
                        iconColor = Colors.red;
                      }

                      // If already read, make it visually distinct
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

  // Firestore stream for notifications, filtered by supermarketId and sorted by timestamp.
  Stream<QuerySnapshot> _getNotificationsStream() {
    // Only query for the specific types the manager should receive, including 'promotion'
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
            'promotion', // Added 'promotion' to the query filter
          ],
        ) // Filter by allowed types
        .orderBy('timestamp', descending: true) // Show newest first
        .snapshots();
  }

  // --- Notification Actions (Firebase Update Logic) ---

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification updated.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update notification: $e')),
        );
      }
      debugPrint('Error updating notification $notificationId: $e');
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
    final snoozeUntil = Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 1)),
    );
    _updateNotificationStatus(notificationId, {
      'snoozeUntil': snoozeUntil,
      'isRead': false,
    });
  }

  void _triggerSync(String notificationId) {
    _showSnackBar('Initiating sync process...');
    _markNotificationAsRead(notificationId);
    // Add actual sync logic here if needed
  }

  // New method to handle 'View Deal' for promotion notifications
  void _viewPromotion(String notificationId, String? productId) {
    _showSnackBar('Navigating to product details for deal...');
    _markNotificationAsRead(notificationId);
    // Implement navigation to a product detail page or promotion page
    // if (productId != null) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => ProductDetailPage(productId: productId)),
    //   );
    // }
  }

  // Define _showSnackBar here within _NotificationsPageState
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; // Ensure widget is still in the tree
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

// --- FilterChips Widget ---
class FilterChips extends StatefulWidget {
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
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8.0,
        children: widget.filters.map((filter) {
          final isSelected = filter == widget.selectedFilter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            selectedColor: Colors.green.shade700,
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (selected) {
              if (selected) {
                widget.onFilterSelected(filter);
              }
            },
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

// --- NotificationCard Widget ---
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
        boxShadow:
            isRead // Less prominent shadow for read notifications
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                    children: buttons.map((btn) {
                      return Padding(
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
                      );
                    }).toList(),
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

// --- ActionButton Class ---
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
