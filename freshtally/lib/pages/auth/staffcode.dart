// staff_verification_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';

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
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isLoading = false;
  String? _verificationError;

  Future<void> _verifyAndCreateAccount() async {
    if (_verificationCodeController.text.length != 6) {
      setState(() {
        _verificationError = 'Code must be exactly 6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _verificationError = null;
    });

    try {
      // Check if the verification code exists and is valid
      final querySnapshot = await FirebaseFirestore.instance
          .collection('verification_codes')
          .where('code', isEqualTo: _verificationCodeController.text)
          .where('supermarketName', isEqualTo: widget.supermarketName)
          .where('isUsed', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _verificationError = 'Invalid verification code or supermarket name';
          _isLoading = false;
        });
        return;
      }

      // Code is valid, mark it as used
      await querySnapshot.docs.first.reference.update({'isUsed': true});

      // Create the staff account
      await FirebaseFirestore.instance.collection('staff').add({
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'email': widget.email,
        'phone': widget.phone,
        'supermarketName': widget.supermarketName,
        'verificationCode': _verificationCodeController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShelfStaffDashboard()),
        );
      }
    } catch (e) {
      setState(() {
        _verificationError = 'Error verifying code: $e';
        _isLoading = false;
      });
    }
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
              'A verification code has been sent to the manager of ${widget.supermarketName}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Enter the 6-digit verification code provided by your manager',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _verificationCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Verification Code',
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
