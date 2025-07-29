import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Freshtally/pages/shelfStaff/settings/settings_page.dart';
import 'package:Freshtally/pages/storeManager/batches/supplier_batch_entry_page.dart';
import 'package:Freshtally/pages/storeManager/sync/sync_status_page.dart';
import 'package:Freshtally/pages/storeManager/notifications/notification_center_page.dart';
import 'package:Freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';

// The StoreManagerDashboard is now a StatefulWidget to manage fetching user and supermarket data.
class StoreManagerDashboard extends StatefulWidget {
  final String? supermarketName;
  final String supermarketId;
  final String location; // Ensure location is also passed and used

  const StoreManagerDashboard({
    super.key,
    this.supermarketName, // Can be null initially, will be fetched
    required this.supermarketId,
    required this.location, // Make location required as well
  });

  @override
  State<StoreManagerDashboard> createState() => _StoreManagerDashboardState();
}

class _StoreManagerDashboardState extends State<StoreManagerDashboard> {
  User? _currentUser;
  String _displaySupermarketName = 'Loading Supermarket...';
  String _displaySupermarketLocation = '';
  String _managerDisplayName = 'Manager';

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchSupermarketDetails();
    _loadUserProfile();
  }

  // Fetches supermarket details from Firestore using the provided supermarketId.
  Future<void> _fetchSupermarketDetails() async {
    try {
      DocumentSnapshot supermarketDoc = await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .get();

      if (supermarketDoc.exists) {
        Map<String, dynamic>? data =
            supermarketDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _displaySupermarketName = data['name'] ?? 'Unnamed Supermarket';
            _displaySupermarketLocation =
                data['location'] ?? 'Unknown Location';
          });
        }
      } else {
        setState(() {
          _displaySupermarketName = 'Supermarket Not Found';
          _displaySupermarketLocation = 'N/A';
        });
      }
    } catch (e) {
      debugPrint('Error fetching supermarket details: $e');
      setState(() {
        _displaySupermarketName = 'Error Loading Supermarket';
        _displaySupermarketLocation = 'N/A';
      });
    }
  }

  // Loads the current user's profile details from Firebase Auth.
  void _loadUserProfile() {
    if (_currentUser != null) {
      setState(() {
        _managerDisplayName =
            _currentUser!.displayName ??
            _currentUser!.email?.split('@')[0] ??
            'Manager';
      });
    }
  }

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
                    const SizedBox(width: 12),
                    // Supermarket Name and Manager Role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_displaySupermarketName - Store Manager',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _managerDisplayName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, size: 30),
                      onPressed: () {
                        // Navigate to NotificationCenterPage, passing supermarketId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return NotificationsPage(
                                supermarketId: widget.supermarketId,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    // Settings Icon
                    IconButton(
                      icon: const Icon(Icons.settings, size: 30),
                      onPressed: () {
                        // Navigate to SettingsPage, passing supermarketId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              supermarketId: widget.supermarketId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Dashboard Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Text(
                  'Store Manager Dashboard',
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
                      const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: 1.5, // Adjust aspect ratio for tile size
                  children: [
                    _buildDashboardTile(
                      title: 'Supplier and Batch Entry',
                      icon: Icons.inventory,
                      color: const Color(0xFFD1F2EB),
                      onTap: () {
                        // Navigate to SupplierBatchEntryPage, passing supermarketId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupplierBatchEntryPage(
                              supermarketId: widget.supermarketId,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      title: 'Sync Status',
                      icon: Icons.sync,
                      color: const Color(0xFFF1F8E9),
                      onTap: () {
                        // Navigate to SyncStatusPage, passing supermarketId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SyncStatusPage(
                              supermarketId: widget.supermarketId,
                            ),
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

  // Helper widget for dashboard tiles
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
