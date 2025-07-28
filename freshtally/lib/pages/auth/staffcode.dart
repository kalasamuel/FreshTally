import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import RoleSelectionPage
import 'package:Freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart'; // Import FirebaseAuth

class StaffVerificationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String supermarketName;
  final String? supermarketId;

  const StaffVerificationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.supermarketName,
    this.supermarketId,
    required String location,
  });

  @override
  State<StaffVerificationPage> createState() => _StaffVerificationPageState();
}

class _StaffVerificationPageState extends State<StaffVerificationPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _supermarketId;
  String? _managerEmail;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('supermarkets')
          .where('name', isEqualTo: widget.supermarketName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Supermarket not found');
      }

      final doc = query.docs.first;
      _supermarketId = doc.id;
      final data = doc.data();
      _managerEmail = data['manager']['email'];

      final code = _generate6DigitCode();

      await FirebaseFirestore.instance
          .collection('verificationCodes')
          .doc(widget.email)
          .set({
            'code': code,
            'createdAt': FieldValue.serverTimestamp(),
            'supermarketId': _supermarketId,
          });

      // In a real app, you would send this code to the manager's email
      debugPrint('Verification code for ${widget.email}: $code');
      debugPrint('This would be sent to manager at $_managerEmail');
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

  String _generate6DigitCode() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
  }

  Future<bool> _verifyCode() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('verificationCodes')
        .doc(widget.email)
        .get();

    if (!snapshot.exists) return false;

    final data = snapshot.data();
    final storedCode = data?['code']?.toString();
    final enteredCode = _codeController.text.trim();

    return storedCode == enteredCode;
  }

  Future<void> _completeSignup() async {
    if (_codeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isValid = await _verifyCode();
      if (!isValid) {
        throw Exception('Invalid verification code');
      }

      final authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      final String staffUid = authResult.user!.uid;

      // Create staff document
      await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(_supermarketId)
          .collection('staff')
          .doc(staffUid)
          .set({
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'email': widget.email,
            'phone': widget.phone,
            'role': 'staff',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Add staff to global users collection for login
      await FirebaseFirestore.instance.collection('users').doc(staffUid).set({
        'uid': staffUid,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'email': widget.email,
        'phone': widget.phone,
        'role': 'staff',
        'supermarketId': _supermarketId,
        'supermarketName': widget.supermarketName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create notification for the manager
      await _createStaffJoinNotification(staffUid);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ShelfStaffDashboard(
            supermarketId: _supermarketId ?? '',
            supermarketName: widget.supermarketName,
            location: '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createStaffJoinNotification(String staffUid) async {
    try {
      // Get manager's UID from the supermarket document
      final supermarketDoc = await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(_supermarketId)
          .get();

      if (!supermarketDoc.exists) {
        debugPrint('Supermarket document not found for notification');
        return;
      }

      final supermarketData = supermarketDoc.data()!;
      final managerData = supermarketData['manager'] as Map<String, dynamic>?;
      final managerUid = managerData?['uid'] as String?;

      if (managerUid == null) {
        debugPrint('Manager UID not found for notification');
        return;
      }

      // Create notification document
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': managerUid,
        'recipientType': 'manager',
        'supermarketId': _supermarketId,
        'type': 'staff_joined',
        'title': 'New Staff Member Joined',
        'message':
            '${widget.firstName} ${widget.lastName} has joined your supermarket .',
        'staffId': staffUid,
        'staffName': '${widget.firstName} ${widget.lastName}',
        'staffEmail': widget.email,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Notification created for manager: $managerUid');
    } catch (e) {
      debugPrint('Error creating notification: $e');
      // Don't throw error here as it shouldn't prevent staff signup
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Enter Verification Code",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30.0),

                Center(
                  child: Text(
                    'A 6-digit code was sent to the manager of\n${widget.supermarketName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30.0),

                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit code',
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 17.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.0),
                      ),
                      elevation: 1,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Complete Signup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20.0),

                TextButton(
                  onPressed: _isLoading ? null : _sendVerificationCode,
                  child: Text(
                    'Resend Code',
                    style: TextStyle(color: Colors.green[700], fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
