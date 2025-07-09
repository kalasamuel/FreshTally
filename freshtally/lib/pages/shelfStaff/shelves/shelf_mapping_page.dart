import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelf Mapping UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const ShelfMappingPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

enum ShelfPosition { top, middle, bottom }

class ShelfMappingPage extends StatefulWidget {
  const ShelfMappingPage({super.key});

  @override
  State<ShelfMappingPage> createState() => _ShelfMappingPageState();
}

class _ShelfMappingPageState extends State<ShelfMappingPage> {
  // Currently selected floor for the dropdown
  String? _selectedFloor;
  // Currently selected shelf number for the dropdown
  String? _selectedShelfNumber;
  // Currently selected shelf position for the radio buttons
  ShelfPosition? _shelfPosition = ShelfPosition.top; // Default to Top

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Light green background
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(
              20.0,
            ), // Margin around the main content area
            padding: const EdgeInsets.all(16.0), // Padding inside the main card
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the start
              children: [
                // App Bar Section
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
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
                      // "Shelf Mapping" title
                      const Text(
                        'Shelf Mapping',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Floor Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true, // Make dropdown take full width
                      value: _selectedFloor,
                      hint: const Text(
                        'Floor',
                        style: TextStyle(color: Colors.grey),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFloor = newValue;
                        });
                      },
                      items:
                          <String>[
                            'Floor 1',
                            'Floor 2',
                            'Floor 3',
                            'Floor 4',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                // Shelf Number Dropdown
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 24.0,
                  ), // More space below this dropdown
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedShelfNumber,
                      hint: const Text(
                        'Shelf Number',
                        style: TextStyle(color: Colors.grey),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedShelfNumber = newValue;
                        });
                      },
                      items:
                          <String>[
                            'Shelf 1',
                            'Shelf 2',
                            'Shelf 3',
                            'Shelf 4',
                            'Shelf 5',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                // Shelf Position Label
                const Text(
                  'Shelf Position:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Shelf Position Radio Buttons
                Column(
                  children: <Widget>[
                    // Top position radio button
                    RadioListTile<ShelfPosition>(
                      title: const Text('Top'),
                      value: ShelfPosition.top,
                      groupValue: _shelfPosition,
                      onChanged: (ShelfPosition? value) {
                        setState(() {
                          _shelfPosition = value;
                        });
                      },
                      activeColor: Colors.green, // Green dot when selected
                      controlAffinity: ListTileControlAffinity
                          .leading, // Radio button on the left
                    ),
                    // Middle position radio button
                    RadioListTile<ShelfPosition>(
                      title: const Text('Middle'),
                      value: ShelfPosition.middle,
                      groupValue: _shelfPosition,
                      onChanged: (ShelfPosition? value) {
                        setState(() {
                          _shelfPosition = value;
                        });
                      },
                      activeColor: Colors.green,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    // Bottom position radio button
                    RadioListTile<ShelfPosition>(
                      title: const Text('Bottom'),
                      value: ShelfPosition.bottom,
                      groupValue: _shelfPosition,
                      onChanged: (ShelfPosition? value) {
                        setState(() {
                          _shelfPosition = value;
                        });
                      },
                      activeColor: Colors.green,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
                const Spacer(), // Pushes the button to the bottom
                // Assign to Product Button
                SizedBox(
                  width: double.infinity, // Button takes full width
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      print('Assign to Product pressed!');
                      print('Selected Floor: $_selectedFloor');
                      print('Selected Shelf Number: $_selectedShelfNumber');
                      print('Selected Shelf Position: $_shelfPosition');
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
                      'Assign to Product',
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
    );
  }
}
