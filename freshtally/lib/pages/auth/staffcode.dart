import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';

class StaffVerificationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String supermarketName;
  final String location;
  final String? supermarketId;

  const StaffVerificationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.supermarketName,
    required this.location,
    this.supermarketId,
  });

  @override
  State<StaffVerificationPage> createState() => _StaffVerificationPageState();
}

class _StaffVerificationPageState extends State<StaffVerificationPage> {
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isLoading = false;
  String? _verificationError;

  Future<void> _verifyAndCreateAccount() async {
    final enteredCode = _verificationCodeController.text.trim();

    if (enteredCode.length != 6) {
      setState(() {
        _verificationError = 'Code must be exactly 6 characters.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _verificationError = null;
    });

    try {
      // Look for supermarket with this join code
      final querySnapshot = await FirebaseFirestore.instance
          .collection('supermarkets')
          .where('meta.join_code.code', isEqualTo: enteredCode)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _verificationError = 'Invalid or expired join code.';
          _isLoading = false;
        });
        return;
      }

      final supermarketDoc = querySnapshot.docs.first;
      final supermarketId = supermarketDoc.id;

      // Save staff under supermarket
      await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(supermarketId)
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
        MaterialPageRoute(
          builder: (context) => ShelfStaffDashboard(
            supermarketId: supermarketId,
            supermarketName: null,
            location: '',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _verificationError = 'Error verifying code: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Enter the 6-digit join code provided by your manager.',
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
                errorText: _verificationError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyAndCreateAccount,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify and Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
