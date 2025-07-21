// // expiry_loss_chart.dart
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'data.dart'; // Import your data models and simulated data

// class ExpiryLossVisualization extends StatefulWidget {
//   const ExpiryLossVisualization({super.key});

//   @override
//   State<ExpiryLossVisualization> createState() =>
//       _ExpiryLossVisualizationState();
// }

// class _ExpiryLossVisualizationState extends State<ExpiryLossVisualization> {
//   late Map<String, double> monthlyLossData;
//   double totalOverallLoss = 0.0;
//   final NumberFormat currencyFormat = NumberFormat.currency(
//     symbol: '\$',
//     decimalDigits: 2,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _processExpiryData();
//   }

//   void _processExpiryData() {
//     monthlyLossData = {};
//     totalOverallLoss = 0.0;

//     for (var lossItem in simulatedExpiredLossData) {
//       final String monthYear = DateFormat(
//         'MMM yyyy',
//       ).format(lossItem.expiryDate);
//       monthlyLossData.update(
//         monthYear,
//         (value) => value + lossItem.totalLoss,
//         ifAbsent: () => lossItem.totalLoss,
//       );
//       totalOverallLoss += lossItem.totalLoss;
//     }

//     // Sort months for consistent chart display (e.g., Jan, Feb, Mar...)
//     final List<MapEntry<String, double>> sortedEntries = monthlyLossData.entries
//         .toList();
//     sortedEntries.sort((a, b) {
//       final DateTime dateA = DateFormat('MMM yyyy').parse(a.key);
//       final DateTime dateB = DateFormat('MMM yyyy').parse(b.key);
//       return dateA.compareTo(dateB);
//     });
//     monthlyLossData = Map.fromEntries(sortedEntries);
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<BarChartGroupData> barGroups = [];
//     double maxY = 0;
//     int xIndex = 0;

//     for (var entry in monthlyLossData.entries) {
//       barGroups.add(
//         BarChartGroupData(
//           x: xIndex,
//           barRods: [
//             BarChartRodData(
//               toY: entry.value,
//               color: Colors.redAccent,
//               width: 16,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ],
//         ),
//       );
//       if (entry.value > maxY) {
//         maxY = entry.value;
//       }
//       xIndex++;
//     }

//     // Add some padding to maxY for better chart display
//     maxY = (maxY * 1.2).ceilToDouble();

//     return Card(
//       margin: const EdgeInsets.all(16.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Loss Due to Product Expiry',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Total Overall Loss: ${currencyFormat.format(totalOverallLoss)}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.red,
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (barGroups.isEmpty)
//               const Center(
//                 child: Text('No expiry loss data available for charting.'),
//               )
//             else
//               AspectRatio(
//                 aspectRatio: 1.6,
//                 child: BarChart(
//                   BarChartData(
//                     alignment: BarChartAlignment.spaceAround,
//                     maxY: maxY,
//                     barTouchData: BarTouchData(
//                       enabled: true,
//                       touchTooltipData: BarTouchTooltipData(
//                         tooltipBgColor: Colors.blueGrey,
//                         tooltipHorizontalAlignment: FLHorizontalAlignment.right,
//                         getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                           final String month = monthlyLossData.keys.elementAt(
//                             groupIndex,
//                           );
//                           return BarTooltipItem(
//                             '$month\n',
//                             const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                             children: <TextSpan>[
//                               TextSpan(
//                                 text: currencyFormat.format(rod.toY),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                     titlesData: FlTitlesData(
//                       show: true,
//                       rightTitles: const AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       topTitles: const AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             return SideTitleWidget(
//                               axisSide: meta.axisSide,
//                               space: 4.0,
//                               child: Text(
//                                 monthlyLossData.keys
//                                     .elementAt(value.toInt())
//                                     .split(' ')[0], // Show month abbreviation
//                                 style: const TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           interval: maxY / 4, // Roughly 4 intervals
//                           getTitlesWidget: (value, meta) {
//                             return Text(
//                               currencyFormat.format(value),
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 10,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     borderData: FlBorderData(show: false),
//                     barGroups: barGroups,
//                     gridData: const FlGridData(show: false),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
