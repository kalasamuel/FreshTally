import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffCodeGenerationPage extends StatefulWidget {
  final Map<String, dynamic> supermarketInfo;

  const StaffCodeGenerationPage({
    Key? key,
    required this.supermarketInfo,
  }) : super(key: key);

  @override
  State<StaffCodeGenerationPage> createState() => _StaffCodeGenerationPageState();
}

class _StaffCodeGenerationPageState extends State<StaffCodeGenerationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _staffEmailController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _staffNameController.dispose();
    _staffEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Staff Code'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Staff Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _staffNameController,
                      decoration: const InputDecoration(
                        labelText: 'Staff Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _staffEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Staff Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateCode,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.code),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Verification Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Enter the staff member\'s name and email\n'
                      '2. Click "Generate Verification Code"\n'
                      '3. The code will be sent to the staff member via notification\n'
                      '4. Staff can use this code during signup to join your supermarket',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateCode() async {
    final staffName = _staffNameController.text.trim();
    final staffEmail = _staffEmailController.text.trim();

    if (staffName.isEmpty || staffEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidEmail(staffEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate a 6-digit code
      final code = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      // Store the verification code in Firestore
      await _firestore.collection('verification_codes').add({
        'code': code,
        'supermarketId': widget.supermarketInfo['id'],
        'supermarketName': widget.supermarketInfo['name'],
        'staffEmail': staffEmail,
        'staffName': staffName,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
        'isUsed': false,
      });

      // Send notification to staff with the code
      await _firestore.collection('notifications').add({
        'type': 'verification_code',
        'message': 'Your verification code is: $code. Use this code to complete your signup.',
        'recipientEmail': staffEmail,
        'recipientRole': 'staff',
        'supermarketId': widget.supermarketInfo['id'],
        'supermarketName': widget.supermarketInfo['name'],
        'verificationCode': code,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Send notification to manager for tracking
      await _firestore.collection('notifications').add({
        'type': 'code_generated',
        'message': 'Verification code $code generated for $staffName ($staffEmail)',
        'recipientRole': 'manager',
        'supermarketId': widget.supermarketInfo['id'],
        'supermarketName': widget.supermarketInfo['name'],
        'verificationCode': code,
        'staffEmail': staffEmail,
        'staffName': staffName,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Clear the form
      _staffNameController.clear();
      _staffEmailController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code $code generated and sent to $staffEmail'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating code: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
} 