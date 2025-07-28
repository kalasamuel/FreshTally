import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Freshtally/pages/customer/product/products_details_page.dart';
import 'package:Freshtally/pages/customer/search/product_search_page.dart';
import 'package:Freshtally/pages/customer/list/shopping_list_page.dart';
import 'package:Freshtally/pages/customer/discounts/discounts_and_promotions.dart';
import 'package:Freshtally/pages/customer/customerNotifications/customer_notifications.dart';
import 'package:Freshtally/pages/shelfStaff/settings/settings_page.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Freshtally/pages/auth/login_page.dart';
import 'package:Freshtally/pages/auth/supermarket_selection_page.dart';
import 'package:intl/intl.dart';

// --- Re-include the Promotion model if not globally available ---
// This is important for consistency and type safety.
// If you have a shared models file, ensure it's imported.
class Promotion {
  final String promotionId;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double originalPrice;
  final double discountPercentage;
  final double discountedPrice;
  final DateTime discountExpiry;
  final DateTime createdAt;

  Promotion({
    required this.promotionId,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.discountExpiry,
    required this.createdAt,
  });

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      promotionId: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? 'Unnamed Promotion',
      productImageUrl: data['imageUrl'], // Using 'imageUrl' from Promotion
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      discountedPrice: (data['discountedPrice'] ?? 0).toDouble(),
      discountExpiry: (data['discountExpiry'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class CustomerHomePage extends StatefulWidget {
  // supermarketName and location are now optional as they will be fetched dynamically
  final String? supermarketName;
  final String? location;
  final String supermarketId; // This is crucial and required for context

  const CustomerHomePage({
    super.key,
    this.supermarketName,
    this.location,
    required this.supermarketId,
  });

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;
  late List<Widget>
  _pages; // Will be initialized in initState based on supermarketId
  String _currentSupermarketName = 'Loading...';
  String _currentSupermarketLocation = 'Loading...';

  static const List<String> _titles = [
    'Home',
    'Search Products',
    'Shopping List',
    'Discounts & Offers',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch supermarket details when the page initializes
    _fetchSupermarketDetails();

    // Initialize pages, passing the supermarketId to each relevant screen.
    // This ensures all sub-tabs operate within the context of the selected supermarket.
    _pages = <Widget>[
      _HomeBody(
        onNavigateToOffers: _navigateToOffersTab,
        supermarketId: widget.supermarketId,
      ),
      ProductSearchPage(supermarketId: widget.supermarketId),
      ShoppingListPage(supermarketId: widget.supermarketId),
      DiscountsAndPromotionsPage(supermarketId: widget.supermarketId),
      NotificationsPage(supermarketId: widget.supermarketId),
    ];
  }

  // Fetches supermarket name and location based on widget.supermarketId from Firestore
  Future<void> _fetchSupermarketDetails() async {
    // Defensive check: If supermarketId is somehow empty, handle it.
    if (widget.supermarketId.isEmpty) {
      setState(() {
        _currentSupermarketName = 'Invalid Supermarket';
        _currentSupermarketLocation = 'Please switch or re-login.';
      });
      _showSnackBar(
        'Invalid supermarket selected. Please choose another.',
        isError: true,
      );
      // Give user time to see message, then redirect
      Future.delayed(
        const Duration(seconds: 2),
        () => _navigateToSupermarketSelection(),
      );
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _currentSupermarketName = data['name'] ?? 'Unnamed Supermarket';
          _currentSupermarketLocation = data['location'] ?? 'Unknown Location';
        });
      } else {
        // If the supermarket document does not exist for the ID
        setState(() {
          _currentSupermarketName = 'Supermarket Not Found';
          _currentSupermarketLocation = 'Please select another';
        });
        _showSnackBar(
          'Selected supermarket details not found. It might have been removed.',
          isError: true,
        );
        Future.delayed(
          const Duration(seconds: 2),
          () => _navigateToSupermarketSelection(),
        );
      }
    } catch (e) {
      debugPrint(
        'Error fetching supermarket details for ${widget.supermarketId}: $e',
      );
      setState(() {
        _currentSupermarketName = 'Error Loading';
        _currentSupermarketLocation = 'Check connection';
      });
      _showSnackBar('Failed to load supermarket details.', isError: true);
    }
  }

