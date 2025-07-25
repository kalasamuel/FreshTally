// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// class AnalyticsDashboard extends StatefulWidget {
//   const AnalyticsDashboard({super.key});

//   @override
//   State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
// }

// class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
//   final FirestoreService _firestoreService = FirestoreService();
//   double _totalLossFromExpiry = 0.0;
//   bool _isLoadingExpiry = true;

//   Map<String, double> _productSalesRate = {};
//   bool _isLoadingSaleRate = true;

//   @override
//   void initState() {
//     super.initState();
//     _calculateLossFromExpiry();
//     _calculateRateOfSale();
//   }

//   Future<void> _calculateLossFromExpiry() async {
//     setState(() {
//       _isLoadingExpiry = true;
//     });

//     try {
//       final List<Batch> batches = await _firestoreService.getBatches().first;
//       final List<TransactionItem> transactions = await _firestoreService
//           .getTransactionItems()
//           .first;
//       final List<Product> products = await _firestoreService
//           .getProducts()
//           .first; // For product names

//       // Map ProductID to ProductName
//       final Map<String, String> productNames = {
//         for (var p in products) p.id: p.name,
//       };

//       // Calculate total quantity sold per ProductID
//       final Map<String, double> soldQuantities = transactions.groupFoldBy(
//         (item) => item.productId,
//         (previous, item) => (previous ?? 0.0) + item.quantity,
//       );

//       double currentLoss = 0.0;
//       final DateTime now = DateTime.now();
//       List<String> expiredProductsDetails = [];

//       for (var batch in batches) {
//         if (batch.expiryDate.isBefore(now)) {
//           // This batch has expired
//           double initialBatchQuantity = batch.initialQuantity;
//           double soldFromThisProduct = soldQuantities[batch.productId] ?? 0.0;

//           // Remaining stock for this product across all batches (simplified)
//           // For a precise calculation per batch, you'd need to track sales per batch,
//           // which is more complex (e.g., FIFO/LIFO or batch-specific transaction linkage).
//           // Here, we're assuming any sale of ProductID X reduces overall stock of ProductID X.
//           double remainingStock = initialBatchQuantity - soldFromThisProduct;

//           if (remainingStock > 0) {
//             double batchLoss = remainingStock * batch.costPrice;
//             currentLoss += batchLoss;
//             expiredProductsDetails.add(
//               '${productNames[batch.productId] ?? 'Unknown Product ID: ${batch.productId}'} (Batch ${batch.id}): '
//               '${remainingStock.toStringAsFixed(2)} units expired, costing ${NumberFormat.currency(symbol: 'UGX ').format(batchLoss)}',
//             );
//           }
//         }
//       }

//       setState(() {
//         _totalLossFromExpiry = currentLoss;
//         _isLoadingExpiry = false;
//         // You could also display expiredProductsDetails in the UI
//       });
//       print('Expired Product Details:');
//       expiredProductsDetails.forEach(print);
//     } catch (e) {
//       print('Error calculating loss from expiry: $e');
//       setState(() {
//         _isLoadingExpiry = false;
//         _totalLossFromExpiry = 0.0;
//       });
//     }
//   }

//   Future<void> _calculateRateOfSale() async {
//     setState(() {
//       _isLoadingSaleRate = true;
//     });

//     try {
//       final List<TransactionItem> transactions = await _firestoreService
//           .getTransactionItems()
//           .first;
//       final List<Product> products = await _firestoreService
//           .getProducts()
//           .first; // For product names

//       // Map ProductID to ProductName
//       final Map<String, String> productNames = {
//         for (var p in products) p.id: p.name,
//       };

//       // Group sales by Product ID and sum quantities
//       Map<String, double> salesByProductId = {};
//       for (var item in transactions) {
//         salesByProductId.update(
//           item.productId,
//           (value) => value + item.quantity,
//           ifAbsent: () => item.quantity,
//         );
//       }

//       // Prepare data for visualization, mapping product IDs to their names
//       Map<String, double> rates = {};
//       salesByProductId.forEach((productId, totalQuantity) {
//         rates[productNames[productId] ?? 'Unknown Product ID: $productId'] =
//             totalQuantity;
//       });

//       // Sort by sales quantity descending to get top sellers
//       _productSalesRate = Map.fromEntries(
//         rates.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
//       );

