import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync Status UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter', // Assuming Inter font for a modern look
      ),
      home: const SyncStatusPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class SyncStatusPage extends StatelessWidget {
  const SyncStatusPage({super.key});

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
                      // "Sync Status" title
                      const Text(
                        'Sync Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      // Refresh icon
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        onPressed: () {
                          // Handle refresh button press
                          print('Refresh sync status!');
                        },
                      ),
                    ],
                  ),
                ),
                // Last Synced Status Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Light grey background
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Rounded corners
                      border: Border.all(
                        color: Colors.grey[300]!,
                      ), // Light border
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_queue,
                          color: Colors.grey,
                          size: 30,
                        ), // Cloud icon
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Synced:',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'Today at 10:42 AM',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(), // Pushes "Online" and "Sync Now" to the right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Sync Now Button
                            ElevatedButton(
                              onPressed: () {
                                print('Sync Now pressed!');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF4CAF50,
                                ), // Green
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 1,
                                minimumSize: Size
                                    .zero, // Remove minimum size constraints
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, // Shrink tap target
                              ),
                              child: const Text(
                                'Sync Now',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space below sync status card
                // Unsynced Entries Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Light grey background
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unsynced Entries',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // List of unsynced items
                        _buildUnsyncedItem(
                          'Product: "Rice (12kg)" → Not yet uploaded',
                        ),
                        _buildUnsyncedItem(
                          'Batch: "Batch #294" → Failed to sync',
                        ),
                        _buildUnsyncedItem(
                          'Shelf Map: Floor 1, Shelf 4 → Queued',
                        ),
                        _buildUnsyncedItem('Expiry Update: "Milk" → Pending'),
                      ],
                    ),
                  ),
                ),
                const Spacer(), // Pushes the status buttons to the bottom
                // Bottom Status Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // All items synced successfully! button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[600], // Dark grey background
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Text(
                          'All items synced successfully!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Space between buttons
                      // 3 items failed to sync. RETRY button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[600], // Dark grey background
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '3 items failed to sync.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // RETRY button
                            ElevatedButton(
                              onPressed: () {
                                print('RETRY pressed!');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF4CAF50,
                                ), // Green
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 1,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'RETRY',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // Helper method to build an unsynced item with a red info icon
  Widget _buildUnsyncedItem(String text) {
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
          const SizedBox(width: 8),
          Expanded(
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
