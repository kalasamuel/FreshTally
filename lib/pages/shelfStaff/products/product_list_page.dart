import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const ProductListPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  // Currently selected category for the dropdown
  String _selectedCategory = 'Category';
  // List of dummy products to display
  final List<Map<String, String>> _products = List.generate(
    20, // Generate 20 dummy product entries
    (index) => {
      'name': 'Product name',
      'location': 'Floor 1 - Shelf 20',
      'price': '20,000',
    },
  );

  @override
  void dispose() {
    _searchController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
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
              children: [
                // App Bar Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
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
                      const SizedBox(width: 8), // Spacer
                      // "All products" title
                      const Text(
                        'All products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search Bar Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[100], // Light grey background for search bar
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Rounded corners
                      border: Border.all(
                        color: Colors.grey[300]!,
                      ), // Light border
                    ),
                    child: Row(
                      children: [
                        // Search icon
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8), // Spacer
                        // Search text field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder
                                  .none, // No border for the text field itself
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                            ),
                            onChanged: (value) {
                              // Handle search text changes
                              print('Search query: $value');
                            },
                          ),
                        ),
                        // Category dropdown
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                            items:
                                <String>[
                                  'Category',
                                  'Electronics',
                                  'Clothing',
                                  'Books',
                                  'Food',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Product List Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: const [
                      // Product Name Header
                      Expanded(
                        flex: 3, // Allocate more space for product name
                        child: Text(
                          'Product name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Self Location Header
                      Expanded(
                        flex: 3, // Allocate more space for self location
                        child: Text(
                          'Self location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Price Header
                      Expanded(
                        flex: 2, // Allocate less space for price
                        child: Text(
                          'Price (Ugx.)',
                          textAlign:
                              TextAlign.right, // Align price to the right
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product List Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      // Determine if the current row should be highlighted
                      final bool isHighlighted =
                          index == 3; // Highlight the 4th item (index 3)

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isHighlighted
                              ? const Color(0xFFE6FFE6)
                              : Colors
                                    .white, // Light green for highlighted, white otherwise
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ), // Rounded corners for list items
                          border: Border.all(
                            color: isHighlighted
                                ? const Color(0xFF90EE90)
                                : Colors
                                      .grey[200]!, // Green border for highlighted, light grey otherwise
                          ),
                        ),
                        child: Row(
                          children: [
                            // Product Name
                            Expanded(
                              flex: 3,
                              child: Text(
                                product['name']!,
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),
                            // Self Location
                            Expanded(
                              flex: 3,
                              child: Text(
                                product['location']!,
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),
                            // Price
                            Expanded(
                              flex: 2,
                              child: Text(
                                product['price']!,
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
