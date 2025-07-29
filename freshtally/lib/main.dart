import 'package:Freshtally/pages/shelfStaff/settings/settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Freshtally/pages/auth/staffcode.dart';
import 'package:Freshtally/pages/customer/list/shopping_list_page.dart';
import 'package:Freshtally/pages/manager/home/manager_home_screen.dart';
import 'package:Freshtally/pages/shelfStaff/shelves/shelf_mapping_page.dart';
import 'package:Freshtally/pages/shelfStaff/shelves/smart_suggestions_page.dart';
import 'package:Freshtally/pages/auth/create_supermarket_page.dart';
import 'package:Freshtally/pages/auth/role_selection_page.dart';
import 'package:Freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
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
      // Use a builder to handle initial routing based on auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const LoginPage();
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login': // Explicitly add a route for login page
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/customerHome':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) =>
                  CustomerHomePage(supermarketId: args['supermarketId'] ?? ''),
            );
          case '/customerSearch':
            // Extract supermarketId from arguments
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final String supermarketId = args['supermarketId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => ProductSearchPage(supermarketId: supermarketId),
            );
          case '/shoppingList':
            // Extract supermarketId from arguments
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final String supermarketId = args['supermarketId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => ShoppingListPage(supermarketId: supermarketId),
            );
          case '/shelfMapping':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) =>
                  ShelfMappingPage(supermarketId: args['supermarketId'] ?? ''),
            );
          case '/shelfStaffHome':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => ShelfStaffDashboard(
                supermarketName: args['supermarketName'] ?? '',
                location: args['location'] ?? '',
                supermarketId: args['supermarketId'] ?? '',
              ),
            );
          case '/smartSuggestions':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => SmartShelfSuggestionsPage(
                supermarketId: args['supermarketId'] ?? '',
              ),
            );
          case '/managerHome':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) {
                return ManagerDashboardPage(
                  supermarketName: args['supermarketName'],
                  location: args['location'],
                  supermarketId: args['supermarketId'] ?? '',
                  managerId: args['managerId'] ?? '',
                );
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
                return const StaffVerificationPage(
                  firstName: '',
                  lastName: '',
                  email: '',
                  password: '',
                  phone: '',
                  userId: '',
                );
              },
            );
          case '/roleSelection':
            return MaterialPageRoute(
              builder: (_) {
                return const RoleSelectionPage(role: '');
              },
            );

          // /settings
          case '/settings':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final String supermarketId = args['supermarketId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => SettingsPage(supermarketId: supermarketId),
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
