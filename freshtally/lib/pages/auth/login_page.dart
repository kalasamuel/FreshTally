import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Freshtally/pages/auth/create_supermarket_page.dart';
import 'package:Freshtally/pages/auth/customer_signup_page.dart';
import 'package:Freshtally/pages/auth/staff_signup_page.dart';
import 'package:Freshtally/pages/customer/home/customer_home_page.dart';
import 'package:Freshtally/pages/manager/home/manager_home_screen.dart';
import 'package:Freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:Freshtally/pages/storeManager/home/home_screen.dart';
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
  bool _obscurePassword = true; // <-- Add this line

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
        throw Exception("User document not found. Contact support.");
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerDashboardPage(
                supermarketName: supermarketName,
                location: location,
                managerId: '',
                supermarketId: '',
              ),
            ),
          );
          break;

          case 'storeManager':
            Navigator.push(
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffSignupPage(
                  supermarketId: supermarketId!,
                  supermarketName: supermarketName,
                  location: location,
                ),
              ),
            );
            break;

            case 'customer':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerHomePage(
                  supermarketId: supermarketId!,
                  supermarketName: supermarketName,
                  location: location,
                ),
              ),
            );
            break;

            default:
            throw Exception("Unknown user role: $role. Contact support");
      }
        }on FirebaseAuthException catch (e) {
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
        return 'Check your internet connection and try again.';
      // return 'An unexpected error occurred. Please try again.';
    }
  }
        
  
      



            

            

      