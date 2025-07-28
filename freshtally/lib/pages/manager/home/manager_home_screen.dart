import 'package:Freshtally/pages/manager/analytics/analytics_dashbaord_page.dart';
import 'package:flutter/material.dart';
import 'package:Freshtally/pages/manager/managerNotifications/notifications.dart';
import 'package:Freshtally/pages/manager/staffManagement/staff_managementJoin_code.dart';
import 'package:Freshtally/pages/shelfStaff/settings/settings_page.dart';
import 'package:Freshtally/pages/manager/productAllocationView/product_allocation_view.dart';
import 'package:Freshtally/pages/manager/promotions/smart_promotions_suggestions.dart';

// import 'package:Freshtally/pages/shelfStaff/sync/sync_status_page.dart';
import 'package:Freshtally/pages/manager/promotions/promotions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerDashboardPage extends StatelessWidget {
  final String supermarketName;
  final String location;
  final String supermarketId;
  final String managerId;

  const ManagerDashboardPage({
    super.key,
    required this.supermarketName,
    required this.location,
    required this.managerId,
    required this.supermarketId,
  });

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
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supermarketName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Notifications Icon
                    IconButton(
                      icon: const Icon(Icons.notifications, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ManagerNotificationCenterPage(
                                supermarketName: supermarketName,
                                managerId: managerId,
                              );
                            },
                          ),
                        );
                        // Handle settings tap
                      },
                    ),
                    // Settings Icon
                    IconButton(
                      icon: const Icon(Icons.settings, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SettingsPage(supermarketId: supermarketId);
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
                  childAspectRatio: 1.4, // Tiles are square
                  children: [
                    _buildDashboardTile(
                      title: 'Analytics Dashboard',
                      icon: Icons.bar_chart,
                      color: const Color(0xFFE8E8E8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AnalyticsDashboardPage(
                                supermarketId: supermarketId,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Promotions page',
                      icon: Icons.card_giftcard,
                      color: const Color(0xFFFDECEB),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return PromotionsPage(
                                supermarketId: supermarketId,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    _buildDashboardTile(
                      title: 'Smart promotions',
                      icon: Icons.lightbulb,
                      color: const Color(0xFFE8E8E8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SmartPromotionsSuggestionsPage(
                                supermarketName: supermarketName,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Product allocation',
                      icon: Icons.assignment,
                      color: const Color(0xFFFFF3E0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ProductAllocationView(
                                supermarketId: supermarketId,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    _buildDashboardTile(
                      title: 'Staff Management & Join Code',

                      icon: Icons.group,
                      color: const Color(0xFFE1F5FE),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ManageStaffPage(
                                supermarketId: supermarketId,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // _buildDashboardTile(
                    //   title: 'Sync Status',
                    //   icon: Icons.sync,
                    //   color: const Color(0xFFE0F2F1), // Light green color
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) {
                    //           return SyncStatusPage(supermarketId: '');
                    //         },
                    //       ),
                    //     );
                    //   },
                    // ),
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
}

Future<void> checkPromotionExpiries() async {
  final now = DateTime.now();
  final twoDaysFromNow = now.add(const Duration(days: 2));
  final promos = await FirebaseFirestore.instance
      .collection('promotions')
      .get();

  for (var doc in promos.docs) {
    final expiryTimestamp = doc['expiryDate'];
    if (expiryTimestamp == null) continue;
    final expiry = (expiryTimestamp as Timestamp).toDate();

    if (expiry.isAfter(now) && expiry.isBefore(twoDaysFromNow)) {
      // Check if notification already exists for this promo
      final existing = await FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: 'promo_expiry')
          .where('payload.promotionId', isEqualTo: doc.id)
          .get();

      if (existing.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'type': 'promo_expiry',
          'title': 'Promotion Expiring Soon',
          'message': 'The promotion "${doc['title']}" is expiring in 2 days.',
          'payload': {'promotionId': doc.id, 'expiryDate': doc['expiryDate']},
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }
  }
}

/// A helper widget to build a single dashboard tile.
Widget _buildDashboardTile({
  required String title,
  required IconData icon,
  required Color color,
  VoidCallback? onTap,
}) {
  return SizedBox(
    child: Card(
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

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
