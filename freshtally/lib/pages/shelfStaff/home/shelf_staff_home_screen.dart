import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/notifications/notifications_shelfstaff.dart';
import 'package:freshtally/pages/shelfStaff/settings/settings_page.dart';
import 'package:freshtally/pages/shelfStaff/products/price_entry.dart';
import 'package:freshtally/pages/shelfStaff/shelves/shelf_mapping_page.dart';
import 'package:freshtally/pages/shelfStaff/shelves/smart_suggestions_page.dart';
import 'package:freshtally/pages/shelfStaff/sync/sync_status_page.dart';

class ShelfStaffDashboard extends StatelessWidget {
  final String? supermarketName;
  final String? location;

  const ShelfStaffDashboard({super.key, this.supermarketName, this.location});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Ensures no default back button is added.
        backgroundColor: const Color(
          0xFFFFFFFF,
        ), // AppBar background color matches the body for a clean UI.
        elevation: 0.0, // Removes the shadow under the app bar for a flat look.
        // Adjust leadingWidth to accommodate the avatar and desired padding.
        // (28 radius * 2 diameter) + 16 (for 8px padding on each side) = 56 + 16 = 72
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
          ), // Add left padding to the avatar.
          child: CircleAvatar(
            radius: 28, // Increased radius for a slightly larger circular icon.
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=60',
            ), // Placeholder image.
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              supermarketName ?? 'Supermarket',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (location != null)
              Text(
                location!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
        centerTitle: false, // Centers the title in the app bar.
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: Colors.black87,
            ), // Added color for consistency.
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationCenterPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 30,
              color: Colors.black87,
            ), // Added color for consistency.
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Text(
                  'Shelf Attendant Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
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
                      icon: Icons.map,
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
                      title: 'Price Entry',
                      icon: Icons.price_change,
                      color: const Color(0xFFFDECEB),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PriceEntryPage(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Sync Status',
                      icon: Icons.sync,
                      color: const Color(0xFFE0F2F1),
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
                      icon: Icons.lightbulb,
                      color: const Color(0xFFF1F8E9),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
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
}
