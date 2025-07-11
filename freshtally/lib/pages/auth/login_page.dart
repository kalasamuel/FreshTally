import 'package:flutter/material.dart';
// import 'package:freshtally/pages/auth/create_supermarket_page.dart';
// import 'package:freshtally/pages/auth/join_supermarket_page.dart';
import 'package:freshtally/pages/auth/role_selection_page.dart';
import 'package:freshtally/pages/customer/home/customer_home_page.dart';
import 'package:freshtally/pages/manager/home/manager_home_screen.dart';

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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            const IconTextField(hintText: "Email", icon: Icons.email),
            const SizedBox(height: 16.0),
            const IconTextField(
              hintText: "Password",
              icon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Forgot Password pressed!')),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login button pressed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
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
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Image.asset('assets/icons/google.png', height: 35),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.apple, size: 40, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Column(
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ManagerDashboardPage();
                        },
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "New Supermarket?",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RoleSelectionPage(role: '');
                        },
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Joining Staff?",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerHomePage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "I am Customer",
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
