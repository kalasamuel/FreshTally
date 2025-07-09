import 'package:firebase_core/firebase_core.dart';
import 'utils/firestore_seeder.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:freshtally/pages/customer/discounts/discounts_and_promotions.dart';
import 'package:freshtally/pages/customer/home/customer_home_page.dart';
import 'package:freshtally/pages/customer/list/shopping_list_page.dart';
import 'package:freshtally/pages/customer/product/products_details_page.dart';
import 'package:freshtally/pages/customer/search/product_search_page.dart';
import 'package:freshtally/pages/shelfStaff/expiry/expiry_tracking_page.dart';
import 'package:freshtally/pages/manager/home/manager_home_screen.dart';
import 'package:freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:freshtally/pages/shelfStaff/notifications/notifications_shelfstaff.dart';
import 'package:freshtally/pages/shelfStaff/products/edit_product_page.dart';
import 'package:freshtally/pages/shelfStaff/products/product_entry_page.dart';
import 'package:freshtally/pages/shelfStaff/products/product_list_page.dart';
import 'package:freshtally/pages/shelfStaff/settings/settings_page.dart';
import 'package:freshtally/pages/shelfStaff/shelves/shelf_mapping_page.dart';
import 'package:freshtally/pages/shelfStaff/shelves/smart_suggestions_page.dart';
import 'package:freshtally/pages/shelfStaff/sync/sync_status_page.dart';

// import your page files here
import 'pages/auth/login_page.dart';
import 'pages/auth/create_supermarket_page.dart';
import 'pages/auth/join_supermarket_page.dart';
import 'pages/auth/role_selection_page.dart';
import 'pages/auth/staff_signup_page.dart';
import 'pages/auth/customer_signup_page.dart';

// import 'pages/staff/home_screen.dart';
void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await uploadProductsToFirestore();
  runApp(const FreshTallyApp());
}

class FreshTallyApp extends StatelessWidget {
  const FreshTallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshTally',
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
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
            final role = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) {
                return StaffSignupPage(role: role ?? '');
              },
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
                return const ShelfStaffDashboardPage();
              },
            );
          case '/staff/managerHome':
            return MaterialPageRoute(
              builder: (_) {
                return const ManagerDashboardPage();
              },
            );
          case '/staff/productEntry':
            return MaterialPageRoute(
              builder: (_) {
                return const ProductEntryPage();
              },
            );
          case '/staff/editProduct':
            return MaterialPageRoute(
              builder: (_) {
                return const EditProductPage();
              },
            );
          case '/staff/productList':
            return MaterialPageRoute(
              builder: (_) {
                return const ProductListPage();
              },
            );
          // case '/staff/batchEntry':
          //   return MaterialPageRoute(builder: (_) { return const BatchEntryPage(); });
          case '/staff/shelfMapping':
            return MaterialPageRoute(
              builder: (_) {
                return const ShelfMappingPage();
              },
            );
          case '/staff/smartShelfSuggestions':
            return MaterialPageRoute(
              builder: (_) {
                return const SmartShelfSuggestionsPage();
              },
            );
          case '/staff/expiryTracking':
            return MaterialPageRoute(
              builder: (_) {
                return const ExpiryTrackingPage();
              },
            );
          case '/staff/notifications':
            return MaterialPageRoute(
              builder: (_) {
                return const NotificationCenterPage();
              },
            );
          case '/staff/syncStatus':
            return MaterialPageRoute(
              builder: (_) {
                return const SyncStatusPage();
              },
            );
          // case '/staff/sales':
          //   return MaterialPageRoute(builder: (_) { return const SalesPage(); });
          // case '/staff/analytics':
          //   return MaterialPageRoute(builder: (_) { return const AnalyticsDashboardPage(); });
          // case '/staff/expiredProductDetails':
          //   return MaterialPageRoute(builder: (_) { return const ExpiredProductDetailsPage(); });
          // case '/staff/inventoryBreakdown':
          //   return MaterialPageRoute(builder: (_) { return const InventoryCategoryBreakdownPage(); });
          // case '/staff/restockingTrends':
          //   return MaterialPageRoute(builder: (_) { return const RestockingTrendsPage(); });
          // case '/staff/userRoles':
          //   return MaterialPageRoute(builder: (_) { return const UserRoleManagementPage(); });
          case '/staff/settings':
            return MaterialPageRoute(
              builder: (_) {
                return const SettingsPage();
              },
            );
          case '/customer/search':
            return MaterialPageRoute(
              builder: (_) {
                return const ProductSearchPage();
              },
            );
          case '/customer/shoppingList':
            return MaterialPageRoute(
              builder: (_) {
                return const ShoppingListPage();
              },
            );
          case '/customer/discounts':
            return MaterialPageRoute(
              builder: (_) {
                return const DiscountsAndPromotionsPage();
              },
            );

          default:
            return MaterialPageRoute(
              builder: (_) {
                return const Scaffold(
                  body: Center(child: Text('404 - Page not found')),
                );
              },
            );
        }
      },
    );
  }
}
