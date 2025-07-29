import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Though not directly used in this snippet for Firestore operations, keeping it as it was in your original file.

class SettingsPage extends StatelessWidget {
  final String supermarketId;

  const SettingsPage({super.key, required this.supermarketId});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // After logout, navigate to the login screen.
        // Ensure '/login' route is defined in your main.dart's onGenerateRoute or routes map.
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        // Provide user feedback on logout errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Catch any other unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  void _switchAccount(BuildContext context) {
    if (context.mounted) {
      // Navigate to the role selection page. This typically means the user is still logged in
      // but wants to switch their active "role" or associated supermarket without full logout.
      // Ensure '/roleSelection' route is defined.
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
      return; // Exit if no valid user or email
    }

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          // Allows scrolling if the content (text fields) exceeds screen height
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column take minimum space
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
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Basic input validation
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

              // Proceed with Firebase password change
              try {
                // Reauthenticate the user with their old password
                final AuthCredential credential = EmailAuthProvider.credential(
                  email: currentUser.email!, // Use the current user's email
                  password: oldPassword, // Use the provided old password
                );

                await currentUser.reauthenticateWithCredential(credential);

                // If reauthentication is successful, update the password
                await currentUser.updatePassword(newPassword);

                if (context.mounted) {
                  Navigator.pop(context); // Close the dialog on success
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully!'),
                      backgroundColor: Colors.green, // Indicate success
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
                      backgroundColor: Colors.red, // Indicate error
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
    // Fallback display name for users without one
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
        // Makes the entire body scrollable
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 40, // Slightly larger avatar
                        backgroundImage: NetworkImage(photoUrl),
                      )
                    : const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey, // A default background
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
                    fontSize: 22, // Slightly larger font
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
              const Divider(height: 40, thickness: 1), // A clearer divider
              ListTile(
                leading: const Icon(
                  Icons.lock,
                  color: Colors.blue,
                ), // Add color
                title: const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ), // Arrow indicator
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
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ), // Distinct color for logout
                title: const Text('Logout', style: TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _logout(context),
              ),
              // Add more settings options here if needed, e.g.,
              // ListTile(
              //   leading: const Icon(Icons.notifications),
              //   title: const Text('Notifications'),
              //   onTap: () {
              //     // Navigate to notification settings
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.privacy_tip),
              //   title: const Text('Privacy Policy'),
              //   onTap: () {
              //     // Navigate to privacy policy page
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