  void _navigateToOffersTab() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Function to navigate back to the SupermarketSelectionPage for switching
  void _navigateToSupermarketSelection() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Use pushAndRemoveUntil to clear the navigation stack below the selection page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SupermarketSelectionPage(
            customerId: currentUser.uid,
            // You can pass an initial message if desired
            initialMessage: 'You can switch to another supermarket here.',
          ),
        ),
        (Route<dynamic> route) => false, // Clears all previous routes
      );
    } else {
      // Fallback: If for some reason user is not logged in, go to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Ensures no back button is automatically added
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        titleSpacing: 0, // Remove default spacing around title
        title: Row(
          children: [
            // Supermarket Name and Location (Left side) - now tappable to switch
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap:
                    _navigateToSupermarketSelection, // Tap to switch supermarket
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentSupermarketName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _currentSupermarketLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Centered Page Title
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Notifications Icon
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(supermarketId: widget.supermarketId),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: Colors.black87,
            ),
          ),
          // Settings Icon
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsPage(supermarketId: widget.supermarketId),
                ),
              );
            },
            icon: const Icon(Icons.settings, size: 30, color: Colors.black87),
          ),
          const SizedBox(width: 8),
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
        backgroundColor: const Color(0xFFFFFFFF),
        indicatorColor: const Color(0xFFC8E6C9),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

// --- MODIFIED _HomeBody Widget ---
class _HomeBody extends StatelessWidget {
  final VoidCallback onNavigateToOffers;
  final String supermarketId;

  const _HomeBody({
    required this.onNavigateToOffers,
    required this.supermarketId,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Groceries', 'Dairy', 'Snacks', 'Fresh', 'Drinks'];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        TypeAheadField<Map<String, dynamic>>(
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search products in this supermarket...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            );
          },
          suggestionsCallback: (pattern) async {
            if (pattern.isEmpty) return [];
            final querySnapshot = await FirebaseFirestore.instance
                .collection('products') // Still search general products here
                .where('supermarketId', isEqualTo: supermarketId)
                .where('name', isGreaterThanOrEqualTo: pattern)
                .where('name', isLessThanOrEqualTo: '$pattern\uf8ff')
                .limit(10)
                .get();

            return querySnapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
          },
          itemBuilder: (context, suggestion) {
            final String imageUrl = suggestion['image_url'] ?? '';
            final String name = suggestion['name'] ?? 'Unnamed Product';
            final num price = suggestion['price'] ?? 0;

            return ListTile(
              leading: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 40),
                    )
                  : const Icon(Icons.image, size: 40),
              title: Text(name),
              subtitle: Text('UGX $price'),
            );
          },
          onSelected: (suggestion) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(
                  productId: suggestion['id'],
                  supermarketId: supermarketId,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        /// Categories
        SizedBox(
          height: 44,
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
              backgroundColor: const Color(0xFFF5F6FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Hot Discounts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        /// Hot Discounts - MODIFIED STREAM
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('supermarkets')
              .doc(supermarketId)
              .collection(
                'promotions',
              ) // Correctly fetch from 'promotions' subcollection
              .where(
                'discountPercentage',
                isGreaterThan: 0,
              ) // Filter for actual discounts
              .where(
                'discountExpiry',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
              ) // Only show active promotions
              .orderBy(
                'discountPercentage',
                descending: true,
              ) // Order by highest discount
              .limit(4) // Limit to top 4 hot discounts
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load discounts: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final promotions = snapshot.data!.docs
                .map((doc) => Promotion.fromFirestore(doc))
                .toList();

            if (promotions.isEmpty) {
              return const Center(
                child: Text('No active hot discounts for this supermarket.'),
              );
            }

            return Column(
              children: promotions.map((promotion) {
                // Use the Promotion object's properties
                return DiscountCard(
                  title:
                      '${promotion.productName}: UGX ${promotion.discountedPrice.toStringAsFixed(0)}',
                  subtitle:
                      'Was UGX ${promotion.originalPrice.toStringAsFixed(0)} • Expires: ${DateFormat('yyyy-MM-dd').format(promotion.discountExpiry)}',
                  cardColor: const Color(0xFFFFE0E6),
                  iconColor: const Color(0xFFE91E63),
                  onTap: onNavigateToOffers, // Still navigate to the offers tab
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class DiscountCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color cardColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const DiscountCard({
    super.key,
    required this.title,
    this.subtitle,
    this.cardColor = const Color(0xFFF5F6FA),
    this.iconColor = Colors.black87,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.local_offer, color: iconColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black87, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
