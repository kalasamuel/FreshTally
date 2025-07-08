import 'package:flutter/material.dart';

class InventoryCategoryBreakdownPage extends StatelessWidget {
  const InventoryCategoryBreakdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory by Category')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryTile('Fruits & Vegetables', 120),
          _buildCategoryTile('Dairy', 80),
          _buildCategoryTile('Bakery', 45),
          _buildCategoryTile('Beverages', 150),
          _buildCategoryTile('Snacks', 95),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String category, int count) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.category, color: Colors.orange),
        title: Text(category),
        trailing: Text(
          '$count items',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
