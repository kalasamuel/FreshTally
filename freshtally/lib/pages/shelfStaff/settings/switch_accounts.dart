import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Freshtally/pages/auth/supermarket_selection_page.dart';
import 'package:Freshtally/pages/customer/home/customer_home_page.dart';
import 'package:Freshtally/pages/manager/home/manager_home_screen.dart';
import 'package:Freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:Freshtally/pages/storeManager/home/home_screen.dart';

class AccountHistoryPage extends StatefulWidget {
  const AccountHistoryPage({super.key});

  @override
  State<AccountHistoryPage> createState() => _AccountHistoryPageState();
}

class _AccountHistoryPageState extends State<AccountHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _previousAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviousAccounts();
  }

  Future<void> _loadPreviousAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList('previous_accounts') ?? [];
    final currentUser = _auth.currentUser;
    if (currentUser?.email != null) {
      accounts.remove(currentUser!.email!);
    }
    setState(() {
      _previousAccounts = accounts;
      _isLoading = false;
    });
  }

  Future<void> _addCurrentAccountToHistory() async {
    final currentUser = _auth.currentUser;
    final email = currentUser?.email;
    if (email != null) {
      final prefs = await SharedPreferences.getInstance();
      final accounts = prefs.getStringList('previous_accounts') ?? [];
      accounts.remove(email);
      accounts.insert(0, email);
      if (accounts.length > 5) {
        accounts.removeLast();
      }
      await prefs.setStringList('previous_accounts', accounts);
    }
  }

  Future<void> _promptPasswordAndLogin(String email) async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign in to $email'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, passwordController.text.trim()),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
    if (password == null || password.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _addCurrentAccountToHistory();

      final userId = credential.user?.uid;
      if (userId == null) throw Exception('Missing UID after login.');

      // --- CUSTOMER LOGIN FLOW LOGIC ---
      final customerDoc = await _firestore
          .collection('customers')
          .doc(userId)
          .get();

      String role;
      List<String> associatedSupermarketIds = [];
      String? staffOrManagerSupermarketId;

      if (customerDoc.exists) {
        final customerData = customerDoc.data();
        role = customerData?['role'] as String? ?? 'customer';
        associatedSupermarketIds = List<String>.from(
          customerData?['associatedSupermarketIds'] ?? [],
        );
      } else {
        final userQuery = await _firestore
            .collectionGroup('users')
            .where('uid', isEqualTo: userId)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          throw Exception('User document not found in Firestore.');
        }

        final userDoc = userQuery.docs.first;
        final userData = userDoc.data();
        role = userData['role'] as String? ?? 'unknown';
        staffOrManagerSupermarketId = userDoc.reference.parent.parent?.id;
      }

      if (!mounted) return;

      // Navigate based on role - MATCHING YOUR LOGIN PAGE LOGIC
      switch (role) {
        case 'manager':
          String supermarketName = 'Unknown';
          String location = 'Unknown';
          if (staffOrManagerSupermarketId != null) {
            final supermarketDoc = await _firestore
                .collection('supermarkets')
                .doc(staffOrManagerSupermarketId)
                .get();
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data();
              supermarketName =
                  supermarketData?['name'] as String? ?? 'Unknown';
              location = supermarketData?['location'] as String? ?? 'Unknown';
            }
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerDashboardPage(
                supermarketName: supermarketName,
                location: location,
                managerId: userId,
                supermarketId: staffOrManagerSupermarketId!,
              ),
            ),
          );
          break;

        case 'storeManager':
          String supermarketName = 'Unknown';
          String location = 'Unknown';
          if (staffOrManagerSupermarketId != null) {
            final supermarketDoc = await _firestore
                .collection('supermarkets')
                .doc(staffOrManagerSupermarketId)
                .get();
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data();
              supermarketName =
                  supermarketData?['name'] as String? ?? 'Unknown';
              location = supermarketData?['location'] as String? ?? 'Unknown';
            }
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StoreManagerDashboard(
                supermarketId: staffOrManagerSupermarketId!,
                supermarketName: supermarketName,
                location: location,
              ),
            ),
          );
          break;

        case 'staff':
          String supermarketName = 'Unknown';
          String location = 'Unknown';
          if (staffOrManagerSupermarketId != null) {
            final supermarketDoc = await _firestore
                .collection('supermarkets')
                .doc(staffOrManagerSupermarketId)
                .get();
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data();
              supermarketName =
                  supermarketData?['name'] as String? ?? 'Unknown';
              location = supermarketData?['location'] as String? ?? 'Unknown';
            }
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ShelfStaffDashboard(
                supermarketId: staffOrManagerSupermarketId!,
                supermarketName: supermarketName,
                location: location,
              ),
            ),
          );
          break;

        case 'customer':
          if (associatedSupermarketIds.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SupermarketSelectionPage(
                  customerId: userId,
                  initialMessage:
                      'No supermarkets linked to your account. Please join one.',
                ),
              ),
            );
          } else if (associatedSupermarketIds.length == 1) {
            final String singleSupermarketId = associatedSupermarketIds.first;
            final supermarketDoc = await _firestore
                .collection('supermarkets')
                .doc(singleSupermarketId)
                .get();
            String supermarketName = 'Unknown';
            String location = 'Unknown';
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data();
              supermarketName =
                  supermarketData?['name'] as String? ?? 'Unknown';
              location = supermarketData?['location'] as String? ?? 'Unknown';
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerHomePage(
                  supermarketName: supermarketName,
                  location: location,
                  supermarketId: singleSupermarketId,
                  userId: userId,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SupermarketSelectionPage(
                  customerId: userId,
                  associatedSupermarketIds: associatedSupermarketIds,
                ),
              ),
            );
          }
          break;

        default:
          throw Exception("Unknown user role: $role. Contact support.");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-in failed: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _previousAccounts.isEmpty
                ? const Center(child: Text('No previous accounts found'))
                : ListView.builder(
                    itemCount: _previousAccounts.length,
                    itemBuilder: (context, index) {
                      final email = _previousAccounts[index];
                      return ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: Text(email),
                        onTap: () => _promptPasswordAndLogin(email),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final accounts = List<String>.from(
                              _previousAccounts,
                            );
                            accounts.removeAt(index);
                            await prefs.setStringList(
                              'previous_accounts',
                              accounts,
                            );
                            setState(() {
                              _previousAccounts = accounts;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('New Account'),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
          ),
        ],
      ),
    );
  }
}
