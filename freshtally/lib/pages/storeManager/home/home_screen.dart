import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/settings/settings_page.dart';
import 'package:freshtally/pages/shelfStaff/expiry/expiry_tracking_page.dart';
import 'package:freshtally/pages/shelfStaff/notifications/notifications_shelfstaff.dart';
import 'package:freshtally/pages/shelfStaff/shelves/shelf_mapping_page.dart';
import 'package:freshtally/pages/shelfStaff/shelves/smart_suggestions_page.dart';
import 'package:freshtally/pages/shelfStaff/sync/sync_status_page.dart';
// import 'package:freshtally/pages/staff/products/edit_product_page.dart';
import 'package:freshtally/pages/shelfStaff/products/product_entry_page.dart';

class StoreManagerDashboardPage extends StatelessWidget {
  const StoreManagerDashboardPage({super.key});

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
                        'https://i.pravatar.cc/150?img=52',
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
                  'Shelf Staff Dashboard',
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
                      title: 'Shelf Mapping',
                      icon: Icons.location_on,
                      color: const Color(0xFFD1F2EB),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShelfMappingPage(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Expiry Tracker',
                      icon: Icons.calendar_today,
                      color: const Color(0xFFFDECEB),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExpiryTrackingPage(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Product Entry',
                      icon: Icons.qr_code_scanner,
                      color: const Color(0xFFE0F2F1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductEntryPage(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Sync Status',
                      icon: Icons.sync,
                      color: const Color(0xFFE8E8E8),
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
                      title: 'Smart Suggestions',
                      icon: Icons.lightbulb_outline,
                      color: const Color(0xFFE8E8E8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SmartShelfSuggestionsPage(),
                          ),
                        );
                      },
                    ),
                    // _buildDashboardTile(
                    //   title: 'Edit Products',
                    //   icon: Icons.edit_square,
                    //   color: const Color(0xFFE0F2F1),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const EditProductPage(),
                    //       ),
                    //     );
                    //   },
                    // ),
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

              // Bottom Buttons
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
