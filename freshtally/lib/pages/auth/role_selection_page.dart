import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String selectedRole = '';

  void navigateToRolePage() {
    if (selectedRole == 'Cashier') {
      Navigator.pushNamed(context, '/cashier');
    } else if (selectedRole == 'Shelf Staff') {
      Navigator.pushNamed(context, '/shelf_staff');
    }
  }

  Widget buildRoleCard(String role, Widget iconWidget) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green[400]! : Colors.grey[50]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            iconWidget,
            SizedBox(width: 16),
            Text(role, style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildRoleCard('Cashier', Image.asset('assets/cashier.png', width: 150)),
            buildRoleCard('Shelf Staff', Image.asset('assets/shelf-attendant.png', width: 150)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: selectedRole.isEmpty ? null : navigateToRolePage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Join')
            )
          ],
        )
        ),
    );
  }
}