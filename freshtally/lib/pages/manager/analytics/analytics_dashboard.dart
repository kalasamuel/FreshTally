import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  late Future<Map<String, ProductSalesData>> _salesDataFuture;

  @override
  void initState() {
    super.initState();
    _salesDataFuture = _fetchSalesData();
  }

  Future<Map<String, ProductSalesData>> _fetchSalesData() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final query = await FirebaseFirestore.instance
        .collection('sales')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .get();

    // Map: productId -> ProductSalesData
    final Map<String, ProductSalesData> salesMap = {};

    for (final doc in query.docs) {
      final data = doc.data();
      final productId = data['productId'] as String?;
      final category = data['category'] as String? ?? 'Unknown';
      final quantity = (data['quantity'] ?? 1) as int;
      final timestamp = (data['timestamp'] as Timestamp).toDate();

      if (productId == null) continue;
      salesMap.putIfAbsent(productId, () => ProductSalesData(productId, category));
      salesMap[productId]!.addSale(timestamp, quantity);
    }

    return salesMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Sales Speed Analytics')),
      body: FutureBuilder<Map<String, ProductSalesData>>(
        future: _salesDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final salesMap = snapshot.data ?? {};
          if (salesMap.isEmpty) {
            return const Center(child: Text('No sales data for the last 7 days.'));
          }

          // Sort products by total sold descending
          final sortedProducts = salesMap.values.toList()
            ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Units Sold per Product (Last 7 Days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: sortedProducts.isNotEmpty
                          ? sortedProducts.first.totalSold * 1.2
                          : 10,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final product = sortedProducts[group.x.toInt()];
                            return BarTooltipItem(
                              '${product.productId}\n${product.category}\n${product.totalSold} sold',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < sortedProducts.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    sortedProducts[index].productId.substring(0, 6),
                                    style: const TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString());
                            },
                            reservedSize: 32,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(sortedProducts.length, (index) {
                        final product = sortedProducts[index];
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: product.totalSold.toDouble(),
                              color: _getColorForCategory(product.category),
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Legend:'),
                Wrap(
                  spacing: 12,
                  children: _buildCategoryLegend(sortedProducts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCategoryLegend(List<ProductSalesData> products) {
    final categories = <String>{};
    for (final p in products) {
      categories.add(p.category);
    }
    return categories.map((cat) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 16, height: 16, color: _getColorForCategory(cat)),
          const SizedBox(width: 4),
          Text(cat, style: const TextStyle(fontSize: 12)),
        ],
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }
}

class ProductSalesData {
  final String productId;
  final String category;
  int totalSold = 0;
  final List<DateTime> saleTimestamps = [];

  ProductSalesData(this.productId, this.category);

  void addSale(DateTime timestamp, int quantity) {
    totalSold += quantity;
    for (int i = 0; i < quantity; i++) {
      saleTimestamps.add(timestamp);
    }
  }
} 