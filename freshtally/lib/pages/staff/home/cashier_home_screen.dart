import 'package:flutter/material.dart';
import 'package:freshtally/pages/staff/notifications/notification_center_page.dart';
import 'package:freshtally/pages/staff/settings/settings_page.dart';
import 'package:freshtally/pages/staff/sync/sync_status_page.dart';

class CashierDashboardPage extends StatelessWidget {
  const CashierDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'https://i.pravatar.cc/150?img=49',
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
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                        // Han
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
                  'Cashier Dashboard',
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
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: 1.5,
                  children: [
                    _buildDashboardTile(
                      title: 'Sales',
                      icon: Icons.point_of_sale,
                      color: const Color(0xFFE0F2F1),
                      onTap: () {
                        // TODO: Add navigation to Product Entry page if available
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Product Lookup',
                      icon: Icons.search,
                      color: const Color(0xFFE0F7FA),
                      onTap: () {
                        // TODO: Add navigation to Product Lookup page if available
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Sync Status',
                      icon: Icons.sync,
                      color: const Color(0xFFECEFF1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SyncStatusPage(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Notifications',
                      icon: Icons.notifications,
                      color: const Color(0xFFFFF3E0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationCenterPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // "Quick Scan" and "Sync Now" Buttons
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle Quick Scan
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC8E6C9),
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0.1,
                          ),
                          child: const Text(
                            'Quick Scan',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle Sync Now
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E0E0),
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0.1,
                          ),
                          child: const Text(
                            'Sync Now',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
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
