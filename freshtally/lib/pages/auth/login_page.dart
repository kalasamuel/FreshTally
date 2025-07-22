import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshtally/pages/auth/create_supermarket_page.dart';
import 'package:freshtally/pages/auth/customer_signup_page.dart';
import 'package:freshtally/pages/auth/staff_signup_page.dart';
import 'package:freshtally/pages/customer/home/customer_home_page.dart';
import 'package:freshtally/pages/manager/home/manager_home_screen.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:freshtally/pages/storeManager/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IconTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const IconTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
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
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreferences();
  }

  Future<void> _loadRememberMePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('rememberedEmail');
    final rememberMeFlag = prefs.getBool('rememberMe') ?? false;

    if (savedEmail != null && rememberMeFlag) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = rememberMeFlag;
      });
    }
  }

  Future<void> _saveRememberMePreferences(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('rememberedEmail', email);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('rememberedEmail');
      await prefs.remove('rememberMe');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = userCredential.user?.uid;
      if (userId == null) throw Exception("User ID not found");

      // Improved user document query
      final userQuery = await _firestore
          .collectionGroup('users')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User document not found. Contact support.');
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      final role = userData['role'] as String? ?? 'customer';
      final supermarketId = userData['supermarketId'] as String?;

      String supermarketName = 'Unknown';
      String location = 'Unknown';

      if (supermarketId != null) {
        final supermarketDoc = await _firestore
            .collection('supermarkets')
            .doc(supermarketId)
            .get();

        if (supermarketDoc.exists) {
          final supermarketData = supermarketDoc.data()!;
          supermarketName = supermarketData['name'] as String? ?? 'Unknown';
          location = supermarketData['location'] as String? ?? 'Unknown';
        }
      }

      await _saveRememberMePreferences(_emailController.text.trim());

      if (!mounted) return;

      switch (role) {
        case 'manager':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerDashboardPage(
                supermarketName: supermarketName,
                location: location,
              ),
            ),
          );
          break;

        case 'storeManager':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StoreManagerDashboard(
                supermarketId: supermarketId!,
                supermarketName: supermarketName,
                location: location,
              ),
            ),
          );
          break;

        case 'staff':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ShelfStaffDashboard(
                supermarketId: supermarketId!,
                supermarketName: supermarketName,
                location: location,
              ),
            ),
          );
          break;

        case 'customer':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerHomePage(
                supermarketName: supermarketName,
                location: location,
                supermarketId: supermarketId ?? '',
              ),
            ),
          );
          break;

        default:
          throw Exception("Unknown user role: $role. Contact support.");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email to reset password.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send password reset email: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> _signInWithGoogle() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In not fully implemented yet.'),
      ),
    );
  }

  Future<void> _signInWithFacebook() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook Sign-In not fully implemented yet.'),
      ),
    );
  }

  Future<void> _signInWithApple() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-In not fully implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Make sure this path matches your asset location
                  height: 300, // Adjust as needed
                ),
              ),
              const SizedBox(height: 24.0),
              Center(
                child: Text(
                  "Welcome to FreshTally!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              const Center(
                child: Text(
                  "",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              IconTextField(
                hintText: "Email",
                icon: Icons.email,
                controller: _emailController,
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
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Password",
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text(
                        "Remember me",
                        style: TextStyle(fontSize: 14.0),
                      ),
                      value: _rememberMe,
                      onChanged: (newValue) {
                        setState(() {
                          _rememberMe = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              const Center(
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
                    onPressed: _signInWithFacebook,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset('assets/icons/google.png', height: 35),
                    onPressed: _signInWithGoogle,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(
                      Icons.apple,
                      size: 40,
                      color: Colors.black,
                    ),
                    onPressed: _signInWithApple,
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateSupermarketPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: const Text(
                        "New Supermarket?",
                        style: TextStyle(color: Colors.green, fontSize: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StaffSignupPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: const Text(
                        "Joining Staff?",
                        style: TextStyle(color: Colors.orange, fontSize: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerSignupPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue.shade700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Text(
                        "I am Customer",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
