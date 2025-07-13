import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
// Import the flutter_typeahead package
import 'package:flutter_typeahead/flutter_typeahead.dart';

class StaffVerificationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String supermarketName;

  const StaffVerificationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.supermarketName,
  });

  @override
  State<StaffVerificationPage> createState() => _StaffVerificationPageState();
}

class _StaffVerificationPageState extends State<StaffVerificationPage> {
  final TextEditingController _searchSupermarketController =
      TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isLoading = false;
  String? _verificationError;
  String? _selectedSupermarketId; // Stores the ID of the selected supermarket
  String? _supermarketSearchError; // New error state for supermarket search

  @override
  void initState() {
    super.initState();
    // Pre-fill the supermarket name field for UI consistency
    _searchSupermarketController.text = widget.supermarketName;
    // If a supermarket name is passed, assume it's initially selected
    if (widget.supermarketName.isNotEmpty) {
      // You might want to fetch the ID here if it's crucial for initial state.
      // For now, we'll just pre-fill the text.
    }
  }

  @override
  void dispose() {
    _searchSupermarketController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndCreateAccount() async {
    final enteredCode = _verificationCodeController.text.trim();

    // Reset previous errors
    setState(() {
      _verificationError = null;
      _supermarketSearchError = null;
      _isLoading = true;
    });

    if (_selectedSupermarketId == null ||
        _searchSupermarketController.text.isEmpty) {
      setState(() {
        _supermarketSearchError =
            'Please select a supermarket from the suggestions.';
        _isLoading = false;
      });
      return;
    }

    if (enteredCode.length != 6) {
      setState(() {
        _verificationError = 'Code must be exactly 6 characters.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch the selected supermarket document using its ID
      final supermarketDoc = await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(_selectedSupermarketId!)
          .get();

      if (!supermarketDoc.exists) {
        setState(() {
          _supermarketSearchError =
              'Selected supermarket does not exist or was removed.';
          _isLoading = false;
        });
        return;
      }

      // Check if join code matches the one in the selected supermarket
      final meta =
          supermarketDoc.data()?['meta'] ?? {}; // Use .data() to access map
      final joinCode = meta['join_code']?['code'] ?? '';

      if (joinCode != enteredCode) {
        setState(() {
          _verificationError = 'Invalid join code for this supermarket.';
          _isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(_selectedSupermarketId!)
          .collection('staff')
          .add({
            'name': '${widget.firstName} ${widget.lastName}',
            'email': widget.email,
            'phone': widget.phone,
            'role': 'Staff',
            'joined_at': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShelfStaffDashboard()),
      );
    } catch (e) {
      setState(() {
        _verificationError = 'An error occurred: $e'; // Generic error message
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Verify Your Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Supermarket Section
                  Center(
                    child: Text(
                      'Search Supermarket',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TypeAheadField for supermarket search
                  TypeAheadField<DocumentSnapshot>(
                    controller: _searchSupermarketController,
                    builder: (context, controller, focusNode) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search Supermarket Name',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) return [];

                      final querySnapshot = await FirebaseFirestore.instance
                          .collection('supermarkets')
                          .where('name', isGreaterThanOrEqualTo: pattern)
                          .where('name', isLessThanOrEqualTo: '$pattern\uf8ff')
                          .limit(10)
                          .get();

                      return querySnapshot.docs;
                    },
                    itemBuilder: (context, DocumentSnapshot doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(title: Text(data['name'] ?? 'Unnamed'));
                    },
                    onSelected: (DocumentSnapshot doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      setState(() {
                        _searchSupermarketController.text = data['name'];
                        _selectedSupermarketId = doc.id;
                        _supermarketSearchError =
                            null; // Clear error on selection
                      });
                    },
                  ),
                  // Display error message below the supermarket search field
                  if (_supermarketSearchError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        _supermarketSearchError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 40),
                  // Enter 6-digit Join Code Section
                  Center(
                    child: Text(
                      'Enter 6-digit Join Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Enter Join Code',
                    _verificationCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    // errorText: _verificationError, // This line is now removed
                  ),
                  // Display error message below the join code field
                  if (_verificationError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        _verificationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 40),
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyAndCreateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 1,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Verify and Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    // Removed errorText parameter as it's handled separately
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
          counterText: '', // Hide the default character counter
          // errorText is removed from here
        ),
      ),
    );
  }
}
