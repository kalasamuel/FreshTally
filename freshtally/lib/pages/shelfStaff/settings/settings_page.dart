import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Freshtally/pages/shelfStaff/settings/switch_accounts.dart';

class SettingsPage extends StatelessWidget {
  final String supermarketId;

  const SettingsPage({super.key, required this.supermarketId});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  Future<void> _switchAccount(BuildContext context) async {
    // Navigate to the account history page
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountHistoryPage()),
      );
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
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password (min 6 chars)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Re-enter your new password',
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
              final oldPassword = oldPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (oldPassword.isEmpty ||
                  newPassword.isEmpty ||
                  confirmPassword.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required.')),
                  );
                }
                return;
              }

              if (newPassword != confirmPassword) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                }
                return;
              }

              if (newPassword.length < 6) {
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
                final AuthCredential credential = EmailAuthProvider.credential(
                  email: currentUser.email!,
                  password: oldPassword,
                );

                await currentUser.reauthenticateWithCredential(credential);
                await currentUser.updatePassword(newPassword);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                String errorMessage;
                switch (e.code) {
                  case 'wrong-password':
                    errorMessage =
                        'The current password you entered is incorrect.';
                    break;
                  case 'user-not-found':
                    errorMessage = 'User not found. Please log in again.';
                    break;
                  case 'requires-recent-login':
                    errorMessage =
                        'This operation is sensitive and requires recent authentication. Please log out and log in again, then try changing your password.';
                    break;
                  case 'too-many-requests':
                    errorMessage =
                        'Too many failed attempts. Please try again later.';
                    break;
                  case 'invalid-credential':
                    errorMessage =
                        'Invalid credentials. Please check your current password.';
                    break;
                  case 'weak-password':
                    errorMessage = 'The new password is too weak.';
                    break;
                  default:
                    errorMessage = 'An error occurred: ${e.message}';
                    break;
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('An unexpected error occurred: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                debugPrint('General Error during password change: $e');
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
    final String userName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final String userEmail = user?.email ?? 'No email provided';
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(photoUrl),
                      )
                    : const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
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
              const Divider(height: 40, thickness: 1),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.blue),
                title: const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.switch_account, color: Colors.green),
                title: const Text(
                  'Switch Account',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _switchAccount(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
