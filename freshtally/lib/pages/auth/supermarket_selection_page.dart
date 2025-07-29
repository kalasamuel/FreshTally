import 'package:Freshtally/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Freshtally/pages/customer/home/customer_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for current user ID

class SupermarketSelectionPage extends StatefulWidget {
  final String customerId;
  final List<String> associatedSupermarketIds;
  final String? initialMessage;

  const SupermarketSelectionPage({
    super.key,
    required this.customerId,
    this.associatedSupermarketIds = const [],
    this.initialMessage,
  });

  @override
  State<SupermarketSelectionPage> createState() =>
      _SupermarketSelectionPageState();
}

class _SupermarketSelectionPageState extends State<SupermarketSelectionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _errorMessage;

  // Fetches details for supermarkets the customer is already associated with
  Future<List<Map<String, dynamic>>>
  _fetchAssociatedSupermarketsDetails() async {
    if (widget.associatedSupermarketIds.isEmpty) {
      return [];
    }
    final List<Map<String, dynamic>> supermarkets = [];
    // Use a Firestore query with 'whereIn' for multiple IDs if the list is not too large (max 10)
    // For more than 10, you'd need to break it into multiple queries or adjust data model.
    if (widget.associatedSupermarketIds.isNotEmpty) {
      try {
        final querySnapshot = await _firestore
            .collection('supermarkets')
            .where(
              FieldPath.documentId,
              whereIn: widget.associatedSupermarketIds,
            )
            .get();
        for (var doc in querySnapshot.docs) {
          supermarkets.add({'id': doc.id, ...doc.data()});
        }
      } catch (e) {
        debugPrint('Error fetching associated supermarkets: $e');
        if (mounted) {
          _showSnackBar(
            'Error loading your linked supermarkets.',
            isError: true,
          );
        }
      }
    }
    return supermarkets;
  }

  // Fetches details for ALL available supermarkets
  Future<List<Map<String, dynamic>>> _fetchAllSupermarkets() async {
    final List<Map<String, dynamic>> allSupermarkets = [];
    try {
      final querySnapshot = await _firestore.collection('supermarkets').get();
      for (var doc in querySnapshot.docs) {
        allSupermarkets.add({'id': doc.id, ...doc.data()});
      }
    } catch (e) {
      debugPrint('Error fetching all supermarkets: $e');
      if (mounted) {
        _showSnackBar(
          'Error loading all available supermarkets.',
          isError: true,
        );
      }
    }
    return allSupermarkets;
  }

  // Handles selecting a supermarket, adding it to associated list if new, then navigating
  Future<void> _selectAndNavigateToSupermarket(String supermarketId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if the supermarket is already associated
      if (!widget.associatedSupermarketIds.contains(supermarketId)) {
        // If not, add it to the customer's associatedSupermarketIds
        await _firestore.collection('customers').doc(widget.customerId).update({
          'associatedSupermarketIds': FieldValue.arrayUnion([supermarketId]),
        });
        debugPrint(
          'Customer ${widget.customerId} associated with new supermarket: $supermarketId',
        );
      }

      // Fetch supermarket details for navigation
      final supermarketDoc = await _firestore
          .collection('supermarkets')
          .doc(supermarketId)
          .get();
      String supermarketName = 'Unknown';
      String location = 'Unknown';
      if (supermarketDoc.exists) {
        final supermarketData = supermarketDoc.data();
        supermarketName = supermarketData?['name'] as String? ?? 'Unknown';
        location = supermarketData?['location'] as String? ?? 'Unknown';
      }

      if (!mounted) return;
      _showSnackBar('Accessing $supermarketName...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerHomePage(
            supermarketName: supermarketName,
            location: location,
            supermarketId: supermarketId,
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to access supermarket: ${e.toString()}';
        debugPrint('Select Supermarket Error: $e');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Supermarket'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.initialMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    widget.initialMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Section for already associated supermarkets
              const Text(
                'Your Linked Supermarkets:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAssociatedSupermarketsDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading linked supermarkets: ${snapshot.error}',
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No supermarkets currently linked to your account.',
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final supermarket = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.store, color: Colors.green),
                          title: Text(
                            supermarket['name'] ?? 'Unnamed Supermarket',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            supermarket['location'] ?? 'Unknown Location',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: _isLoading
                              ? null
                              : () => _selectAndNavigateToSupermarket(
                                  supermarket['id'],
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'All Available Supermarkets:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAllSupermarkets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading all supermarkets: ${snapshot.error}',
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No other supermarkets available at this time.',
                        ),
                      ),
                    );
                  }

                  // Filter out supermarkets already associated with the customer
                  final unassociatedSupermarkets = snapshot.data!
                      .where(
                        (supermarket) => !widget.associatedSupermarketIds
                            .contains(supermarket['id']),
                      )
                      .toList();

                  if (unassociatedSupermarkets.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'You are already linked to all available supermarkets.',
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: unassociatedSupermarkets.length,
                    itemBuilder: (context, index) {
                      final supermarket = unassociatedSupermarkets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.storefront,
                            color: Colors.blueGrey,
                          ),
                          title: Text(
                            supermarket['name'] ?? 'Unnamed Supermarket',
                          ),
                          subtitle: Text(
                            supermarket['location'] ?? 'Unknown Location',
                          ),
                          trailing: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.blue,
                          ),
                          onTap: _isLoading
                              ? null
                              : () => _selectAndNavigateToSupermarket(
                                  supermarket['id'],
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Optional: Add a logout button for convenience
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Logout', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
