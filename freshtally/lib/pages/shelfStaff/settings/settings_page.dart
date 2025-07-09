import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
    // Dummy user
    const userName = 'Kala Samuel';
    const userEmail = 'kalasamuel79@gmail.com';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 40),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {}, // Future enhancement
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
  }
}
