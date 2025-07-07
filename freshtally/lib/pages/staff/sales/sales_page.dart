import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Sale UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const NewSalePage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final TextEditingController _searchController = TextEditingController();

  // List to hold added items with their quantities
  final List<Map<String, dynamic>> _addedItems = [
    {
      'product': 'Tomato Sauce',
      'price': 'UGX 3,000',
      'subtotal': 'UGX 6,000',
      'quantity': 3,
    },
    {
      'product': 'Brown Bread',
      'price': 'UGX 5,500',
      'subtotal': 'UGX 5,500',
      'quantity': 1,
    },
    {
      'product': 'Tomato Sauce',
      'price': 'UGX 3,000',
      'subtotal': 'UGX 6,000',
      'quantity': 3,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to update quantity for an item
  void _updateQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity >= 0) {
        // Ensure quantity doesn't go below zero
        _addedItems[index]['quantity'] = newQuantity;
        // You would typically recalculate subtotal here based on price and new quantity
        // For now, keeping it static as per image.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F7D9), // Light green background
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(
              20.0,
            ), // Margin around the main content area
            decoration: BoxDecoration(
              color: Colors.white, // White background for the main card
              borderRadius: BorderRadius.circular(
                20.0,
              ), // Rounded corners for the main card
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.1,
                  ), // Subtle shadow for depth
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the start
              children: [
                // App Bar Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back arrow icon
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Handle back button press
                          Navigator.pop(context);
                        },
                      ),
                      // "New Sale" title
                      const Text(
                        'New Sale',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      // Barcode icon
                      IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.black,
                        ), // Using qr_code_scanner for barcode
                        onPressed: () {
                          // Handle barcode scanner button press
                          print('Barcode scanner pressed!');
                        },
                      ),
                    ],
                  ),
                ),
                // Search Product Text Field
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Light grey background
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Rounded corners
                      border: Border.all(
                        color: Colors.grey[300]!,
                      ), // Light border
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search Product',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder
                            .none, // No border for the text field itself
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onChanged: (value) {
                        // Handle search text changes
                        print('Search product query: $value');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space below search bar
                // Added Items Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Added Items',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Space below "Added Items" title

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _addedItems.length,
                    itemBuilder: (context, index) {
                      final item = _addedItems[index];
                      return _buildAddedItemCard(
                        context,
                        product: item['product'],
                        price: item['price'],
                        subtotal: item['subtotal'],
                        quantity: item['quantity'],
                        onQuantityChanged: (newQuantity) {
                          _updateQuantity(index, newQuantity);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Space before sync now button
                // Sync Now Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print('Sync Now pressed for New Sale!');
                        // Implement sync logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Green
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        'Sync Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build an individual added item card
  Widget _buildAddedItemCard(
    BuildContext context, {
    required String product,
    required String price,
    required String subtotal,
    required int quantity,
    required ValueChanged<int> onQuantityChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0), // Space between item cards
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light grey background
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          _buildInfoRow('Product:', product),
          // Price
          _buildInfoRow('Price:', price),
          // Subtotal
          _buildInfoRow('Subtotal:', subtotal),
          const SizedBox(height: 12), // Space before quantity control
          // Quantity Control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quantity:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  // Decrement button
                  _buildQuantityButton(
                    Icons.remove,
                    () => onQuantityChanged(quantity - 1),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Increment button
                  _buildQuantityButton(
                    Icons.add,
                    () => onQuantityChanged(quantity + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build a row for product info (e.g., Product:, Price:)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 70, // Fixed width for labels for alignment
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build quantity increment/decrement buttons
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Light grey background for buttons
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black87),
        onPressed: onPressed,
        padding: EdgeInsets.zero, // Remove default padding
        constraints: const BoxConstraints(), // Remove default constraints
      ),
    );
  }
}
