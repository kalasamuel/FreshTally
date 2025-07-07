import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expiry Tracking',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Inter'),
      home: const ExpiryTrackingPage(),
      debugShowCheckedModeBanner: false,
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
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // App Bar Section
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
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
              // Yogurt Card
              Container(
                //first card
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0), // Light reddish background
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFFFCCCC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildProductCard(
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
                    cardColor: Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                ),
              ),
              // Bread Card
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFE0), // Light yellowish background
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFFFF7A0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildProductCard(
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
                    cardColor: Colors.transparent, // Already colored by parent
                    borderColor: Colors.transparent,
                  ),
                ),
              ),
            ],
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
        // Product Details
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...details.map((detail) => _buildDetailItem(detail)),
            const SizedBox(height: 16),
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
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16.0,
                      ),
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.green,
                      overlayColor: Colors.green.withOpacity(0),
                    ),
                    child: Slider(
                      value: initialDiscount,
                      min: 0,
                      max: 100,
                      divisions: 100,
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
        const SizedBox(height: 16),
        // Move to Eye-Level Shelf Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              print('Move to Eye-Level Shelf for $productName pressed!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 1,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
