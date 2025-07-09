import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/settings/settings_page.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 8.0,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Expiry'),
                        _buildFilterChip('Restock'),
                        _buildFilterChip('Sync'),
                        _buildFilterChip('Suggestions'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildNotificationCard(
                  context,
                  title: 'Fresh Milk 500ml',
                  icon: Icons.error_outline,
                  iconColor: Colors.red,
                  details: [
                    'Expires in 1 day. Qty: 15 units',
                    'Recovery: UGX 25,000',
                  ],
                  actionButtons: [
                    _buildActionButton(
                      'Snooze',
                      const Color(0xFFE0E0E0),
                      Colors.black87,
                      () => debugPrint('Snooze pressed'),
                    ),
                    _buildActionButton(
                      'Mark Done',
                      const Color(0xFFFFCC80),
                      Colors.black87,
                      () => debugPrint('Mark Done pressed'),
                    ),
                    _buildActionButton(
                      'Dismiss',
                      const Color(0xFFC8E6C9),
                      Colors.black87,
                      () => debugPrint('Dismiss pressed'),
                    ),
                  ],
                  time: 'Today, 8:30 AM',
                  cardColor: const Color(0xFFFFF0F0),
                  borderColor: const Color(0xFFFFCCCC),
                ),
                const SizedBox(height: 16),
                _buildNotificationCard(
                  context,
                  title: 'Sync Reminder',
                  icon: Icons.sync,
                  iconColor: Colors.black87,
                  details: ['3 items pending sync'],
                  actionButtons: [
                    _buildActionButton(
                      'Sync Now',
                      const Color(0xFFC8E6C9),
                      Colors.black87,
                      () => debugPrint('Sync Now pressed'),
                    ),
                    _buildActionButton(
                      'Snooze',
                      const Color(0xFFE0E0E0),
                      Colors.black87,
                      () => debugPrint('Snooze pressed'),
                    ),
                    _buildActionButton(
                      'Dismiss',
                      const Color(0xFFFFCC80),
                      Colors.black87,
                      () => debugPrint('Dismiss pressed'),
                    ),
                  ],
                  time: 'Today, 7:45 AM',
                  cardColor: const Color(0xFFF5F6FA),
                  borderColor: Colors.transparent,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text) {
    final bool isSelected = _selectedFilter == text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFFF5F6FA),
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = text;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        avatar: isSelected
            ? const Icon(Icons.check_circle, color: Colors.white, size: 18)
            : null,
        elevation: 0.1,
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> details,
    required List<Widget> actionButtons,
    required String time,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                          Icon(Icons.info_outline, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detail,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: actionButtons
                          .map(
                            (button) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: button,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0.1,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
