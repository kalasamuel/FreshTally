import 'package:flutter/material.dart';
import 'package:freshtally/pages/customer/search/product_search_page.dart';
import 'package:freshtally/pages/customer/list/shopping_list_page.dart';
import 'package:freshtally/pages/customer/discounts/discounts_and_promotions.dart';
import 'package:freshtally/pages/customer/customerNotifications/customer_notifications.dart';
import 'package:freshtally/pages/shelfStaff/settings/settings_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  // Define the pages for the bottom navigation bar.
  late final List<Widget> _pages;

  // Define the titles for the app bar.
  static const List<String> _titles = [
    'Home',
    'Search Products',
    'Shopping List',
    'Discounts & Offers',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize _pages here, passing the callback to _HomeBody.
    _pages = <Widget>[
      _HomeBody(onNavigateToOffers: _navigateToOffersTab), // Pass the callback
      const ProductSearchPage(),
      const ShoppingListPage(),
      const DiscountsAndPromotionsPage(),
      const NotificationsPage(),
    ];
  }

  // Callback function to change the selected index to the Offers tab.
  void _navigateToOffersTab() {
    setState(() {
      _selectedIndex = 3; // Index for 'Offers' tab
    });
  }

  // Handler for when a navigation bar item is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 24, // Consistent font size for app bar titles.
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFFFFFF), // App bar background color.
        elevation: 0.0, // No shadow for a clean look.
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: Colors.black87,
            ), // Consistent icon size and color.
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(
              Icons.settings,
              size: 30,
              color: Colors.black87,
            ), // Consistent icon size and color.
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page.
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.local_offer), label: 'Offers'),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: const Color(
          0xFFFFFFFF,
        ), // Navigation bar background color.
        indicatorColor: const Color(
          0xFFC8E6C9,
        ), // Indicator color for selected item.
        labelBehavior: NavigationDestinationLabelBehavior
            .alwaysShow, // Always show labels.
      ),
    );
  }
}

// _HomeBody is now a StatefulWidget to manage its own state (e.g., filter chips).
class _HomeBody extends StatelessWidget {
  // Callback to notify the parent to change the tab.
  final VoidCallback onNavigateToOffers;

  const _HomeBody({required this.onNavigateToOffers});

  @override
  Widget build(BuildContext context) {
    final categories = ['Groceries', 'Dairy', 'Snacks', 'Fresh', 'Drinks'];

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ), // Consistent padding.
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: const TextStyle(
              color: Colors.black54,
            ), // Consistent hint style.
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.black87,
            ), // Consistent icon color.
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                12,
              ), // Consistent rounded corners.
              borderSide: BorderSide.none, // No border.
            ),
            filled: true,
            fillColor: const Color(0xFFF5F6FA), // Consistent fill color.
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ), // Consistent text style.
        ),
        const SizedBox(height: 20), // Increased space.
        // Horizontal Category Chips
        SizedBox(
          height: 44, // Adjusted height for better visual.
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => Chip(
              label: Text(
                categories[index],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              backgroundColor: const Color(
                0xFFF5F6FA,
              ), // Consistent chip background.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12.0,
                ), // Consistent rounded corners.
                side: BorderSide.none, // No border.
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ), // Adjusted padding.
            ),
          ),
        ),
        const SizedBox(height: 24), // Increased space.
        // Hot Discounts Section Title
        const Text(
          'Hot Discounts',
          style: TextStyle(
            fontSize: 20, // Consistent section title font size.
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Consistent text color.
          ),
        ),
        const SizedBox(height: 12), // Space below title.
        // Hot Discounts Cards
        DiscountCard(
          title: '50% OFF Chocolate',
          cardColor: const Color(0xFFFFE0E6), // Light pink.
          iconColor: const Color(0xFFE91E63), // Darker pink.
          onTap:
              onNavigateToOffers, // Call the callback to navigate to Offers tab.
        ),
        const SizedBox(height: 12), // Space between cards.
        DiscountCard(
          title: 'Buy 1 Get 1 Free – Milk',
          cardColor: const Color(0xFFFFE0E6),
          iconColor: const Color(0xFFE91E63),
          onTap:
              onNavigateToOffers, // Call the callback to navigate to Offers tab.
        ),
        const SizedBox(height: 24), // Increased space.
        // Suggested Combos Section Title
        const Text(
          'Suggested Combos',
          style: TextStyle(
            fontSize: 20, // Consistent section title font size.
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Consistent text color.
          ),
        ),
        const SizedBox(height: 12), // Space below title.
        // Suggested Combos Cards
        const DiscountCard(
          title: 'Rice + Beans Combo',
          cardColor: Color(0xFFE3F2FD), // Light blue.
          iconColor: Color(0xFF1976D2), // Blue.
        ),
        const SizedBox(height: 12), // Space between cards.
        const DiscountCard(
          title: 'Tea + Sugar + Biscuits',
          cardColor: Color(0xFFE3F2FD),
          iconColor: Color(0xFF1976D2),
        ),
        const SizedBox(height: 24), // Space at the bottom.
      ],
    );
  }
}

class DiscountCard extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const DiscountCard({
    super.key,
    required this.title,
    this.cardColor = const Color(0xFFF5F6FA), // Default to a light background.
    this.iconColor = Colors.black87, // Default icon color.
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1, // Consistent subtle elevation.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Consistent rounded corners.
      color: cardColor,
      child: InkWell(
        onTap: onTap, // Use the provided onTap callback.
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Consistent padding.
          child: Row(
            children: [
              Icon(
                Icons.local_offer,
                color: iconColor,
                size: 28,
              ), // Consistent icon size.
              const SizedBox(width: 16), // Space between icon and text.
              Expanded(
                // Ensures text wraps if too long.
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16, // Consistent text size.
                    fontWeight: FontWeight.w600,
                    color: Colors.black87, // Consistent text color.
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.black87,
                size: 24,
              ), // Consistent icon size and color.
            ],
          ),
        ),
      ),
    );
  }
}