//       setState(() {
//         _isLoadingSaleRate = false;
//       });
//     } catch (e) {
//       print('Error calculating rate of sale: $e');
//       setState(() {
//         _isLoadingSaleRate = false;
//         _productSalesRate = {};
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormatter = NumberFormat.currency(
//       symbol: 'UGX ',
//       decimalDigits: 2,
//     );

//     return Scaffold(
//       appBar: AppBar(title: const Text('Supermarket Analytics')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Loss Due to Expired Products Section ---
//             Text(
//               'Loss Due to Expired Products',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 10),
//             _isLoadingExpiry
//                 ? const Center(child: CircularProgressIndicator())
//                 : Card(
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Estimated Total Loss:',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             currencyFormatter.format(_totalLossFromExpiry),
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: _totalLossFromExpiry > 0
//                                   ? Colors.red
//                                   : Colors.green,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           const Text(
//                             'Note: This calculation considers batches with past expiry dates. '
//                             'It subtracts quantities sold (from transactions) from the batch\'s '
//                             '`InitialQuantity` to estimate remaining expired stock. '
//                             'Requires "batches" and "products" collections in Firestore.',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontStyle: FontStyle.italic,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//             const Divider(height: 40),

//             // --- Rate of Sale Visualization Section ---
//             Text(
//               'Rate of Sale of Products (Top 10 by Quantity Sold)',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 10),
//             _isLoadingSaleRate
//                 ? const Center(child: CircularProgressIndicator())
//                 : _productSalesRate.isEmpty
//                 ? const Text('No sales data available for visualization.')
//                 : SizedBox(
//                     height: 300,
//                     child: Card(
//                       elevation: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: BarChart(
//                           BarChartData(
//                             alignment: BarChartAlignment.spaceAround,
//                             // Adjust maxY to be slightly above the highest value
//                             maxY: _productSalesRate.values.isNotEmpty
//                                 ? _productSalesRate.values.reduce(
//                                         (a, b) => a > b ? a : b,
//                                       ) *
//                                       1.2
//                                 : 100, // Default if no data
//                             barTouchData: BarTouchData(enabled: false),
//                             titlesData: FlTitlesData(
//                               show: true,
//                               bottomTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   getTitlesWidget: (value, meta) {
//                                     final index = value.toInt();
//                                     if (index < _productSalesRate.length) {
//                                       final productName = _productSalesRate.keys
//                                           .elementAt(index);
//                                       return SideTitleWidget(
//                                         axisSide: meta.axisSide,
//                                         angle:
//                                             -45 *
//                                             (3.1415926535 / 180), // Rotate text
//                                         space: 4,
//                                         child: Text(
//                                           productName.length > 15
//                                               ? '${productName.substring(0, 12)}...'
//                                               : productName,
//                                           style: const TextStyle(fontSize: 10),
//                                         ),
//                                       );
//                                     }
//                                     return const Text('');
//                                   },
//                                   interval: 1,
//                                   reservedSize:
//                                       70, // Increase space for rotated labels
//                                 ),
//                               ),
//                               leftTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   getTitlesWidget: (value, meta) {
//                                     return Text(
//                                       value.toInt().toString(),
//                                       style: const TextStyle(fontSize: 10),
//                                     );
//                                   },
//                                   interval:
//                                       (_productSalesRate.values.isNotEmpty
//                                               ? _productSalesRate.values.reduce(
//                                                       (a, b) => a > b ? a : b,
//                                                     ) /
//                                                     5
//                                               : 20)
//                                           .roundToDouble(), // Dynamic interval
//                                   reservedSize: 30, // Space for labels
//                                 ),
//                               ),
//                               topTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false),
//                               ),
//                               rightTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false),
//                               ),
//                             ),
//                             borderData: FlBorderData(show: false),
//                             barGroups: _productSalesRate.entries
//                                 .take(10) // Show top 10 products
//                                 .toList()
//                                 .asMap()
//                                 .entries
//                                 .map((entry) {
//                                   int index = entry.key;
//                                   MapEntry<String, double> item = entry.value;
//                                   return BarChartGroupData(
//                                     x: index,
//                                     barRods: [
//                                       BarChartRodData(
//                                         toY: item.value,
//                                         color: Colors.blueAccent,
//                                         width: 15,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ],
//                                     showingTooltipIndicators: [],
//                                   );
//                                 })
//                                 .toList(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//             const SizedBox(height: 20),
//             const Text(
//               'This visualization displays the total quantity sold for the top 10 products within the entire dataset. '
//               'For a dynamic rate over time (e.g., sales per day/week), you would need to filter and aggregate transactions '
//               'based on specific date ranges.',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontStyle: FontStyle.italic,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   }
