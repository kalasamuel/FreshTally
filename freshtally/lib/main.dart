import 'package:flutter/material.dart';
import 'package:freshtally/pages/customer/discounts/discounts_page.dart';
import 'package:freshtally/pages/customer/feedback/customer_feedback_page.dart';
import 'package:freshtally/pages/customer/home/customer_home_page.dart';
import 'package:freshtally/pages/customer/list/shopping_list_page.dart';
import 'package:freshtally/pages/customer/product/products_details_page.dart';
import 'package:freshtally/pages/customer/search/product_search_page.dart';
import 'package:freshtally/pages/staff/expiry/expiry_tracking_page.dart';
import 'package:freshtally/pages/staff/home/cashier_home_screen.dart';
import 'package:freshtally/pages/staff/home/manager_home_screen.dart';
import 'package:freshtally/pages/staff/home/shelf_staff_home_screen.dart';
import 'package:freshtally/pages/staff/notifications/notification_center_page.dart';
import 'package:freshtally/pages/staff/products/edit_product_page.dart';
import 'package:freshtally/pages/staff/products/product_entry_page.dart';
import 'package:freshtally/pages/staff/products/product_list_page.dart';
import 'package:freshtally/pages/staff/settings/settings_page.dart';
import 'package:freshtally/pages/staff/shelves/shelf_mapping_page.dart';
import 'package:freshtally/pages/staff/shelves/smart_suggestions_page.dart';
import 'package:freshtally/pages/staff/sync/sync_status_page.dart';

// import your page files here
import 'pages/auth/login_page.dart';
import 'pages/auth/create_supermarket_page.dart';
import 'pages/auth/join_supermarket_page.dart';
import 'pages/auth/role_selection_page.dart';
import 'pages/auth/staff_signup_page.dart';
import 'pages/auth/customer_signup_page.dart';

// import 'pages/staff/home_screen.dart';

void main() {
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
          case '/staff/cashierHome':
            return MaterialPageRoute(
              builder: (_) {
                return const CashierDashboardPage();
              },
            );
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

          case '/customer/home':
            return MaterialPageRoute(
              builder: (_) {
                return const CustomerHomePage();
              },
            );
          case '/customer/search':
            return MaterialPageRoute(
              builder: (_) {
                return const ProductSearchPage();
              },
            );
          case '/customer/productDetails':
            return MaterialPageRoute(
              builder: (_) {
                return const ProductDetailsPage();
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
                return const DiscountsPage();
              },
            );
          case '/customer/feedback':
            return MaterialPageRoute(
              builder: (_) {
                return const CustomerFeedbackPage();
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
