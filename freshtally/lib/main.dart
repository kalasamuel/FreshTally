import 'package:flutter/material.dart';
//import 'package:freshtally/pages/staff/batches/batch_entry_page.dart';
// import 'package:freshtally/pages/auth/role_selection_page.dart';
//import 'package:freshtally/pages/auth/login_page.dart';
import 'package:freshtally/pages/auth/customer_signup_page.dart';


// void main() {
//   runApp(const MyApp()); // Added const for better performance
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FreshTally',
//       initialRoute: '/',
//       routes: {
//         // '/': (context) => HomePage(), // maybe your login page
//          '/role_selection': (context) => const RoleSelectionPage(),
//         // '/cashier': (context) => const CashierPage(),
//         // '/shelf_staff': (context) => const ShelfStaffPage(),
//       },
//     );
//   }
// }

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: CreateCustomerPage()),
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FreshTally',
//       theme: ThemeData(primarySwatch: Colors.green),
//       home: const LoginPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
