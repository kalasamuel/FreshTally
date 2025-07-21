// // sales_rate_chart.dart
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'data.dart'; // Import your data models and simulated data

// class SalesRateVisualization extends StatefulWidget {
//   const SalesRateVisualization({super.key});

//   @override
//   State<SalesRateVisualization> createState() => _SalesRateVisualizationState();
// }

// class _SalesRateVisualizationState extends State<SalesRateVisualization> {
//   late Map<DateTime, int> dailySalesData;
//   double averageDailySalesRate = 0.0;
//   final DateFormat dateFormat = DateFormat('MMM dd');

//   @override
//   void initState() {
//     super.initState();
//     _processSalesData();
//   }

//   void _processSalesData() {
//     dailySalesData = {};
//     int totalUnitsSold = 0;
//     int daysWithSales = 0;

//     // Aggregate sales data by day
//     for (var saleItem in simulatedSalesData) {
//       final DateTime day = DateTime(
//         saleItem.transactionDate.year,
//         saleItem.transactionDate.month,
//         saleItem.transactionDate.day,
//       );
//       dailySalesData.update(
//         day,
//         (value) => value + saleItem.quantitySold,
//         ifAbsent: () => saleItem.quantitySold,
//       );
//     }

//     // Ensure all days in the past 30 days are present, even if 0 sales
//     final DateTime thirtyDaysAgo = now.subtract(
//       const Duration(days: 29),
//     ); // Cover 30 days including today
//     List<DateTime> allDates = [];
//     for (int i = 0; i < 30; i++) {
//       allDates.add(now.subtract(Duration(days: i)));
//     }
//     allDates.sort(
//       (a, b) => a.compareTo(b),
//     ); // Sort ascending for chart plotting

//     Map<DateTime, int> fullDailySalesData = {};
//     for (DateTime date in allDates) {
//       DateTime dayKey = DateTime(date.year, date.month, date.day);
//       int salesForDay = dailySalesData[dayKey] ?? 0;
//       fullDailySalesData[dayKey] = salesForDay;
//       totalUnitsSold += salesForDay;
//       if (salesForDay > 0) {
//         // Only count days with actual sales for average if desired, or all days if average across entire period
//         daysWithSales++;
//       }
//     }
//     dailySalesData = fullDailySalesData; // Use the complete dataset

//     if (dailySalesData.isNotEmpty) {
//       // Calculate average over the 30-day period
//       averageDailySalesRate =
//           totalUnitsSold / 30; // Dividing by total days in the period
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<FlSpot> spots = [];
//     double minY = 0;
//     double maxY = 0;
//     int xIndex = 0;

//     // Get sorted keys to ensure correct x-axis order
//     final List<DateTime> sortedDates = dailySalesData.keys.toList()..sort();

//     for (DateTime date in sortedDates) {
//       final int sales = dailySalesData[date] ?? 0;
//       spots.add(FlSpot(xIndex.toDouble(), sales.toDouble()));
//       if (sales > maxY) {
//         maxY = sales.toDouble();
//       }
//       xIndex++;
//     }

//     // Add some padding to maxY for better chart display
//     maxY = (maxY * 1.2).ceilToDouble();
//     if (maxY == 0) maxY = 10; // Prevent division by zero if no sales

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
//               'Daily Product Sales Rate (Last 30 Days)',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Average Daily Sales: ${averageDailySalesRate.toStringAsFixed(2)} units',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (spots.isEmpty)
//               const Center(child: Text('No sales data available for charting.'))
//             else
//               AspectRatio(
//                 aspectRatio: 1.6,
//                 child: LineChart(
//                   LineChartData(
//                     minX: 0,
//                     maxX:
//                         spots.length.toDouble() -
//                         1, // X-axis spans the number of days
//                     minY: minY,
//                     maxY: maxY,
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
//                             if (value.toInt() % 7 == 0) {
//                               // Show label for every 7th day (weekly)
//                               return SideTitleWidget(
//                                 axisSide: meta.axisSide,
//                                 space: 4.0,
//                                 child: Text(
//                                   dateFormat.format(sortedDates[value.toInt()]),
//                                   style: const TextStyle(
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               );
//                             }
//                             return const SizedBox.shrink();
//                           },
//                         ),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           interval: maxY / 4, // Roughly 4 intervals
//                           getTitlesWidget: (value, meta) {
//                             return Text(
//                               value.toInt().toString(),
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
//                     gridData: FlGridData(
//                       show: true,
//                       drawVerticalLine: true,
//                       getDrawingHorizontalLine: (value) => const FlLine(
//                         color: Color(0xff37434d),
//                         strokeWidth: 0.5,
//                       ),
//                       getDrawingVerticalLine: (value) => const FlLine(
//                         color: Color(0xff37434d),
//                         strokeWidth: 0.5,
//                       ),
//                     ),
//                     borderData: FlBorderData(
//                       show: true,
//                       border: Border.all(
//                         color: const Color(0xff37434d),
//                         width: 1,
//                       ),
//                     ),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: spots,
//                         isCurved: true,
//                         color: Colors.green,
//                         barWidth: 3,
//                         isStrokeCapRound: true,
//                         dotData: const FlDotData(show: false),
//                         belowBarData: BarAreaData(
//                           show: true,
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.green.withOpacity(0.3),
//                               Colors.green.withOpacity(0),
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                       ),
//                     ],
//                     lineTouchData: LineTouchData(
//                       touchTooltipData: LineTouchTooltipData(
//                         tooltipBgColor: Colors.blueGrey,
//                         getTooltipItems: (touchedSpots) {
//                           return touchedSpots.map((LineBarSpot touchedSpot) {
//                             final String date = dateFormat.format(
//                               sortedDates[touchedSpot.x.toInt()],
//                             );
//                             return LineTooltipItem(
//                               '$date\n',
//                               const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: '${touchedSpot.y.toInt()} units',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }).toList();
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
