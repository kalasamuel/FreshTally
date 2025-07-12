import 'package:flutter/material.dart';
import 'package:freshtally/pages/auth/staff_signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Join Supermarket',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const JoinSupermarketPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class JoinSupermarketPage extends StatefulWidget {
  const JoinSupermarketPage({super.key});

  @override
  State<JoinSupermarketPage> createState() => _JoinSupermarketPageState();
}

class _JoinSupermarketPageState extends State<JoinSupermarketPage> {
  // Text editing controllers for the input fields
  final TextEditingController _searchSupermarketController =
      TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _searchSupermarketController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Light green background
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(
              20.0,
            ), // Margin around the main content area
            padding: const EdgeInsets.all(16.0), // Padding inside the main card

            child: SingleChildScrollView(
              // Make content scrollable if keyboard appears
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align content to the start
                mainAxisSize: MainAxisSize.min, // Take minimum space
                children: [
                  // App Bar Section
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 40.0,
                    ), // More space below app bar
                    child: Row(children: [
                      ],
                    ),
                  ),
                  // Search Supermarket Section
                  Center(
                    child: Text(
                      'Search Supermarket',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Space below title
                  _buildTextField(
                    'Search Supermarket e.g. Mega',
                    _searchSupermarketController,
                  ),
                  const SizedBox(height: 40), // More space between sections
                  // Enter 6-digit Join Code Section
                  Center(
                    child: Text(
                      'Enter 6-digit Join Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Space below title
                  _buildTextField(
                    'Enter Join Code',
                    _joinCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6, // Limit to 6 digits
                  ),
                  const SizedBox(height: 40), // Space before button
                  // Verify Button
                  SizedBox(
                    width: double.infinity, // Button takes full width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const StaffSignupPage(role: '');
                            },
                          ),
                        );

                        print(
                          'Supermarket: ${_searchSupermarketController.text}',
                        );
                        print('Join Code: ${_joinCodeController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF4CAF50,
                        ), // Green button color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ), // Rounded corners
                        ),
                        elevation: 1, // Add a subtle shadow
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a styled text input field
  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        border: Border.all(color: Colors.grey[300]!), // Light border
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength, // Set max length if provided
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none, // No border for the text field itself
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
          counterText: '', // Hide the default character counter
        ),
      ),
    );
  }
}
