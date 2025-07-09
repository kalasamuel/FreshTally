import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: NotificationsScreen()),
  );
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterChips(),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  NotificationCard(
                    title: 'Fresh Milk 500ml',
                    description:
                        'Expires in 1 day. Qty: 15 units\nRecovery: UGX 25,000',
                    time: 'Today, 8:30 AM',
                    color: Colors.red[50],
                    icon: Icons.error_outline,
                    iconColor: Colors.red,
                    buttons: [
                      ActionButton(label: 'Snooze', color: Colors.grey[300]!),
                      ActionButton(
                        label: 'Mark Done',
                        color: Colors.yellow[200]!,
                      ),
                      ActionButton(label: 'Dismiss', color: Colors.green[100]!),
                    ],
                  ),
                  SizedBox(height: 12),
                  NotificationCard(
                    title: 'Sync Reminder',
                    description: '3 items pending sync',
                    time: 'Today, 7:45 AM',
                    color: Colors.green[50],
                    icon: Icons.sync,
                    iconColor: Colors.green,
                    buttons: [
                      ActionButton(label: 'Sync Now', color: Colors.blue[100]!),
                      ActionButton(label: 'Snooze', color: Colors.grey[300]!),
                      ActionButton(label: 'Dismiss', color: Colors.green[100]!),
                    ],
                  ),
                  SizedBox(height: 12),
                  NotificationCard(
                    title: 'Rice 10kg',
                    description:
                        'Low stock: Only 2 left\nEstimated loss: UGX 18,000',
                    time: 'Yesterday, 10:15 PM',
                    color: Colors.green[50],
                    icon: Icons.info_outline,
                    iconColor: Colors.orange,
                    buttons: [
                      ActionButton(
                        label: 'Mark Done',
                        color: Colors.blue[100]!,
                      ),
                      ActionButton(label: 'Dismiss', color: Colors.green[100]!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  final filters = ['All', 'Expiry', 'Restock', 'Sync', 'Suggestions'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: filters.map((filter) {
        final isSelected = filter == 'Suggestions';
        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          selectedColor: Colors.green,
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
          onSelected: (_) {},
        );
      }).toList(),
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

  NotificationCard({
    required this.title,
    required this.description,
    required this.time,
    this.color,
    required this.icon,
    required this.iconColor,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(description),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: buttons.map((btn) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btn.color,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(btn.label),
                    ),
                  );
                }).toList(),
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

  ActionButton({required this.label, required this.color});
}
