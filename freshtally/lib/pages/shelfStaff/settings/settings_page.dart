import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required String supermarketId});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _switchAccount(BuildContext context) {
    // TODO: Reset state and navigate to RoleSelectionPage
    Navigator.pushReplacementNamed(context, '/roleSelection');
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? 'No email provided';
    final String? photoUrl = user?.photoURL;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get(),
      builder: (context, snapshot) {
        String userName = 'User';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
              .trim();
          if (userName.isEmpty) userName = 'User';
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: photoUrl != null
                      ? CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(photoUrl),
                        )
                      : const CircleAvatar(
                          radius: 32,
                          child: Icon(Icons.person, size: 32),
                        ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    userEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const Divider(height: 40),

                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {
                    // Implement password change functionality
                    _showChangePasswordDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.switch_account),
                  title: const Text('Switch Account'),
                  onTap: () => _switchAccount(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return;

    final emailController = TextEditingController(text: currentUser.email);
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Old Password'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Implement password change logic here
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              // Add your password change logic here
              Navigator.pop(context);
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
