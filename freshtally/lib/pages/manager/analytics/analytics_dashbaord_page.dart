import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // Ensure this import is correct and fl_chart is updated
import 'package:intl/intl.dart';

// Data models for chart data
class SalesDataPoint {
  final DateTime date;
  final double revenue;
  SalesDataPoint(this.date, this.revenue);
}

class ExpiryCategory {
  final String category;
  final double estimatedLoss;
  final Color color;
  ExpiryCategory(this.category, this.estimatedLoss, this.color);
}

class AnalyticsDashboardPage extends StatefulWidget {
  final String supermarketId;

  const AnalyticsDashboardPage({super.key, required this.supermarketId});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  bool _isLoading = true;
  String? _errorMessage;

  List<SalesDataPoint> _dailySalesData = [];
  List<ExpiryCategory> _expiryLossData = [];

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  // Helper to show snackbar messages
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

  // Main function to fetch all analytics data
  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.supermarketId.isEmpty) {
      setState(() {
        _errorMessage = 'Supermarket ID is missing. Cannot load analytics.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch POS Transactions for Sales Rate Chart
      // Changed limit from 365 to 90 to reduce data processing and memory usage for the chart.
      // For more detailed historical data, consider server-side aggregation or pagination.
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('pos_transactions')
          .orderBy('transaction_timestamp', descending: true)
          .limit(90) // **Adjusted limit to reduce memory usage**
          .get();
      _dailySalesData = _processSalesData(transactionsSnapshot.docs);

      // Fetch Products for Expiry Loss Chart
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('products')
          .get();
      _expiryLossData = _processExpiryLossData(productsSnapshot.docs);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching analytics data: $e');
      setState(() {
        _errorMessage = 'Failed to load analytics data: ${e.toString()}';
        _isLoading = false;
      });
      _showSnackBar('Failed to load analytics data.', isError: true);
    }
  }

  // Processes POS transactions to aggregate daily sales revenue
  List<SalesDataPoint> _processSalesData(List<QueryDocumentSnapshot> docs) {
    final dailyRevenue = <DateTime, double>{};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final dateString = data['transactionDate'] as String?;
      final timeString = data['transactionTime'] as String?;
      final lineItemTotal = (data['lineItemTotal'] ?? 0).toDouble();

      if (dateString == null || timeString == null) continue;

      try {
        final fullDateTime = DateFormat(
          'dd-MM-yyyy HH:mm:ss',
        ).parse('$dateString $timeString');

        // Normalize to just the date
        final dateOnly = DateTime(
          fullDateTime.year,
          fullDateTime.month,
          fullDateTime.day,
        );

        dailyRevenue.update(
          dateOnly,
          (value) => value + lineItemTotal,
          ifAbsent: () => lineItemTotal,
        );
      } catch (e) {
        debugPrint('Date/time parsing failed for $dateString $timeString: $e');
      }
    }

    final sortedDates = dailyRevenue.keys.toList()..sort();
    return sortedDates
        .map((date) => SalesDataPoint(date, dailyRevenue[date]!))
        .toList();
  }

  // Processes product data to estimate potential loss from expiring items
  List<ExpiryCategory> _processExpiryLossData(
    List<QueryDocumentSnapshot> docs,
  ) {
    double expiredLoss = 0;
    double sevenDaysLoss = 0;
    double thirtyDaysLoss = 0;
    double safeLoss = 0; // Products with no expiry or far expiry

    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final expiryTimestamp =
          data['expiry_date'] as Timestamp?; // Using expiry_date from products
      final stockQuantity = (data['stock_quantity'] ?? 0).toDouble();
      final currentPrice = (data['current_price'] ?? 0).toDouble();

      if (stockQuantity <= 0 || currentPrice <= 0)
        continue; // Skip if no stock or no value

      final potentialLoss = stockQuantity * currentPrice;

      if (expiryTimestamp == null) {
        safeLoss += potentialLoss; // No expiry date, considered 'safe'
        continue;
      }

      final expiryDate = expiryTimestamp.toDate();

      if (expiryDate.isBefore(now)) {
        expiredLoss += potentialLoss;
      } else if (expiryDate.isBefore(sevenDaysFromNow)) {
        sevenDaysLoss += potentialLoss;
      } else if (expiryDate.isBefore(thirtyDaysFromNow)) {
        thirtyDaysLoss += potentialLoss;
      } else {
        safeLoss += potentialLoss; // Expiring more than 30 days out
      }
    }

    // Create ExpiryCategory objects for the Pie Chart
    return [
          ExpiryCategory('Expired', expiredLoss, Colors.red),
          ExpiryCategory('7 Days', sevenDaysLoss, Colors.orange),
          ExpiryCategory('30 Days', thirtyDaysLoss, Colors.amber),
          ExpiryCategory('Safe / No Expiry', safeLoss, Colors.green),
        ]
        .where((category) => category.estimatedLoss > 0)
        .toList(); // Only show categories with actual loss
  }

  @override
  Widget build(BuildContext context) {
    if (widget.supermarketId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Supermarket ID is required to view analytics.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchAnalyticsData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Sales Rate Chart ---
                  const Text(
                    'Sales Rate (Last 30 Days)', // Update text to reflect the new limit
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _dailySalesData.isEmpty
                      ? const Center(
                          heightFactor: 3,
                          child: Text('No sales data available for charts.'),
                        )
                      : Container(
                          height: 250,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: _dailySalesData.length > 7
                                        ? 7
                                        : 1, // Show weekly or daily for smaller sets
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= _dailySalesData.length)
                                        return const Text('');
                                      final date = _dailySalesData[index].date;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          DateFormat('MMM d').format(date),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        'UGX ${value.toInt()}',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: const Color(0xff37434d),
                                  width: 1,
                                ),
                              ),
                              minX: 0,
                              maxX: (_dailySalesData.length - 1).toDouble(),

                              minY: 0,
                              maxY:
                                  (_dailySalesData
                                              .map((e) => e.revenue)
                                              .reduce((a, b) => a > b ? a : b) *
                                          1.2)
                                      .ceilToDouble(), // 20% buffer
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    _dailySalesData.length,
                                    (index) => FlSpot(
                                      index.toDouble(),
                                      _dailySalesData[index].revenue,
                                    ),
                                  ),

                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade400,
                                      Colors.green.shade800,
                                    ],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400.withOpacity(0.3),
                                        Colors.green.shade800.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 40),

                  // --- Expiry Loss Chart ---
                  const Text(
                    'Estimated Expiry Loss',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _expiryLossData.isEmpty
                      ? const Center(
                          heightFactor: 3,
                          child: Text('No expiring product data found.'),
                        )
                      : Container(
                          height: 280, // Increased height for legend
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sections: _expiryLossData.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final data = entry.value;
                                      final isTouched =
                                          index ==
                                          0; // Example: Highlight first slice
                                      final fontSize = isTouched ? 18.0 : 14.0;
                                      final radius = isTouched ? 70.0 : 60.0;
                                      return PieChartSectionData(
                                        color: data.color,
                                        value: data.estimatedLoss,
                                        title: data.estimatedLoss > 0
                                            ? 'UGX ${data.estimatedLoss.toStringAsFixed(0)}'
                                            : '',
                                        radius: radius,
                                        titleStyle: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        badgePositionPercentageOffset: .98,
                                      );
                                    }).toList(),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    // Optional: Add touch interaction
                                    // pieTouchData: PieTouchData(
                                    //   touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    //     setState(() {
                                    //       if (!event.isInterestedForInteractions ||
                                    //           pieTouchResponse == null ||
                                    //           pieTouchResponse.touchedSection == null) {
                                    //         touchedIndex = -1;
                                    //         return;
                                    //       }
                                    //       touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    //     });
                                    //   },
                                    // ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Legend for the Pie Chart
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _expiryLossData.map((data) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          color: data.color,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${data.category}: UGX ${data.estimatedLoss.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
