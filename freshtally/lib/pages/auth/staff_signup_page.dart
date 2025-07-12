// staff_registration_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshtally/pages/auth/staffcode.dart';

class StaffRegistrationPage extends StatefulWidget {
  const StaffRegistrationPage({super.key});

  @override
  State<StaffRegistrationPage> createState() => _StaffRegistrationPageState();
}

class _StaffRegistrationPageState extends State<StaffRegistrationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _supermarketNameController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _requestVerificationCode() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _supermarketNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate and send verification code
      await requestStaffSignup(
        supermarketName: _supermarketNameController.text.trim(),
        staffName:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );

      // Navigate to verification page with all the collected data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffVerificationPage(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.trim(),
            supermarketName: _supermarketNameController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting verification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('First Name', _firstNameController),
            _buildTextField('Last Name', _lastNameController),
            _buildTextField(
              'Email',
              _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField('Password', _passwordController, obscureText: true),
            _buildTextField(
              'Confirm Password',
              _confirmPasswordController,
              obscureText: true,
            ),
            _buildTextField(
              'Phone (Optional)',
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField('Supermarket Name', _supermarketNameController),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _requestVerificationCode,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Request Verification Code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

Future<void> requestStaffSignup({
  required String supermarketName,
  required String staffName,
}) async {
  // Generate a 6-digit code
  String code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
      .toString();

  // Create a notification for the manager
  await FirebaseFirestore.instance.collection('notifications').add({
    'type': 'staff_signup',
    'title': 'Staff Signup Request',
    'message':
        'A new staff member ($staffName) wants to join your supermarket "$supermarketName". Share the code below with them.',
    'payload': {
      'verificationCode': code,
      'staffName': staffName,
      'supermarketName': supermarketName,
    },
    'createdAt': FieldValue.serverTimestamp(),
    'isRead': false,
  });

  // Store the verification code
  await FirebaseFirestore.instance.collection('verification_codes').add({
    'code': code,
    'supermarketName': supermarketName,
    'staffName': staffName,
    'isUsed': false,
    'createdAt': FieldValue.serverTimestamp(),
    'expiresAt': Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 1)),
    ),
  });
}
