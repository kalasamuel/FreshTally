import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../managerNotifications/notifications.dart';
import '../staffCodeGeneration/staff_code_generation_page.dart';
import '../../../models/user_model.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({Key? key}) : super(key: key);

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _supermarketInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSupermarketInfo();
  }

  Future<void> _loadSupermarketInfo() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.email).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final supermarketId = userData['supermarketId'];
          
          if (supermarketId != null) {
            final supermarketDoc = await _firestore.collection('supermarkets').doc(supermarketId).get();
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data() as Map<String, dynamic>;
              setState(() {
                _supermarketInfo = {
                  'id': supermarketId,
                  'name': supermarketData['name'] ?? 'Unknown Supermarket',
                  'location': supermarketData['location'] ?? 'Unknown Location',
                };
                _isLoading = false;
              });
            }
          }
        }
      }
    } catch (error) {
      print('Error loading supermarket info: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_supermarketInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manager Dashboard'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No supermarket information found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagerNotificationsPage(
                    supermarketInfo: _supermarketInfo!,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supermarket Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _supermarketInfo!['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _supermarketInfo!['location'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerNotificationsPage(
                            supermarketInfo: _supermarketInfo!,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.code,
                    title: 'Generate Staff Code',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffCodeGenerationPage(
                            supermarketInfo: _supermarketInfo!,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to analytics page
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.local_offer,
                    title: 'Promotions',
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to promotions page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffCodeGenerationPage(
                supermarketInfo: _supermarketInfo!,
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Generate Staff Code',
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
