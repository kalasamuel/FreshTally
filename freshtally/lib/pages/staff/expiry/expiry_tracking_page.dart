import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expiry Tracking UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const ExpiryTrackingPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class ExpiryTrackingPage extends StatefulWidget {
  const ExpiryTrackingPage({super.key});

  @override
  State<ExpiryTrackingPage> createState() => _ExpiryTrackingPageState();
}

class _ExpiryTrackingPageState extends State<ExpiryTrackingPage> {
  // State for the discount slider of the first product
  double _discountValue1 = 30.0;
  // State for the discount slider of the second product
  double _discountValue2 = 26.0;

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
                      // "Expiry Tracking Page" title
                      const Text(
                        'Expiry Tracking Page',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Padding for the list view content
                    children: [
                      // First Product Card (Yogurt)
                      _buildProductCard(
                        context,
                        productName: 'Yogurt 500ml',
                        details: [
                          'Expiry: 2 days left',
                          'Quantity: 20 units',
                          'Shelf: Floor 1 • Shelf 3 • Middle',
                          'Projected Loss: UGX. 10,000',
                          'Recovery if discounted: UGX. 8,000',
                          'Shelf: Floor 1 • Shelf 3 • Middle',
                        ],
                        initialDiscount: _discountValue1,
                        onDiscountChanged: (newValue) {
                          setState(() {
                            _discountValue1 = newValue;
                          });
                        },
                        cardColor: const Color(
                          0xFFFFF0F0,
                        ), // Light reddish background
                        borderColor: const Color(0xFFFFCCCC), // Reddish border
                      ),
                      const SizedBox(height: 20), // Space between cards
                      // Second Product Card (Bread)
                      _buildProductCard(
                        context,
                        productName: 'Bread – Whole Wheat',
                        details: [
                          'Expiry: 4 days left',
                          'Quantity: 10 units',
                          'Shelf: Floor 1 • Shelf 3 • Middle',
                          'Projected Loss: UGX. 7,500',
                          'Recovery if discounted: UGX. 6,000',
                          'Shelf: Floor 1 • Shelf 3 • Middle',
                        ],
                        initialDiscount: _discountValue2,
                        onDiscountChanged: (newValue) {
                          setState(() {
                            _discountValue2 = newValue;
                          });
                        },
                        cardColor: const Color(
                          0xFFFFFFE0,
                        ), // Light yellowish background
                        borderColor: const Color(
                          0xFFFFF7A0,
                        ), // Yellowish border
                      ),
                      const SizedBox(height: 20), // Space after the last card
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a product card
  Widget _buildProductCard(
    BuildContext context, {
    required String productName,
    required List<String> details,
    required double initialDiscount,
    required ValueChanged<double> onDiscountChanged,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            productName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        // Product Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: cardColor, // Dynamic card color
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: borderColor), // Dynamic border color
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List of details
              ...details.map((detail) => _buildDetailItem(detail)).toList(),
              const SizedBox(height: 16), // Spacer before discount slider
              // Discount Slider
              Row(
                children: [
                  const Text(
                    'Discount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0, // Thinner track
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8.0,
                        ), // Smaller thumb
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16.0,
                        ), // Smaller overlay
                        activeTrackColor: Colors.green, // Green active track
                        inactiveTrackColor:
                            Colors.grey[300], // Light grey inactive track
                        thumbColor: Colors.green, // Green thumb
                        overlayColor: Colors.green.withOpacity(
                          0.2,
                        ), // Green overlay
                      ),
                      child: Slider(
                        value: initialDiscount,
                        min: 0,
                        max: 100,
                        divisions: 100, // Allow 1% increments
                        label: '${initialDiscount.round()}%',
                        onChanged: onDiscountChanged,
                      ),
                    ),
                  ),
                  Text(
                    '${initialDiscount.round()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // Space between card and button
        // Move to Eye-Level Shelf Button
        SizedBox(
          width: double.infinity, // Button takes full width
          child: ElevatedButton(
            onPressed: () {
              print('Move to Eye-Level Shelf for $productName pressed!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50), // Green button color
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              elevation: 3, // Add a subtle shadow
            ),
            child: const Text(
              'Move to Eye-Level Shelf',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build a detail item with an info icon
  Widget _buildDetailItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align icon and text at the top
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.red,
            size: 18,
          ), // Red info icon
          const SizedBox(width: 8), // Spacer
          Expanded(
            // Use Expanded to wrap text if it's long
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
