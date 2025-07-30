import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SmartShelfSuggestionsPage extends StatelessWidget {
  final String supermarketId;

  const SmartShelfSuggestionsPage({super.key, required this.supermarketId});

  // Fetches products and group by category, then compute suggested shelf addresses
  Future<Map<String, Map<String, dynamic>>> _fetchSuggestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('supermarketId', isEqualTo: supermarketId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {};
      }

      // Group products by category
      final Map<String, List<Map<String, dynamic>>> categoryGroups = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID for reference
        final category = data['category']?.toString() ?? 'Uncategorized';
        if (!categoryGroups.containsKey(category)) {
          categoryGroups[category] = [];
        }
        categoryGroups[category]!.add(data);
      }

      // Compute most common shelf address for each category
      final Map<String, Map<String, dynamic>> suggestions = {};
      for (var category in categoryGroups.keys) {
        final products = categoryGroups[category]!;
        final locationCounts = <String, int>{};
        final locationDetails = <String, Map<String, dynamic>>{};

        int assignedProducts = 0;
        int unassignedProducts = 0;

        for (var product in products) {
          final location = product['location'] as Map<String, dynamic>?;
          if (location == null ||
              location['floor'] == null ||
              location['shelf'] == null ||
              location['position'] == null) {
            unassignedProducts++;
            continue;
          }

          assignedProducts++;
          final floor = location['floor']?.toString() ?? 'Unknown';
          final shelf = location['shelf']?.toString() ?? 'Unknown';
          final position = location['position']?.toString() ?? 'Unknown';
          final locationKey = '$floor-$shelf-$position';

          locationCounts[locationKey] = (locationCounts[locationKey] ?? 0) + 1;
          locationDetails[locationKey] = {
            'floor': floor,
            'shelf': shelf,
            'position': position,
          };
        }

        // Find the most common location
        String? suggestedLocation;
        int maxCount = 0;
        locationCounts.forEach((key, count) {
          if (count > maxCount) {
            maxCount = count;
            suggestedLocation = key;
          }
        });

        // Calculate confidence percentage
        double confidence = 0.0;
        if (assignedProducts > 0 && maxCount > 0) {
          confidence = (maxCount / assignedProducts) * 100;
        }

        if (suggestedLocation != null &&
            locationDetails.containsKey(suggestedLocation)) {
          final details = locationDetails[suggestedLocation]!;
          suggestions[category] = {
            'floor': details['floor'],
            'shelf': details['shelf'],
            'position': details['position'],
            'productCount': products.length,
            'assignedProducts': assignedProducts,
            'unassignedProducts': unassignedProducts,
            'confidence': confidence,
            'hasValidSuggestion': true,
          };
        } else {
          suggestions[category] = {
            'floor': 'Not assigned',
            'shelf': 'Not assigned',
            'position': 'Not assigned',
            'productCount': products.length,
            'assignedProducts': assignedProducts,
            'unassignedProducts': unassignedProducts,
            'confidence': 0.0,
            'hasValidSuggestion': false,
          };
        }
      }

      return suggestions;
    } catch (e) {
      throw Exception('Failed to fetch suggestions: $e');
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceText(double confidence) {
    if (confidence >= 80) return 'High';
    if (confidence >= 60) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        title: const Text(
          'Smart Shelf Suggestions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info banner
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2196F3), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI-powered suggestions based on product placement patterns',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Suggestions list
            Expanded(
              child: FutureBuilder<Map<String, Map<String, dynamic>>>(
                future: _fetchSuggestions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF4CAF50)),
                          SizedBox(height: 16),
                          Text(
                            'Analyzing product placement patterns...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading suggestions',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add products to see smart suggestions',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final suggestions = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 0,
                    ),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final category = suggestions.keys.elementAt(index);
                      final suggestion = suggestions[category]!;
                      final hasValidSuggestion =
                          suggestion['hasValidSuggestion'] as bool;
                      final confidence = suggestion['confidence'] as double;

                      return Card(
                        elevation: 0.1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: hasValidSuggestion
                            ? const Color(0xFFF1F8E9)
                            : const Color(0xFFFFF3E0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category header with confidence indicator
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (hasValidSuggestion)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getConfidenceColor(confidence),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_getConfidenceText(confidence)} (${confidence.toStringAsFixed(0)}%)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Suggestion details
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasValidSuggestion
                                          ? 'Recommended Shelf Address:'
                                          : 'No Clear Pattern Found:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: hasValidSuggestion
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Floor: ${suggestion['floor']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.shelves,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Shelf: ${suggestion['shelf']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.place,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Position: ${suggestion['position']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Statistics
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatChip(
                                    'Total Products',
                                    suggestion['productCount'].toString(),
                                    Colors.blue,
                                  ),
                                  _buildStatChip(
                                    'Assigned',
                                    suggestion['assignedProducts'].toString(),
                                    Colors.green,
                                  ),
                                  _buildStatChip(
                                    'Unassigned',
                                    suggestion['unassignedProducts'].toString(),
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
