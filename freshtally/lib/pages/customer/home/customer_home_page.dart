import 'package:flutter/material.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Groceries', 'Dairy', 'Snacks', 'Fresh', 'Drinks'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FreshTally'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          const Text(
            '🔥 Hot Discounts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DiscountCard(title: '50% OFF Chocolate 🍫'),
          DiscountCard(title: 'Buy 1 Get 1 Free – Milk 🥛'),
          const SizedBox(height: 20),

          // Suggested Combos
          const Text(
            '🧺 Suggested Combos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DiscountCard(title: 'Rice + Beans Combo 🍚 + 🫘'),
          DiscountCard(title: 'Tea + Sugar + Biscuits ☕️'),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.local_offer), label: 'Offers'),
          NavigationDestination(icon: Icon(Icons.feedback), label: 'Feedback'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // TODO: Navigate to appropriate screen
        },
      ),
    );
  }
}

class DiscountCard extends StatelessWidget {
  final String title;

  const DiscountCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF39C12).withOpacity(0.1),
      child: ListTile(
        leading: const Icon(Icons.local_offer, color: Color(0xFFF39C12)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Show product details
        },
      ),
    );
  }
}
