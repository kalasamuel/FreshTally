import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/settings/settings_page.dart';
// Remove the import below as SyncStatusPage is defined in this file
// import 'package:freshtally/pages/storeManager/sync/sync_status_page.dart';

class SyncStatusPage extends StatefulWidget {
  // Change the callback type to accept BuildContext.
  final void Function(BuildContext context)? onSyncNowPressed;

  const SyncStatusPage({
    super.key,
    this.onSyncNowPressed,
    required String supermarketId,
  });

  @override
  State<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage> {
  // Helper method to show a snackbar with sync results.
  void _showSyncResultSnackbar(
    BuildContext context, {
    required bool success,
    int failedCount = 0,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[900], // Dark background for contrast.
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
                  color: Colors.white, // White text for readability.
                ),
              ),
            ),
            if (!success) // Show retry button only if sync failed.
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  // Implement retry logic here.
                  debugPrint('RETRY pressed!');
                },
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4CAF50), // Green color for retry button.
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        duration: const Duration(seconds: 4), // Snackbar visible duration.
        behavior: SnackBarBehavior
            .floating, // Makes the snackbar float above content.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Rounded corners for snackbar.
        margin: const EdgeInsets.all(
          10,
        ), // Margin around the floating snackbar.
      ),
    );
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
          'Sync Status',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true, // Centers the title in the app bar.
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(supermarketId: ''),
                ),
              );
            },
          ),
        ],
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
                // Section Title for "Sync Overview".
                const Text(
                  'Sync Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24), // Space below the section title.
                // Last Synced Status Card
                Card(
                  elevation: 0.1, // Subtle elevation.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ), // Rounded corners.
                  color: const Color(
                    0xFFF1F8E9,
                  ), // Light green background, matching dashboard tiles.
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Internal padding.
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_queue,
                          color: Colors.black87, // Icon color.
                          size: 30,
                        ), // Cloud icon.
                        const SizedBox(
                          width: 12,
                        ), // Space between icon and text.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Synced:',
                              style: TextStyle(
                                color: Colors.black54, // Slightly lighter text.
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'Today at 10:42 AM', // Placeholder for last sync time.
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(), // Pushes "Online" and "Sync Now" to the right.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Online', // Placeholder for connection status.
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(
                                  0xFF4CAF50,
                                ), // Green for online status.
                              ),
                            ),
                            const SizedBox(height: 4), // Small space.
                            // Sync Now Button
                            SizedBox(
                              height:
                                  36, // Adjusted height for a smaller button.
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.onSyncNowPressed != null) {
                                    widget.onSyncNowPressed!(
                                      context,
                                    ); // Pass context here
                                  } else {
                                    // Default behavior if no callback is provided.
                                    bool syncSuccess = false;
                                    int failedCount = 3;
                                    _showSyncResultSnackbar(
                                      context,
                                      success: syncSuccess,
                                      failedCount: failedCount,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFC8E6C9,
                                  ), // Background color matching other buttons.
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ), // Rounded corners.
                                  ),
                                  elevation: 0.1, // Subtle elevation.
                                  minimumSize: Size
                                      .zero, // Allows button to shrink to fit padding.
                                  tapTargetSize: MaterialTapTargetSize
                                      .shrinkWrap, // Reduces tap target size.
                                ),
                                child: const Text(
                                  'Sync Now',
                                  style: TextStyle(
                                    fontSize:
                                        14, // Slightly smaller font for this button.
                                    color: Colors.black87, // Dark text.
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
                const SizedBox(height: 20), // Space below sync status card.
                // Unsynced Entries Section
                Card(
                  elevation: 0.1, // Subtle elevation.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ), // Rounded corners.
                  color: const Color(0xFFF5F6FA), // Light background.
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Internal padding.
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
                        const SizedBox(height: 12), // Space below title.
                        // List of unsynced items.
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
                // No Spacer needed here as there are no elements below the last card.
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build an unsynced item with an info icon.
  Widget _buildUnsyncedItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ), // Vertical padding for each item.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.red, // Red info icon for unsynced items.
            size: 18,
          ),
          const SizedBox(width: 8), // Space between icon and text.
          Expanded(
            // Ensures text wraps if it's too long.
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ), // Darker text for readability.
            ),
          ),
        ],
      ),
    );
  }
}
