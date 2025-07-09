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

  static final List<Widget> _pages = <Widget>[
    _HomeBody(),
    ProductSearchPage(),
    ShoppingListPage(),
    DiscountsAndPromotionsPage(),
    NotificationsPage(),
  ];

  static const List<String> _titles = [
    'Home',
    'Search Products',
    'Shopping List',
    'Discounts & Offers',
    'Notifications',
  ];

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
        title: Center(child: Text(_titles[_selectedIndex])),
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
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.local_offer), label: 'Offers'),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final categories = ['Groceries', 'Dairy', 'Snacks', 'Fresh', 'Drinks'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Category Chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => Chip(
              label: Text(categories[index]),
              backgroundColor: const Color(0xFFF5F6FA),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Hot Discounts
        Text(
          'Hot Discounts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade700, // More appealing color
          ),
        ),
        const SizedBox(height: 10),
        DiscountCard(
          title: '50% OFF Chocolate',
          cardColor: const Color(0xFFFFE0E6),
          iconColor: const Color(0xFFE91E63),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscountsAndPromotionsPage(
                  highlightProductName: 'Chocolate Bar',
                ),
              ),
            );
          },
        ),
        DiscountCard(
          title: 'Buy 1 Get 1 Free – Milk',
          cardColor: const Color(0xFFFFE0E6),
          iconColor: const Color(0xFFE91E63),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscountsAndPromotionsPage(
                  highlightProductName: 'Fresh Milk 1L',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Suggested Combos
        Text(
          'Suggested Combos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700, // More appealing color
          ),
        ),
        const SizedBox(height: 10),
        const DiscountCard(
          title: 'Rice + Beans Combo',
          cardColor: Color(0xFFE3F2FD), // Light blue
          iconColor: Color(0xFF1976D2), // Blue
        ),
        const DiscountCard(
          title: 'Tea + Sugar + Biscuits',
          cardColor: Color(0xFFE3F2FD),
          iconColor: Color(0xFF1976D2),
        ),
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
    this.cardColor = const Color(0xFFF39C12),
    this.iconColor = const Color(0xFFF39C12),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: ListTile(
        leading: Icon(Icons.local_offer, color: iconColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
