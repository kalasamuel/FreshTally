import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const NotificationsPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Currently selected filter chip
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F7D9), // Light green background
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(
              20.0,
            ), // Margin around the main content area
            decoration: BoxDecoration(
              color: Colors.white, // White background for the main card
              borderRadius: BorderRadius.circular(
                20.0,
              ), // Rounded corners for the main card
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.1,
                  ), // Subtle shadow for depth
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the start
              children: [
                // App Bar Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Back arrow icon
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Handle back button press
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8), // Spacer
                      // "Notifications" title
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Allow horizontal scrolling for chips
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
                // Notification List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    children: [
                      // Expiry Notification Card
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
                            Colors.grey[300]!,
                            Colors.black87,
                            () => print('Snooze pressed'),
                          ),
                          _buildActionButton(
                            'Mark Done',
                            const Color(0xFFFFF7A0),
                            Colors.black87,
                            () => print('Mark Done pressed'),
                          ),
                          _buildActionButton(
                            'Dismiss',
                            const Color(0xFFE6FFE6),
                            Colors.black87,
                            () => print('Dismiss pressed'),
                          ),
                        ],
                        time: 'Today, 8:30 AM',
                        cardColor: const Color(
                          0xFFFFF0F0,
                        ), // Light reddish background
                        borderColor: const Color(0xFFFFCCCC), // Reddish border
                      ),
                      const SizedBox(height: 16), // Space between cards
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
                            const Color(0xFFE0EFFF),
                            Colors.black87,
                            () => print('Sync Now pressed'),
                          ),
                          _buildActionButton(
                            'Snooze',
                            Colors.grey[300]!,
                            Colors.black87,
                            () => print('Snooze pressed'),
                          ),
                          _buildActionButton(
                            'Dismiss',
                            const Color(0xFFE6FFE6),
                            Colors.black87,
                            () => print('Dismiss pressed'),
                          ),
                        ],
                        time: 'Today, 7:45 AM',
                        cardColor: const Color(
                          0xFFF0F8F0,
                        ), // Very light green/off-white
                        borderColor: Colors.grey[300]!, // Light grey border
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
                            const Color(0xFFE0EFFF),
                            Colors.black87,
                            () => print('Mark Done pressed'),
                          ),
                          _buildActionButton(
                            'Dismiss',
                            const Color(0xFFE6FFE6),
                            Colors.black87,
                            () => print('Dismiss pressed'),
                          ),
                        ],
                        time: 'Yesterday, 10:15 PM',
                        cardColor: const Color(
                          0xFFF0F8F0,
                        ), // Very light green/off-white
                        borderColor: Colors.grey[300]!, // Light grey border
                      ),
                      const SizedBox(height: 16), // Space after the last card
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a filter chip
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
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.green, // Green when selected
        backgroundColor: Colors.grey[200], // Light grey when not selected
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = text;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.grey[300]!,
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        avatar: isSelected
            ? const Icon(Icons.check_circle, color: Colors.white, size: 18)
            : null, // Checkmark when selected
      ),
    );
  }

  // Helper method to build a notification card
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Icon
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Space below title
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
                          color: Colors.red,
                          size: 16,
                        ), // Small info icon
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detail,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16), // Space before buttons
          // Action Buttons and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis
                      .horizontal, // Allow horizontal scrolling for buttons if many
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
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build a small action button
  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 1, // Subtle elevation for buttons
        minimumSize: Size.zero, // Remove minimum size constraints
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
