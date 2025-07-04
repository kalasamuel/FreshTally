import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Shelf Suggestions UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const SmartShelfSuggestionsPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class SmartShelfSuggestionsPage extends StatelessWidget {
  const SmartShelfSuggestionsPage({super.key});

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
            padding: const EdgeInsets.all(16.0), // Padding inside the main card
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
                  padding: const EdgeInsets.only(
                    bottom: 24.0,
                  ), // More space below app bar
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
                      // "Smart Shelf Suggestions" title
                      const Text(
                        'Smart Shelf Suggestions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Display Section (Image and Name)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: [
                      // Placeholder for product image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors
                              .grey[200], // Light grey background for image placeholder
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ), // Rounded corners
                        ),
                        child: Icon(
                          Icons.image, // Placeholder icon
                          color: Colors.grey[500],
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16), // Spacer
                      // Product Name
                      const Text(
                        'Colgate Max Fresh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // Suggested Groupings Section
                const Text(
                  'Suggested Groupings:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8), // Spacer
                Container(
                  width: double.infinity, // Take full width
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FFE6), // Light green background
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Rounded corners
                    border: Border.all(
                      color: const Color(0xFF90EE90),
                    ), // Green border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSuggestionItem('Colgate Toothpaste'),
                      _buildSuggestionItem('Listerine Mouthwash'),
                      _buildSuggestionItem('Toothbrush'),
                    ],
                  ),
                ),
                // Reason Section
                const Text(
                  'Reason:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8), // Spacer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FFE6),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFF90EE90)),
                  ),
                  child: _buildSuggestionItem('Frequently Bought Together'),
                ),
                // Suggested Location Section
                const Text(
                  'Suggested Location:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8), // Spacer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(
                    bottom: 32.0,
                  ), // More space before buttons
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FFE6),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFF90EE90)),
                  ),
                  child: _buildSuggestionItem('Shelf 3 - Eye level'),
                ),
                const Spacer(), // Pushes buttons to the bottom
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceAround, // Distribute buttons evenly
                  children: [
                    // Accept Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('Accept pressed!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50), // Green
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between buttons
                    // Override Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('Override pressed!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFFC107,
                          ), // Orange/Amber
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Override',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between buttons
                    // Ignore Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('Ignore pressed!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[500], // Grey
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Ignore',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a suggestion item with a checkmark icon
  static Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 18,
          ), // Green checkmark
          const SizedBox(width: 8), // Spacer
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 16)),
        ],
      ),
    );
  }
}
