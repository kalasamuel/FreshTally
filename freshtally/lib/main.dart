import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freshtally/pages/customer/list/shopping_list_page.dart';
import 'package:freshtally/pages/manager/home/manager_home_screen.dart';
import 'package:freshtally/pages/shelfStaff/shelves/shelf_mapping_page.dart';
import 'package:freshtally/pages/auth/create_supermarket_page.dart';
import 'package:freshtally/pages/auth/join_supermarket_page.dart';
import 'package:freshtally/pages/auth/role_selection_page.dart';
import 'package:freshtally/pages/auth/customer_signup_page.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'firebase_options.dart';
import 'pages/auth/login_page.dart';
import 'pages/customer/home/customer_home_page.dart';
import 'pages/customer/search/product_search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FreshTallyApp());
}

class FreshTallyApp extends StatelessWidget {
  const FreshTallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshTally',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/customerHome':
            return MaterialPageRoute(builder: (_) => const CustomerHomePage());
          case '/customerSearch':
            return MaterialPageRoute(builder: (_) => const ProductSearchPage());
          case '/shoppingList':
            return MaterialPageRoute(builder: (_) => const ShoppingListPage());
          case '/shelfMapping':
            return MaterialPageRoute(builder: (_) => const ShelfMappingPage());
          case '/shelfStaffHome':
            return MaterialPageRoute(builder: (_) => const ShelfMappingPage());
          case '/managerHome':
            return MaterialPageRoute(
              builder: (_) {
                return const LoginPage();
              },
            );
          case '/createSupermarket':
            return MaterialPageRoute(
              builder: (_) {
                return const CreateSupermarketPage();
              },
            );
          case '/joinSupermarket':
            return MaterialPageRoute(
              builder: (_) {
                return const JoinSupermarketPage();
              },
            );
          case '/roleSelection':
            return MaterialPageRoute(
              builder: (_) {
                return const RoleSelectionPage(role: '');
              },
            );
          case '/staffSignup':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => ShelfStaffDashboard(
                supermarketName: args['supermarketName'],
                location: args['location'],
              ),
            );
          case '/customerSignup':
            return MaterialPageRoute(
              builder: (_) {
                return const CustomerSignupPage();
              },
            );
          // case '/staff/home':
          //   return MaterialPageRoute(builder: (_) { return const HomeScreen(); });
          case '/staff/shelfStaffHome':
            return MaterialPageRoute(
              builder: (_) {
                return const ShelfStaffDashboard();
              },
            );
          case '/staff/managerHome':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) {
                return ManagerDashboardPage(
                  supermarketName: args['supermarketName'],
                  location: args['location'],
                );
              },
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404 - Page not found')),
              ),
            );
        }
      },
    );
  }
}
