import 'package:flutter/material.dart';
import 'package:freshtally/pages/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freshtally/pages/auth/staffcode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Staff Account',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Inter'),
      // The role parameter is not used in StaffSignupPage directly, removed for clarity.
      home: const StaffSignupPage(role: ''),
      debugShowCheckedModeBanner: false,
    );
  }
}

// IconTextField widget (assuming it's either defined here or in a shared file)
class IconTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLength;

  const IconTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
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
        counterText: '',
      ),
    );
  }
}

class StaffSignupPage extends StatefulWidget {
  const StaffSignupPage({super.key, required String role});

  @override
  State<StaffSignupPage> createState() => _StaffSignupPageState();
}

class _StaffSignupPageState extends State<StaffSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Remove the problematic 'supermarketId' getter here as it's handled later
  // String? get supermarketId => null;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please correct the errors in the form.';
      });
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create user in Firebase Auth
      final authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = authResult.user?.uid;
      if (uid == null) {
        throw Exception("Failed to create user account. Please try again.");
      }

      // No Firestore write here yet! We navigate to verification.

      if (!mounted) return;

      // Navigate to StaffVerificationPage, passing user details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StaffVerificationPage(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password:
                password, // Pass password if needed for re-auth or similar, though typically not
            phone: phone,
            // These will be determined in StaffVerificationPage
            supermarketName: '', // Will be selected later
            location: '', // Will be determined later
            supermarketId: null, // Will be determined later
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to create account.';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        msg = 'Password is too weak.';
      }
      setState(() {
        _errorMessage = msg;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Placeholder for social sign-up methods
  void _signUpWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-Up not implemented.')),
    );
  }

  void _signUpWithFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook Sign-Up not implemented.')),
    );
  }

  void _signUpWithApple() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-Up not implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black, // Back button color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Staff Account', // Retain original title
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[700], // Match Login Page title color
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              24.0,
            ), // Padding around the form content
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch children
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Join as Staff!", // Custom text for staff signup
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  // Input Fields using IconTextField
                  IconTextField(
                    hintText: 'First Name',
                    icon: Icons.person,
                    controller: _firstNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  IconTextField(
                    hintText: 'Last Name',
                    icon: Icons.person_outline,
                    controller: _lastNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  IconTextField(
                    hintText: 'Email',
                    icon: Icons.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  IconTextField(
                    hintText: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  IconTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password is required';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  IconTextField(
                    hintText: 'Phone No. (Optional)',
                    icon: Icons.phone,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 15, // Example max length for phone numbers
                  ),
                  const SizedBox(height: 24.0), // Space before button
                  // Error Message Display
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

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
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            ) // White spinner
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
                  const SizedBox(height: 20.0), // Space below button
                  // Or Sign Up with:
                  const Center(
                    child: Text(
                      "Or Sign Up with:", // Changed from "Sign In" to "Sign Up" for clarity
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
                        onPressed: _signUpWithFacebook,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: Image.asset(
                          'assets/icons/google.png',
                          height: 35,
                        ),
                        onPressed: _signUpWithGoogle,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.apple,
                          size: 40,
                          color: Colors.black,
                        ),
                        onPressed: _signUpWithApple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30.0), // Space below icons
                  // Already have an account? Sign In
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the LoginPage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
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
}
