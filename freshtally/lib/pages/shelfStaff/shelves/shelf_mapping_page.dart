import 'package:flutter/material.dart';

enum ShelfPosition { top, middle, bottom }

class ShelfMappingPage extends StatefulWidget {
  const ShelfMappingPage({super.key});

  @override
  State<ShelfMappingPage> createState() => _ShelfMappingPageState();
}

class _ShelfMappingPageState extends State<ShelfMappingPage> {
  String? _selectedFloor;
  String? _selectedShelfNumber;
  ShelfPosition? _shelfPosition = ShelfPosition.top;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        title: const Text(
          'Shelf Mapping',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shelf Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFloor,
                      hint: const Text(
                        'Select Floor',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black87,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
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
                Container(
                  margin: const EdgeInsets.only(bottom: 24.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedShelfNumber,
                      hint: const Text(
                        'Select Shelf Number',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black87,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
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
                const Text(
                  'Shelf Position:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Column(
                  children: <Widget>[
                    RadioListTile<ShelfPosition>(
                      title: const Text(
                        'Top',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      value: ShelfPosition.top,
                      groupValue: _shelfPosition,
                      onChanged: (ShelfPosition? value) {
                        setState(() {
                          _shelfPosition = value;
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    RadioListTile<ShelfPosition>(
                      title: const Text(
                        'Middle',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      value: ShelfPosition.middle,
                      groupValue: _shelfPosition,
                      onChanged: (ShelfPosition? value) {
                        setState(() {
                          _shelfPosition = value;
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    RadioListTile<ShelfPosition>(
                      title: const Text(
                        'Bottom',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      value: ShelfPosition.bottom,
                      groupValue: _shelfPosition,
                      onChanged: (ShelfPosition? value) {
                        setState(() {
                          _shelfPosition = value;
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Selected Floor: $_selectedFloor');
                      debugPrint(
                        'Selected Shelf Number: $_selectedShelfNumber',
                      );
                      debugPrint('Selected Shelf Position: $_shelfPosition');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Shelf mapping saved!')),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8E6C9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0.1,
                    ),
                    child: const Text(
                      'Assign to Product',
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
