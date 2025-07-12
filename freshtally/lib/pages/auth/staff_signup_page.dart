import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Staff Account UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const StaffSignupPage(role: ''),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class StaffSignupPage extends StatefulWidget {
  const StaffSignupPage({super.key, required String role});

  @override
  State<StaffSignupPage> createState() => _StaffSignupPageState();
}

class _StaffSignupPageState extends State<StaffSignupPage> {
  // Text editing controllers for each input field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _supermarketNameController =
      TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  bool _isLoading = false;
  String? _verificationError;
  String? _supermarketError;

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _supermarketNameController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
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
          .where(
            'supermarketName',
            isEqualTo: _supermarketNameController.text.trim(),
          )
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

      setState(() {
        _isLoading = false;
        _verificationError = null;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _verificationError = 'Error verifying code. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _createAccount() async {
    // Validate all fields
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _supermarketNameController.text.trim().isEmpty ||
        _verificationCodeController.text.isEmpty) {
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

    if (_verificationCodeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code must be 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the staff account
      await FirebaseFirestore.instance.collection('staff').add({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'supermarketName': _supermarketNameController.text.trim(),
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

        // Navigate to role selection or dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShelfStaffDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Light green background
      appBar: AppBar(
        title: Text(
          'Create Your Staff Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(
              20.0,
            ), // Margin around the main content area
            padding: const EdgeInsets.all(16.0), // Padding inside the main card
            child: SingleChildScrollView(
              // Make content scrollable if keyboard appears
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align content to the start
                mainAxisSize: MainAxisSize.min, // Take minimum space
                children: [
                  // App Bar Section
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20.0,
                    ), // More space below app bar
                    child: Row(
                      children: [
                        const SizedBox(width: 8), // Spacer
                      ],
                    ),
                  ),
                  // Input Fields
                  _buildTextField('First Name', _firstNameController),
                  _buildTextField('Last Name', _lastNameController),
                  _buildTextField(
                    'Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    'Password',
                    _passwordController,
                    obscureText: true,
                  ),
                  _buildTextField(
                    'Confirm Password',
                    _confirmPasswordController,
                    obscureText: true,
                  ),
                  _buildTextField(
                    'Phone no. (Optional)',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    'Supermarket Name',
                    _supermarketNameController,
                    errorText: _supermarketError,
                  ),

                  // Verification Code Section
                  const SizedBox(height: 16),
                  const Text(
                    'Verification Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the 6-digit code provided by your supermarket manager',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Enter 6-digit code',
                          _verificationCodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          errorText: _verificationError,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24), // Space before button
                  // Create Account Button
                  SizedBox(
                    width: double.infinity, // Button takes full width
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF4CAF50,
                        ), // Green button color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ), // Rounded corners
                        ),
                        elevation: 1, // Add a subtle shadow
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24), // Space below button
                  // Or Sign In with:
                  Center(
                    child: Text(
                      "Or Sign In with:",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.facebook,
                          size: 40,
                          color: Colors.blue,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: Image.asset(
                          'assets/icons/google.png',
                          height: 35,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.apple,
                          size: 40,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // Space below icons
                  // Already have an account? Sign In
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        print('Sign In tapped!');
                        // Navigate to sign-in page
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 15,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: Colors.green, // Green for "Sign In"
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  // Helper method to build a styled text input field
  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light grey background
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          border: Border.all(
            color: errorText != null ? Colors.red : Colors.grey[300]!,
          ), // Light border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none, // No border for the text field itself
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                counterText: '', // Hide character counter
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a social media icon button
  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30), // Circular ripple effect
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
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
    'expiresAt': FieldValue.serverTimestamp(), // Add expiration logic if needed
  });

  // Optionally, show a dialog to the staff member
}
