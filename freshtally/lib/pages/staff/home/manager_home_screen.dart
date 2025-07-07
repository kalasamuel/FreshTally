import 'package:flutter/material.dart';
import 'package:freshtally/pages/staff/expiry/expiry_tracking_page.dart';
import 'package:freshtally/pages/staff/notifications/notification_center_page.dart';
import 'package:freshtally/pages/staff/settings/settings_page.dart';
import 'package:freshtally/pages/staff/shelves/shelf_mapping_page.dart';
import 'package:freshtally/pages/staff/shelves/smart_suggestions_page.dart';
import 'package:freshtally/pages/staff/sync/sync_status_page.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background color from the image
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Profile and Settings
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    // Profile Image
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=48',
                      ), // Placeholder image
                    ),
                    const SizedBox(width: 12),
                    // Supermarket Name
                    const Text(
                      'Mega Supermarket - Kampala',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // Settings Icon
                    IconButton(
                      icon: const Icon(Icons.settings, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SettingsPage();
                            },
                          ),
                        );
                        // Handle settings tap
                      },
                    ),
                  ],
                ),
              ),

              // Dashboard Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Text(
                  'Manager Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Dashboard Tiles Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable grid scrolling
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0, // Space between columns
                  mainAxisSpacing: 20.0, // Space between rows
                  childAspectRatio: 1.5, // Tiles are square
                  children: [
                    _buildDashboardTile(
                      title: 'Analytics Dashboard',
                      icon: Icons.bar_chart,
                      color: const Color(0xFFE8E8E8), // Grey color from image
                    ),
                    _buildDashboardTile(
                      title: 'Expiry Tracker',
                      icon: Icons.calendar_today, // Closest matching icon
                      color: const Color(0xFFFDECEB), // Pink color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ExpiryTrackingPage();
                            },
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Notifications',
                      icon: Icons.notifications,
                      color: const Color(0xFFFFF3E0), // Beige/Yellow color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return NotificationCenterPage();
                            },
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'User Role Management',
                      icon: Icons.group,
                      color: const Color(0xFFE0F2F1), // Light green color
                    ),
                    _buildDashboardTile(
                      title: 'Inventory List',
                      icon: Icons.inventory_2, // Closest matching icon
                      color: const Color(0xFFFFF3E0), // Beige/Yellow color
                    ),
                    _buildDashboardTile(
                      title: 'Shelf Mapping',
                      icon: Icons.location_on,
                      color: const Color(0xFFE0F2F1), // Light green color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ShelfMappingPage();
                            },
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Sync Status',
                      icon: Icons.sync,
                      color: const Color(0xFFE8E8E8), // Grey color
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SyncStatusPage();
                            },
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Smart Suggestions',
                      icon: Icons.lightbulb_outline,
                      color: const Color(0xFFFFF3E0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SmartShelfSuggestionsPage();
                            },
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Product Entry',
                      icon: Icons.qr_code_scanner, // Barcode icon
                      color: const Color(0xFFE0F2F1), // Light green color
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // "Sync Now" Button
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Sync Now
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green color
                      minimumSize: const Size(50, 60), // Full width and height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0.1,
                    ),
                    child: const Text(
                      'Sync Now',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// A helper widget to build a single dashboard tile.
Widget _buildDashboardTile({
  required String title,
  required IconData icon,
  required Color color,
  VoidCallback? onTap,
}) {
  return Card(
    elevation: 0.1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: color,
    child: InkWell(
      onTap:
          onTap ??
          () {
            debugPrint('$title tile tapped!');
          },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
