import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IconTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const IconTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      onChanged: onChanged,
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

class CreateSupermarketPage extends StatefulWidget {
  const CreateSupermarketPage({super.key});

  @override
  _CreateSupermarketPageState createState() => _CreateSupermarketPageState();
}

class _CreateSupermarketPageState extends State<CreateSupermarketPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSupermarketValid = true;
  String? _supermarketValidationError;

  final TextEditingController _supermarketNameController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _supermarketNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _validateSupermarket() async {
    final name = _supermarketNameController.text.trim();
    final nameLower = name.toLowerCase();
    final location = _locationController.text.trim();

    if (name.isEmpty || location.isEmpty) {
      setState(() {
        _isSupermarketValid = true;
        _supermarketValidationError = null;
      });
      return;
    }

    try {
      // Query for supermarkets with the same name
      final nameQuery = await _firestore
          .collection('supermarkets')
          .where('name_lower', isEqualTo: nameLower)
          .get();

      if (nameQuery.docs.isEmpty) {
        // Name is unique
        setState(() {
          _isSupermarketValid = true;
          _supermarketValidationError = null;
        });
        return;
      }

      // If name exists, check if the same location exists for that name
      final locationQuery = await _firestore
          .collection('supermarkets')
          .where('name_lower', isEqualTo: nameLower)
          .where('location', isEqualTo: location)
          .limit(1)
          .get();

      if (locationQuery.docs.isEmpty) {
        // Location is unique for this name
        setState(() {
          _isSupermarketValid = true;
          _supermarketValidationError = null;
        });
      } else {
        // Both name and location are already used together
        setState(() {
          _isSupermarketValid = false;
          _supermarketValidationError =
              'A supermarket with this name already exists at this location.';
        });
      }
    } catch (e) {
      setState(() {
        _isSupermarketValid = true;
        _supermarketValidationError = null;
      });
    }
  }

  Future<void> _createAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _validateSupermarket();
    if (!_isSupermarketValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed. No user object returned.");
      }

      final String uid = user.uid; // Get the authenticated user's UID

      // 1. Create the Supermarket document (using manager's UID as Supermarket ID)
      // This also stores some initial manager details nested.
      await _firestore
          .collection('supermarkets')
          .doc(uid) // The supermarket's ID is the manager's UID
          .set({
            'name': _supermarketNameController.text.trim(),
            'name_lower': _supermarketNameController.text.trim().toLowerCase(),
            'location': _locationController.text.trim(),
            'manager': {
              'uid': uid, // Store manager's UID within the supermarket document
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
            },
            'createdAt': FieldValue.serverTimestamp(),
            'staffCount': 1,
          });

      // 2. Create the Manager's User Profile document under the 'users' subcollection
      // This is the document that your LoginPage's collectionGroup query expects.
      await _firestore
          .collection('supermarkets')
          .doc(uid) // Reference the created supermarket
          .collection('users') // Access the 'users' subcollection
          .doc(
            uid,
          ) // Set the manager's UID as the document ID for their profile
          .set({
            'uid':
                uid, // <--- IMPORTANT: Explicitly add the UID field here for the collectionGroup query
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': 'manager', // Crucial for role-based navigation
            'supermarketId':
                uid, // The ID of the supermarket this manager belongs to
            'supermarketName': _supermarketNameController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      // Navigate to the appropriate dashboard
      Navigator.pushReplacementNamed(
        context,
        '/managerHome',
        arguments: {
          'supermarketId':
              uid, // Pass the supermarket ID (which is the manager's UID)
          'supermarketName': _supermarketNameController.text.trim(),
          'location': _locationController.text.trim(),
          'managerId':
              uid, // Pass the manager's UID (same as supermarketId in this case)
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.code);
      });
      debugPrint(
        'FirebaseAuthException during account creation: ${e.code} - ${e.message}',
      );
    } catch (e) {
      debugPrint('Error during account creation (general catch): $e');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'An unexpected error occurred: ${e.toString()}'; // Show more specific error
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Supermarket',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Create an account for your supermarket",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30.0),

              // Supermarket Name Field
              IconTextField(
                hintText: 'Supermarket Name',
                icon: Icons.store,
                controller: _supermarketNameController,
                onChanged: (_) => _validateSupermarket(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Supermarket name is required';
                  }
                  if (_supermarketValidationError != null) {
                    return _supermarketValidationError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Supermarket Location Field
              IconTextField(
                hintText: 'Supermarket Location',
                icon: Icons.location_on,
                controller: _locationController,
                onChanged: (_) => _validateSupermarket(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  if (_supermarketValidationError != null) {
                    return _supermarketValidationError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              const Center(
                child: Text(
                  'Manager Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20.0),
              // First Name Field
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

              // Last Name Field
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

              // Email Field
              IconTextField(
                hintText: 'Email',
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

              // Password Field
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

              // Confirm Password Field
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
              const SizedBox(height: 32.0),

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
                onPressed: _isLoading || !_isSupermarketValid
                    ? null
                    : _createAccount,
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
