import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:Freshtally/pages/storeManager/home/home_screen.dart';

class RoleSelectionPage extends StatefulWidget {
  final String? supermarketId;
  final String role;
  final String? userId; // Added userId parameter

  const RoleSelectionPage({
    super.key,
    this.supermarketId,
    required this.role,
    this.userId, // Added to constructor
  });

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize selectedRole with the passed role if needed
    selectedRole = widget.role;
  }

  /// Update user document and staff document with selected role & navigate
  Future<void> joinRole() async {
    if (selectedRole == null) {
      setState(() {
        errorMessage = "Please select a role.";
      });
      return;
    }

    if (widget.supermarketId == null) {
      setState(() {
        errorMessage =
            "Supermarket ID is missing. Cannot assign role. Please restart signup.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId =
          user?.uid ?? widget.userId; // Use current user or passed userId

      if (userId == null) {
        throw Exception("User not signed in. Please sign up or log in again.");
      }

      // First, get the supermarket name from the supermarkets collection
      final supermarketDoc = await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(widget.supermarketId!)
          .get();

      if (!supermarketDoc.exists) {
        throw Exception("Supermarket not found");
      }

      final supermarketName = supermarketDoc.data()?['name'] ?? 'Unknown';

      // Prepare the user data
      final userData = {
        'createdAt': FieldValue.serverTimestamp(),
        'email': user?.email ?? '', // Use current user email or empty
        'firstName': '', // These should come from previous steps
        'lastName': '', // These should come from previous steps
        'location': '', // These should come from previous steps
        'role': selectedRole!.toLowerCase(),
        'supermarketId': widget.supermarketId,
        'supermarketName': supermarketName,
        'uid': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update the user's document in the 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(
            userData,
            SetOptions(merge: true),
          ); // Use merge to preserve existing fields

      await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(widget.supermarketId!)
          .collection('staff')
          .doc(userId)
          .set(userData, SetOptions(merge: true));

      // Navigate to the appropriate dashboard
      if (!mounted) return;

      if (selectedRole == 'Store Manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StoreManagerDashboard(
              supermarketId: widget.supermarketId!,
              location: userData['location'] ?? '',
            ),
          ),
        );
      } else if (selectedRole == 'Shelf Staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ShelfStaffDashboard(
              supermarketId: widget.supermarketId!,
              supermarketName: supermarketName,
              location: userData['location'] ?? '',
            ),
          ),
        );
      } else {
        setState(() {
          errorMessage = "Selected role is invalid: $selectedRole";
        });
      }
    } on FirebaseException catch (e) {
      setState(() {
        errorMessage = "Firestore error: ${e.message}";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to assign role: ${e.toString()}";
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
                  Text(
                    'You are joining: ${widget.supermarketId != null ? "Supermarket ID: ${widget.supermarketId}" : "..."}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
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
