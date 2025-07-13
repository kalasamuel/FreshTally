import 'package:flutter/material.dart';
// Assuming settings page is shared or similar

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key, required String supermarketId});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  // Currently selected filter chip
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFFFFF,
      ), // Sets the background color of the scaffold to white.
      appBar: AppBar(
        backgroundColor: const Color(
          0xFFFFFFFF,
        ), // AppBar background color matches the body.
        elevation: 0.0, // Removes the shadow under the app bar for a flat look.

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true, // Centers the title in the app bar.
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal:
                  24.0, // Consistent horizontal padding for the content.
              vertical: 24.0, // Consistent vertical padding for the content.
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Aligns children to the start (left).
              children: [
                // Section Title for "Notifications".
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20, // Consistent section title font size.
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24), // Space below the section title.
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0.0, // Adjusted to match main padding.
                    vertical: 8.0,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis
                        .horizontal, // Allow horizontal scrolling for chips.
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
                const SizedBox(
                  height: 16,
                ), // Space between chips and notification list.
                // Notification List
                // Using Column directly for demonstration; in a real app,
                // you might use ListView.builder for performance with many items.
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
                      const Color(0xFFE0E0E0), // Lighter grey for consistency.
                      Colors.black87,
                      () => debugPrint('Snooze pressed'),
                    ),
                    _buildActionButton(
                      'Mark Done',
                      const Color(
                        0xFFFFCC80,
                      ), // Lighter orange/amber for consistency.
                      Colors.black87,
                      () => debugPrint('Mark Done pressed'),
                    ),
                    _buildActionButton(
                      'Dismiss',
                      const Color(0xFFC8E6C9), // Light green for consistency.
                      Colors.black87,
                      () => debugPrint('Dismiss pressed'),
                    ),
                  ],
                  time: 'Today, 8:30 AM',
                  cardColor: const Color(
                    0xFFFFF0F0,
                  ), // Light reddish background.
                  borderColor: const Color(0xFFFFCCCC), // Reddish border.
                ),
                const SizedBox(height: 16), // Space between cards.
                // Sync Reminder Notification Card
                _buildNotificationCard(
                  context,
                  title: 'Sync Reminder',
                  icon: Icons.sync,
                  iconColor: Colors.black87,
                  details: ['3 items pending sync'],
                  actionButtons: [
                    _buildActionButton(
                      'Sync Now',
                      const Color(0xFFC8E6C9), // Light green for consistency.
                      Colors.black87,
                      () => debugPrint('Sync Now pressed'),
                    ),
                    _buildActionButton(
                      'Snooze',
                      const Color(0xFFE0E0E0), // Lighter grey for consistency.
                      Colors.black87,
                      () => debugPrint('Snooze pressed'),
                    ),
                    _buildActionButton(
                      'Dismiss',
                      const Color(
                        0xFFFFCC80,
                      ), // Lighter orange/amber for consistency.
                      Colors.black87,
                      () => debugPrint('Dismiss pressed'),
                    ),
                  ],
                  time: 'Today, 7:45 AM',
                  cardColor: const Color(
                    0xFFF5F6FA,
                  ), // Consistent light background.
                  borderColor: Colors.transparent, // No border for this card.
                ),
                const SizedBox(height: 16),

                // Low Stock Notification Card
                _buildNotificationCard(
                  context,
                  title: 'Rice 10kg',
                  icon: Icons.info_outline,
                  iconColor: Colors.red,
                  details: [
                    'Low stock: Only 2 left',
                    'Estimated loss: UGX 18,000',
                  ],
                  actionButtons: [
                    _buildActionButton(
                      'Mark Done',
                      const Color(0xFFC8E6C9), // Light green for consistency.
                      Colors.black87,
                      () => debugPrint('Mark Done pressed'),
                    ),
                    _buildActionButton(
                      'Dismiss',
                      const Color(0xFFE0E0E0), // Lighter grey for consistency.
                      Colors.black87,
                      () => debugPrint('Dismiss pressed'),
                    ),
                  ],
                  time: 'Yesterday, 10:15 PM',
                  cardColor: const Color(
                    0xFFF5F6FA,
                  ), // Consistent light background.
                  borderColor: Colors.transparent, // No border for this card.
                ),
                const SizedBox(height: 16), // Space after the last card.
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a filter chip.
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
            fontSize: 15, // Consistent font size for chips.
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF4CAF50), // Green when selected.
        backgroundColor: const Color(
          0xFFF5F6FA,
        ), // Light background when not selected.
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = text;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.0,
          ), // Consistent rounded corners.
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : Colors
                      .transparent, // Green border when selected, transparent otherwise.
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ), // Adjusted padding.
        avatar: isSelected
            ? const Icon(Icons.check_circle, color: Colors.white, size: 18)
            : null, // Checkmark when selected.
        elevation: 0.1, // Subtle elevation for chips.
      ),
    );
  }

  // Helper method to build a notification card.
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
      elevation: 0.1, // Subtle elevation for cards.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners for cards.
        side: BorderSide(color: borderColor), // Apply border color here.
      ),
      color: cardColor, // Apply card background color.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Icon
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24), // Consistent icon size.
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18, // Consistent title font size.
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Space below title.
            // Details
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
                            color: Colors.red, // Small info icon.
                            size: 18, // Consistent info icon size.
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detail,
                              style: const TextStyle(
                                color: Colors.black87, // Consistent text color.
                                fontSize: 15, // Consistent font size.
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16), // Space before buttons.
            // Action Buttons and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis
                        .horizontal, // Allow horizontal scrolling for buttons if many.
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
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ), // Time text style.
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a small action button.
  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      // Wrap ElevatedButton in SizedBox for fixed height
      height: 36, // Consistent small button height.
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ), // Consistent rounded corners.
          elevation: 0.1, // Subtle elevation for buttons.
          minimumSize: Size.zero, // Remove minimum size constraints.
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target.
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14, // Consistent font size for action buttons.
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
