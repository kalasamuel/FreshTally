import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SyncStatusPage extends StatefulWidget {
  final String supermarketId;

  const SyncStatusPage({super.key, required this.supermarketId});

  @override
  State<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime? _lastSyncedAt;
  bool _isSyncing = false;
  String _networkStatus = 'Checking...'; // Placeholder for network status

  @override
  void initState() {
    super.initState();
    _fetchLastSyncedTime();
    // In a real app, you'd integrate a connectivity package here
    // For this example, we'll assume online if Firestore works.
    _networkStatus = 'Online';
  }

  // Fetches the last successful sync timestamp from Firestore.
  Future<void> _fetchLastSyncedTime() async {
    try {
      final doc = await _firestore
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('syncStatus')
          .doc('metadata')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('lastSyncedAt')) {
          setState(() {
            _lastSyncedAt = (data['lastSyncedAt'] as Timestamp).toDate();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching last synced time: $e');
      if (mounted) {
        _showSnackBar('Failed to load last sync time.', isError: true);
      }
    }
  }

  // Updates the last successful sync timestamp in Firestore.
  Future<void> _updateLastSyncedTime() async {
    try {
      await _firestore
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('syncStatus')
          .doc('metadata')
          .set({
            'lastSyncedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      // Re-fetch to get the exact server timestamp
      _fetchLastSyncedTime();
    } catch (e) {
      debugPrint('Error updating last synced time: $e');
    }
  }

  // Simulates the sync process. In a real app, this would involve
  // uploading local changes and downloading server updates.
  Future<void> _syncNow() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    int successfulSyncs = 0;
    int failedSyncs = 0;

    try {
      // 1. Fetch unsynced items for this supermarket
      final unsyncedSnapshot = await _firestore
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('unsyncedChanges')
          .get();

      if (unsyncedSnapshot.docs.isEmpty) {
        if (mounted) {
          _showSnackBar('No pending items to sync. Everything is up to date!');
        }
        await _updateLastSyncedTime(); // Update last synced time even if nothing to sync
        return;
      }

      // 2. Process each unsynced item
      for (final doc in unsyncedSnapshot.docs) {
        final data = doc.data();
        final String type = data['type'] ?? 'unknown';
        final Map<String, dynamic> changeData = data['data'] ?? {};
        final String? targetCollection = data['targetCollection'];
        final String? targetDocId = data['targetDocId']; // For updates/deletes

        try {
          // Simulate network delay
          await Future.delayed(const Duration(milliseconds: 500));

          // Perform actual Firestore operations based on the 'type'
          if (targetCollection != null) {
            final collectionRef = _firestore.collection(targetCollection);

            switch (type) {
              case 'add':
                await collectionRef.add(changeData);
                break;
              case 'update':
                if (targetDocId != null) {
                  await collectionRef.doc(targetDocId).update(changeData);
                } else {
                  throw Exception(
                    'Target document ID missing for update operation.',
                  );
                }
                break;
              case 'delete':
                if (targetDocId != null) {
                  await collectionRef.doc(targetDocId).delete();
                } else {
                  throw Exception(
                    'Target document ID missing for delete operation.',
                  );
                }
                break;
              default:
                debugPrint('Unhandled unsynced change type: $type');
                throw Exception('Unhandled sync operation type.');
            }
          } else {
            throw Exception('Target collection missing for unsynced change.');
          }

          // If successful, delete the unsynced change record
          await doc.reference.delete();
          successfulSyncs++;
        } catch (itemError) {
          failedSyncs++;
          debugPrint('Failed to sync item ${doc.id}: $itemError');
          // Update status of failed item in unsyncedChanges for manager review
          await doc.reference.update({
            'status': 'failed',
            'errorMessage': itemError.toString(),
          });
        }
      }

      // 3. Update last synced time after processing all items
      await _updateLastSyncedTime();

      // 4. Show result to user
      if (mounted) {
        if (failedSyncs == 0) {
          _showSyncResultSnackbar(success: true);
        } else {
          _showSyncResultSnackbar(success: false, failedCount: failedSyncs);
        }
      }
    } catch (e) {
      debugPrint('Overall sync process failed: $e');
      if (mounted) {
        _showSnackBar(
          'An error occurred during sync: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  // Helper to show SnackBar messages
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // SnackBar for sync results with a RETRY option
  void _showSyncResultSnackbar({required bool success, int failedCount = 0}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[900],
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
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _syncNow(); // Retry the sync process
                },
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4CAF50),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        title: const Text(
          'Sync Status',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  'Sync Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0.1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: const Color(0xFFF1F8E9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_queue,
                          color: Colors.black87,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Synced:',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _lastSyncedAt != null
                                  ? DateFormat(
                                      'MMM d, yyyy HH:mm',
                                    ).format(_lastSyncedAt!)
                                  : 'Never',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _networkStatus,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _networkStatus == 'Online'
                                    ? const Color(0xFF4CAF50)
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: _isSyncing
                                    ? null
                                    : _syncNow, // Disable when syncing
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC8E6C9),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0.1,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: _isSyncing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black87,
                                        ),
                                      )
                                    : const Text(
                                        'Sync Now',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
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
                const SizedBox(height: 20),
                Card(
                  elevation: 0.1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: const Color(0xFFF5F6FA),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                        // StreamBuilder to listen for real-time unsynced changes
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('supermarkets')
                              .doc(widget.supermarketId)
                              .collection('unsyncedChanges')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading unsynced items: ${snapshot.error}',
                                ),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'No unsynced items. All good!',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final doc = snapshot.data!.docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final String description =
                                    data['description'] ?? 'No description';
                                final String status =
                                    data['status'] ?? 'pending';
                                final String errorMessage =
                                    data['errorMessage'] ?? '';

                                IconData itemIcon;
                                Color itemIconColor;
                                String displayText = description;

                                if (status == 'failed') {
                                  itemIcon = Icons.error;
                                  itemIconColor = Colors.red;
                                  displayText =
                                      '$description → Failed: $errorMessage';
                                } else {
                                  itemIcon = Icons.info_outline;
                                  itemIconColor = Colors.orange;
                                }

                                return _buildUnsyncedItem(
                                  displayText,
                                  itemIcon,
                                  itemIconColor,
                                );
                              },
                            );
                          },
                        ),
                      ],
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

  Widget _buildUnsyncedItem(String text, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
