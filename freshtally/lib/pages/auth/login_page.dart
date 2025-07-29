import 'package:Freshtally/pages/auth/supermarket_selection_page.dart';
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

class IconTextField extends StatefulWidget {
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
  State<IconTextField> createState() => _IconTextFieldState();
}

class _IconTextFieldState extends State<IconTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscure : false,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(widget.icon, color: Colors.grey),
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
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null,
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

  Future<void> _addToAccountHistory(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList('previous_accounts') ?? [];

    // Remove if already exists (to avoid duplicates)
    accounts.remove(email);

    // Add to beginning of list (most recent first)
    accounts.insert(0, email);

    // Limit to last 5 accounts (adjust as needed)
    if (accounts.length > 5) {
      accounts.removeLast();
    }

    await prefs.setStringList('previous_accounts', accounts);
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

      // Add to account history
      final userEmail = userCredential.user?.email;
      if (userEmail != null) {
        await _addToAccountHistory(userEmail);
      }

      final userId = userCredential.user?.uid;
      if (userId == null) throw Exception("User ID not found after login.");

      // --- CUSTOMER LOGIN FLOW LOGIC ---
      final customerDoc = await _firestore
          .collection('customers')
          .doc(userId)
          .get();

      String role;
      List<String> associatedSupermarketIds = [];
      String? staffOrManagerSupermarketId;

      if (customerDoc.exists) {
        final customerData = customerDoc.data();
        role = customerData?['role'] as String? ?? 'customer';
        associatedSupermarketIds = List<String>.from(
          customerData?['associatedSupermarketIds'] ?? [],
        );
        debugPrint(
          'Customer logged in: $userId, Role: $role, Supermarkets: $associatedSupermarketIds',
        );
      } else {
        final userQuery = await _firestore
            .collection(
              'users',
            ) // Changed from collectionGroup to direct collection
            .doc(userId)
            .get();

        if (!userQuery.exists) {
          throw Exception(
            'User document not found in Firestore for UID: $userId. Contact support.',
          );
        }

        final userData = userQuery.data();
        role =
            userData?['role'] as String? ??
            'staff'; // Default to staff if role missing
        staffOrManagerSupermarketId = userData?['supermarketId'];

        if (staffOrManagerSupermarketId == null) {
          throw Exception('Supermarket ID not found for staff user: $userId.');
        }
        debugPrint(
          'Staff logged in: $userId, Role: $role, Supermarket: $staffOrManagerSupermarketId',
        );
      }

      await _saveRememberMePreferences(_emailController.text.trim());

      if (!mounted) return;

      // Navigate based on role
      switch (role.toLowerCase()) {
        // Changed to lowercase comparison
        case 'manager':
        case 'storemanager': // Combined manager cases
          String supermarketName = 'Unknown';
          String location = 'Unknown';
          if (staffOrManagerSupermarketId != null) {
            final supermarketDoc = await _firestore
                .collection('supermarkets')
                .doc(staffOrManagerSupermarketId)
                .get();
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data();
              supermarketName =
                  supermarketData?['name'] as String? ?? 'Unknown';
              location = supermarketData?['location'] as String? ?? 'Unknown';
            }
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StoreManagerDashboard(
                supermarketId: staffOrManagerSupermarketId!,
                supermarketName: supermarketName,
                location: location,
              ),
            ),
          );
          break;

        case 'staff':
        case 'shelfstaff': // Combined staff cases
          String supermarketName = 'Unknown';
          String location = 'Unknown';
          if (staffOrManagerSupermarketId != null) {
            final supermarketDoc = await _firestore
                .collection('supermarkets')
                .doc(staffOrManagerSupermarketId)
                .get();
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data();
              supermarketName =
                  supermarketData?['name'] as String? ?? 'Unknown';
              location = supermarketData?['location'] as String? ?? 'Unknown';
            }
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ShelfStaffDashboard(
                supermarketId: staffOrManagerSupermarketId!,
                supermarketName: supermarketName,
                location: location,
              ),
            ),
          );
          break;

        case 'customer':
          if (associatedSupermarketIds.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SupermarketSelectionPage(
                  customerId: userId,
                  initialMessage:
                      'No supermarkets linked to your account. Please join one.',
                ),
              ),
            );
          } else if (associatedSupermarketIds.length == 1) {
            final String singleSupermarketId = associatedSupermarketIds.first;
            final supermarketDoc = await _firestore
                .collection('supermarkets')
                .doc(singleSupermarketId)
                .get();
            String supermarketName = 'Unknown';
            String location = 'Unknown';
            if (supermarketDoc.exists) {
              final supermarketData = supermarketDoc.data();
              supermarketName =
                  supermarketData?['name'] as String? ?? 'Unknown';
              location = supermarketData?['location'] as String? ?? 'Unknown';
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerHomePage(
                  supermarketName: supermarketName,
                  location: location,
                  supermarketId: singleSupermarketId,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SupermarketSelectionPage(
                  customerId: userId,
                  associatedSupermarketIds: associatedSupermarketIds,
                ),
              ),
            );
          }
          break;

        default:
          throw Exception("Unknown user role: $role. Contact support.");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.code);
        debugPrint(
          'FirebaseAuthException: Code: ${e.code}, Message: ${e.message}',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        debugPrint('General Login Error: ${e.toString()}');
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
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        debugPrint('Unhandled FirebaseAuthException code: $code');
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

  Future<void> _signInWithApple() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-In not fully implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20.0),
              Center(child: Image.asset('assets/images/logo.png', height: 150)),
              const SizedBox(height: 5.0),
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
                  "Login",
                  style: TextStyle(
                    fontSize: 25,
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
              IconTextField(
                hintText: "Password",
                icon: Icons.lock,
                isPassword: true,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
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
                  Image.asset('assets/icons/google.png', height: 35),
                  IconButton(
                    icon: const Icon(
                      Icons.apple,
                      size: 45,
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
                        Navigator.push(
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
                        Navigator.push(
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
                        Navigator.push(
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
