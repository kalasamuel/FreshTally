import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatelessWidget {
  final String supermarketId;

  const SettingsPage({super.key, required this.supermarketId});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // Ensure '/login' route is defined in your main.dart's onGenerateRoute
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  void _switchAccount(BuildContext context) {
    if (context.mounted) {
      // Ensure '/roleSelection' route is defined in your main.dart's onGenerateRoute
      Navigator.pushReplacementNamed(context, '/roleSelection');
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.email == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active user or email found for password change.'),
          ),
        );
      }
      return;
    }

    final emailController = TextEditingController(text: currentUser.email);
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          // This SingleChildScrollView is already correct for the dialog
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
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
              if (newPasswordController.text.trim() !=
                  confirmPasswordController.text.trim()) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                }
                return;
              }

              if (newPasswordController.text.trim().length < 6) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'New password must be at least 6 characters long',
                      ),
                    ),
                  );
                }
                return;
              }

              try {
                final credential = EmailAuthProvider.credential(
                  email: currentUser.email!,
                  password: oldPassword,
                );

                await currentUser.reauthenticateWithCredential(credential);

                await currentUser.updatePassword(
                  newPasswordController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                String errorMessage = 'An error occurred. Please try again.';
                if (e.code == 'wrong-password') {
                  errorMessage = 'Invalid current password.';
                } else if (e.code == 'user-not-found') {
                  errorMessage = 'User not found.';
                } else if (e.code == 'too-many-requests') {
                  errorMessage = 'Too many failed attempts. Try again later.';
                } else {
                  errorMessage = 'Error: ${e.message}';
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(errorMessage)));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An unexpected error occurred: $e')),
                  );
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'User';
    final String userEmail = user?.email ?? 'No email provided';
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        // <--- Wrap the Padding with SingleChildScrollView here
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: photoUrl != null && photoUrl.isNotEmpty
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
      ),
    );
  }
}
