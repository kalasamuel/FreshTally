import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:freshtally/pages/storeManager/home/home_screen.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key, required String role});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;
  String? errorMessage;
  bool isLoading = false;

  /// Fetch role & supermarketId from Firestore & navigate
  Future<void> joinRole() async {
    if (selectedRole == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not signed in");

      // Fetch staff doc
      final staffDoc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(user.uid)
          .get();

      if (!staffDoc.exists) throw Exception("Staff document not found");

      final staffData = staffDoc.data()!;
      final supermarketId = staffData['supermarketId'];
      final role = staffData['role'];

      if (role != selectedRole) {
        setState(() {
          errorMessage = "Your assigned role is '$role', not '$selectedRole'";
          isLoading = false;
        });
        return;
      }

      if (role == 'Store Manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StoreManagerDashboard(
              supermarketId: supermarketId,
              location: '',
            ),
          ),
        );
      } else if (role == 'Shelf Staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ShelfStaffDashboard(
              supermarketId: supermarketId,
              supermarketName: null,
              location: '',
            ),
          ),
        );
      } else {
        setState(() {
          errorMessage = "Unknown role: $role";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildRoleCard(String role, Widget iconWidget) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.green.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 16),
            Text(
              role,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Select Role',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Inter',
          ),
        ),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildRoleCard(
                    'Store Manager',
                    Image.asset('assets/icons/cashier.png', width: 100),
                  ),
                  buildRoleCard(
                    'Shelf Staff',
                    Image.asset('assets/icons/shelf-attendant.png', width: 100),
                  ),
                  const SizedBox(height: 30),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedRole == null || isLoading
                          ? null
                          : joinRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 1,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Join',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
