import 'package:flutter/material.dart';
import 'package:freshtally/pages/auth/role_selection_page.dart';

void main() {
  runApp(const MyApp()); // Added const for better performance
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshTally',
      // Define the initial route explicitly
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionPage(), // Set RoleSelectionPage as the root
        '/role_selection': (context) => const RoleSelectionPage(), // This route is now redundant if '/' goes to RoleSelectionPage
        // Uncomment these as you create your CashierPage and ShelfStaffPage
        // '/cashier': (context) => const CashierPage(),
        // '/shelf_staff': (context) => const ShelfStaffPage(),
      },
    );
  }
}