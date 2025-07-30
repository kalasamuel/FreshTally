import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Keep Firestore import if it's used
// Assuming settings page is shared or similar

// PriceEntryPage is now a StatefulWidget to manage its TextEditingControllers.
class PriceEntryPage extends StatefulWidget {
  const PriceEntryPage({super.key, required String supermarketId});

  @override
  State<PriceEntryPage> createState() => _PriceEntryPageState();
}

class _PriceEntryPageState extends State<PriceEntryPage> {
  // Controllers for the text fields.
  final productIdController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed from the tree.
    productIdController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // Here is the function to handle price update.
  void _updatePrice() {
    // Check if controllers have text before attempting to update.
    if (productIdController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Product ID and Price.'),
        ),
      );
      return;
    }

    // Parses the price input, defaulting to 0 if invalid.
    final newPrice = double.tryParse(priceController.text) ?? 0.0;

    // Simulate saving to Firestore (keep this logic if Firestore is actually used).
    // In a real app, you'd handle success/failure and potentially show a loading indicator.
    FirebaseFirestore.instance
        .collection('products')
        .doc(productIdController.text)
        .update({'price': newPrice})
        .then((_) {
          // Show a success message.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Price updated successfully!')),
          );
          // Optionally navigate back after successful update.
          Navigator.pop(context);
        })
        .catchError((error) {
          // Show an error message if the update fails.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update price: $error')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFFFFF,
      ), // Sets the background color of the scaffold to white.
      appBar: AppBar(
        backgroundColor: const Color(
          0xFFFFFFFF,
        ), // AppBar background color matches the body.
        elevation: 0.0, // Removes the shadow under the app bar for a flat look.
        title: const Text(
          'Price Entry',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true, // Centers the title in the app bar.
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0, // Horizontal padding for the content.
              vertical: 24.0, // Vertical padding for the content.
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Aligns children to the start (left).
              children: [
                // Section Title for "Price Details".
                const Text(
                  'Price Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24), // Space below the section title.
                // Product ID Field
                TextField(
                  controller: productIdController,
                  decoration: InputDecoration(
                    labelText: 'Product ID',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16), // Space between fields.
                // Price Field
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType:
                      TextInputType.number, // Ensures numeric keyboard.
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 32), // Space before the button.
                // Update Price Button
                SizedBox(
                  width: double.infinity, // Button takes full width.
                  height: 56, // Fixed height for the button.
                  child: ElevatedButton(
                    onPressed: _updatePrice, // Calls the _updatePrice method.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFC8E6C9,
                      ), // Background color.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded corners.
                      ),
                      elevation: 0.1, // Subtle elevation.
                    ),
                    child: const Text(
                      'Update Price',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
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
}
