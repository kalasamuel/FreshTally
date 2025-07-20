import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:freshtally/pages/auth/role_selection_page.dart'; // Import RoleSelectionPage
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class StaffVerificationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String
  password; // Potentially sensitive, consider removing if not strictly needed
  final String phone;

  // These are no longer required on initiation; they'll be selected on this page
  final String supermarketName; // Placeholder, will be updated
  final String location; // Placeholder, will be updated
  final String? supermarketId; // Placeholder, will be updated

  const StaffVerificationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.supermarketName, // Keep for now to match constructor, but will be overridden
    required this.location, // Keep for now, but will be overridden
    this.supermarketId, // Keep for now, but will be overridden
  });

  @override
  State<StaffVerificationPage> createState() => _StaffVerificationPageState();
}

class _StaffVerificationPageState extends State<StaffVerificationPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String? _selectedSupermarketId;
  String? _selectedSupermarketName;
  String? _selectedSupermarketLocation; // To store location if needed
  List<DocumentSnapshot> _supermarketSearchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      setState(() {
        _supermarketSearchResults = [];
      });
      return;
    }

    // Perform Firestore search for supermarkets
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('supermarkets')
          .orderBy('name')
          .startAt([searchText])
          .endAt([
            '$searchText\uf8ff',
          ]) // \uf8ff is a high-range unicode character to ensure "starts with"
          .get();

      setState(() {
        _supermarketSearchResults = querySnapshot.docs;
        // Reset selected supermarket if search results change and old selection is not in new results
        if (_selectedSupermarketId != null &&
            !_supermarketSearchResults.any(
              (doc) => doc.id == _selectedSupermarketId,
            )) {
          _selectedSupermarketId = null;
          _selectedSupermarketName = null;
          _selectedSupermarketLocation = null;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error searching supermarkets: $e";
      });
    }
  }

  void _selectSupermarket(DocumentSnapshot supermarketDoc) {
    setState(() {
      _selectedSupermarketId = supermarketDoc.id;
      _selectedSupermarketName =
          supermarketDoc['name']; // Assuming 'name' field exists
      _selectedSupermarketLocation =
          supermarketDoc['location'] ??
          ''; // Assuming 'location' field exists, or default to empty
      _supermarketSearchResults = []; // Clear search results after selection
      _searchController.text =
          _selectedSupermarketName!; // Pre-fill search field with selected name
      _errorMessage = null; // Clear any previous errors
    });
  }

  Future<void> _verifyJoinCodeAndCreateStaff() async {
    if (_selectedSupermarketId == null) {
      setState(() {
        _errorMessage = 'Please select a supermarket first.';
      });
      return;
    }

    final enteredCode = _verificationCodeController.text.trim();

    if (enteredCode.length != 6) {
      setState(() {
        _errorMessage = 'Join code must be exactly 6 digits.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supermarketRef = FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(_selectedSupermarketId);
      final supermarketDoc = await supermarketRef.get();

      if (!supermarketDoc.exists) {
        throw Exception("Selected supermarket not found. Please re-select.");
      }

      final joinCodeData = supermarketDoc.data()?['meta']?['join_code'];
      final storedCode = joinCodeData?['code'];
      final expiresAtTimestamp = joinCodeData?['expiresAt'] as Timestamp?;

      if (storedCode == null || storedCode != enteredCode) {
        throw Exception("Invalid join code for the selected supermarket.");
      }

      if (expiresAtTimestamp != null &&
          expiresAtTimestamp.toDate().isBefore(DateTime.now())) {
        throw Exception("Join code has expired.");
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated. Please log in again.");
      }

      // CRITICAL: Create staff document under the specific supermarket's subcollection
      // This path is: `supermarkets/{supermarketId}/staff/{user.uid}`
      await supermarketRef.collection('staff').doc(user.uid).set({
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'email': widget.email,
        'phone': widget.phone,
        'role': 'unassigned', // Set to 'unassigned' initially.
        // User will select 'Store Manager' or 'Shelf Staff' on RoleSelectionPage.
        'supermarketId':
            _selectedSupermarketId, // Redundant but good for quick queries
        'supermarketName': _selectedSupermarketName, // For easy display
        'joinedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification successful! Now select your role.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to RoleSelectionPage, passing the determined supermarketId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSelectionPage(
            supermarketId: _selectedSupermarketId,
            role:
                'staff', // Pass a default role for the constructor, not actually used for setting role here
          ),
        ),
      );
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = "Firestore error: ${e.message}";
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // TODO: Implement QR Code scanning logic here
  void _scanQrCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code scanning not yet implemented.')),
    );
    // In a real app, you'd use a QR code scanner package.
    // The scanned data would likely be the supermarketId or the join code directly.
    // If it's the supermarketId, you'd then try to fetch the join code for it.
    // If it's the join code, you'd verify it and identify the supermarket it belongs to.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Your Supermarket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'First, search and select your Supermarket.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Supermarket Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Supermarket Name',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _supermarketSearchResults = [];
                            _selectedSupermarketId = null;
                            _selectedSupermarketName = null;
                            _selectedSupermarketLocation = null;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
            // Supermarket Search Results
            if (_supermarketSearchResults.isNotEmpty)
              Container(
                constraints: BoxConstraints(maxHeight: 200), // Limit height
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _supermarketSearchResults.length,
                  itemBuilder: (context, index) {
                    final doc = _supermarketSearchResults[index];
                    return ListTile(
                      title: Text(doc['name'] ?? 'Unnamed Supermarket'),
                      subtitle: Text(doc['location'] ?? 'No location'),
                      onTap: () => _selectSupermarket(doc),
                      tileColor: _selectedSupermarketId == doc.id
                          ? Colors.green.withOpacity(0.1)
                          : null,
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            if (_selectedSupermarketName != null)
              Column(
                children: [
                  Text(
                    'Selected Supermarket: ${_selectedSupermarketName!}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Location: ${_selectedSupermarketLocation!}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Now, enter the 6-digit join code or scan QR code.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _verificationCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Join Code',
                      errorText:
                          _errorMessage?.contains('join code') == true ||
                              _errorMessage?.contains('expired') == true
                          ? _errorMessage
                          : null,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanQrCode,
                        tooltip: 'Scan QR Code',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _verifyJoinCodeAndCreateStaff,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Verify Code and Proceed'),
                  ),
                ],
              )
            else
              const Text(
                'Start typing to search for your supermarket.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            if (_errorMessage != null &&
                (_errorMessage?.contains('supermarket') == false &&
                    _errorMessage?.contains('join code') == false &&
                    _errorMessage?.contains('expired') == false))
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
