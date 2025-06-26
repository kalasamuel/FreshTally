import 'package:flutter/material.dart';
import 'package:freshtally/pages/auth/role_selection_page.dart';
import 'package:freshtally/pages/auth/create_supermarket_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreshTally',
      home: CreateSupermarketPage(),
      initialRoute: '/',
      routes: {
        //'/': (context) => HomePage(), // maybe your login page
        //'/create_supermarket': (context) => CreateSupermarketPage(),
        //'/role_selection': (context) => const RoleSelectionPage(),
        //'/cashier': (context) => const CashierPage(),
        //'/shelf_staff': (context) => const ShelfStaffPage(),
      },
    );
  }
}
