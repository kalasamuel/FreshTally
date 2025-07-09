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

  void _showSyncResultSnackbar(
    BuildContext context, {
    required bool success,
    int failedCount = 0,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[90],
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                success
                    ? 'All items synced successfully!'
                    : '$failedCount item${failedCount > 1 ? 's' : ''} failed to sync.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (!success)
              TextButton(
                onPressed: () {
                  // Retry logic here
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  print('RETRY pressed!');
                },
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                // Simulate sync result
                                bool syncSuccess =
                                    false; // Change to true to test success
                                int failedCount = 3;
                                _showSyncResultSnackbar(
                                  context,
                                  success: syncSuccess,
                                  failedCount: failedCount,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 1,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
