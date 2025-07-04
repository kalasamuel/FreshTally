import 'package:flutter/material.dart';

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
      home: const CreateStaffAccountPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class CreateStaffAccountPage extends StatefulWidget {
  const CreateStaffAccountPage({super.key});

  @override
  State<CreateStaffAccountPage> createState() => _CreateStaffAccountPageState();
}

class _CreateStaffAccountPageState extends State<CreateStaffAccountPage> {
  // Text editing controllers for each input field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F7D9), // Light green background
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(
              20.0,
            ), // Margin around the main content area
            padding: const EdgeInsets.all(16.0), // Padding inside the main card
            decoration: BoxDecoration(
              color: Colors.white, // White background for the main card
              borderRadius: BorderRadius.circular(
                20.0,
              ), // Rounded corners for the main card
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.1,
                  ), // Subtle shadow for depth
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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
                      bottom: 24.0,
                    ), // More space below app bar
                    child: Row(
                      children: [
                        // Back arrow icon
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Handle back button press
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 8), // Spacer
                        // "Create Your Staff Account" title
                        const Text(
                          'Create Your Staff Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
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
                  const SizedBox(height: 24), // Space before button
                  // Create Account Button
                  SizedBox(
                    width: double.infinity, // Button takes full width
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle create account button press
                        print('Create Account pressed!');
                        print('First Name: ${_firstNameController.text}');
                        print('Last Name: ${_lastNameController.text}');
                        print('Email: ${_emailController.text}');
                        print('Password: ${_passwordController.text}');
                        print(
                          'Confirm Password: ${_confirmPasswordController.text}',
                        );
                        print('Phone No: ${_phoneController.text}');
                      },
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
                        elevation: 3, // Add a subtle shadow
                      ),
                      child: const Text(
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
                      'Or Sign In with:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 16), // Space below text
                  // Social Media Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(
                        Icons.facebook,
                        Colors.blue[800]!,
                        () => print('Facebook Sign In'),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialIcon(
                        Icons.g_mobiledata,
                        Colors.red[700]!,
                        () => print('Google Sign In'),
                      ), // Using g_mobiledata for Google
                      const SizedBox(width: 20),
                      _buildSocialIcon(
                        Icons.apple,
                        Colors.black,
                        () => print('Apple Sign In'),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light grey background
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          border: Border.all(color: Colors.grey[300]!), // Light border
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none, // No border for the text field itself
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
          ),
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
