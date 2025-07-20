// // lib/services/firestore_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:freshtally/models/association_rule.dart'; // Keep this import
// import 'package:freshtally/models/dashboard_data.dart'; // NEW: Import DashboardData
// import 'package:syncfusion_flutter_datepicker/datepicker.dart'; // For PickerDateRange

// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final String _rulesCollection = 'association_rules';
//   final String _dailySummaryCollection =
//       'daily_summary'; // NEW: Assuming this collection exists

//   // ... (Existing methods for Association Rules) ...

//   // Fetches aggregated dashboard KPIs for a given date range
//   Future<DashboardData> getDashboardKPIs(PickerDateRange dateRange) async {
//     try {
//       // Convert PickerDateRange to DateTime for queries
//       DateTime startDate =
//           dateRange.startDate ??
//           DateTime.now().subtract(const Duration(days: 7));
//       DateTime endDate = dateRange.endDate ?? DateTime.now();

//       // Query daily summaries within the date range
//       final QuerySnapshot snapshot = await _db
//           .collection(_dailySummaryCollection)
//           .where(
//             'date',
//             isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.toUtc()),
//           )
//           .where(
//             'date',
//             isLessThanOrEqualTo: Timestamp.fromDate(
//               endDate
//                   .toUtc()
//                   .add(const Duration(days: 1))
//                   .subtract(const Duration(seconds: 1)),
//             ),
//           ) // Include full end day
//           .orderBy('date', descending: false)
//           .get();

//       double totalSales = 0.0;
//       int totalTransactions = 0;
//       Map<String, double> productSalesMap = {}; // For top product
//       Map<String, double> categorySalesMap = {}; // For category sales chart
//       List<SalesDataPoint> salesTrendData = [];

//       for (var doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;

//         totalSales += (data['total_sales'] as num?)?.toDouble() ?? 0.0;
//         totalTransactions += (data['total_transactions'] as num?)?.toInt() ?? 0;

//         // Populate sales trend data
//         salesTrendData.add(SalesDataPoint.fromMap(data));

//         // Aggregate product sales for top product
//         if (data.containsKey('product_sales')) {
//           // Assuming a map of product_id: sales
//           (data['product_sales'] as Map<String, dynamic>).forEach((
//             productId,
//             sales,
//           ) {
//             productSalesMap[productId] =
//                 (productSalesMap[productId] ?? 0.0) + (sales as num).toDouble();
//           });
//         }

//         // Aggregate category sales for category chart
//         if (data.containsKey('category_sales')) {
//           // Assuming an array of maps like [{category: 'Food', sales: 100}]
//           List<dynamic> catSalesList = data['category_sales'];
//           for (var item in catSalesList) {
//             String category = item['category'];
//             double sales = (item['sales'] as num).toDouble();
//             categorySalesMap[category] =
//                 (categorySalesMap[category] ?? 0.0) + sales;
//           }
//         }
//       }

//       // Determine top product
//       String topProductName = 'N/A';
//       double topProductSales = 0.0;
//       if (productSalesMap.isNotEmpty) {
//         // This requires fetching product names from a 'products' collection based on IDs
//         // For simplicity, let's just pick the top product ID and assume a lookup is done later
//         // Or, if 'top_product' is stored directly in daily summary:
//         topProductName = snapshot.docs.isNotEmpty
//             ? (snapshot.docs.last.data()
//                       as Map<String, dynamic>)['top_product_name'] ??
//                   'N/A'
//             : 'N/A';
//         topProductSales = snapshot.docs.isNotEmpty
//             ? (snapshot.docs.last.data()
//                           as Map<String, dynamic>)['top_product_sales']
//                       ?.toDouble() ??
//                   0.0
//             : 0.0;

//         // If you need to derive top product from `productSalesMap`
//         // String? topProductId = productSalesMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
//         // You'd then fetch the product name from a 'products' collection using topProductId
//       }

//       double averageBasketValue = totalTransactions > 0
//           ? totalSales / totalTransactions
//           : 0.0;

//       // Convert categorySalesMap to List<CategorySalesData>
//       List<CategorySalesData> categorySalesData = categorySalesMap.entries
//           .map((e) => CategorySalesData(category: e.key, sales: e.value))
//           .toList();

//       return DashboardData.fromAggregatedData(
//         totalSales: totalSales,
//         totalTransactions: totalTransactions,
//         averageBasketValue: averageBasketValue,
//         topProductName: topProductName,
//         topProductSales: topProductSales,
//         salesTrend: salesTrendData,
//         categorySales: categorySalesData,
//       );
//     } catch (e) {
//       print("Error fetching dashboard KPIs: $e");
//       return DashboardData.fromAggregatedData(
//         totalSales: 0.0,
//         totalTransactions: 0,
//         averageBasketValue: 0.0,
//         topProductName: 'Error',
//         topProductSales: 0.0,
//       ); // Return default/error data
//     }
//   }

//   // Existing methods...
//   Future<List<String>> getAllAntecedentProducts() async {
//     try {
//       final querySnapshot = await _db
//           .collection(_rulesCollection)
//           .limit(500) // Limit to avoid large reads for initial list
//           .get();

//       Set<String> uniqueProducts = {};
//       for (var doc in querySnapshot.docs) {
//         final rule = AssociationRule.fromFirestore(doc);
//         uniqueProducts.addAll(rule.antecedents);
//       }
//       return uniqueProducts.toList()..sort(); // Sort alphabetically
//     } catch (e) {
//       print("Error fetching all antecedent products: $e");
//       return [];
//     }
//   }

//   Future<List<AssociationRule>> getRecommendations(
//     String selectedProduct,
//   ) async {
//     try {
//       final querySnapshot = await _db
//           .collection(_rulesCollection)
//           .where('antecedents', arrayContains: selectedProduct)
//           .orderBy('lift', descending: true)
//           .limit(10)
//           .get();

//       return querySnapshot.docs
//           .map((doc) => AssociationRule.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       print("Error fetching recommendations: $e");
//       return [];
//     }
//   }

//   Future<List<AssociationRule>> getAllAssociationRules({
//     String? sortBy,
//     bool descending = true,
//     String? filterByItem,
//   }) async {
//     try {
//       Query query = _db.collection(_rulesCollection);

//       if (filterByItem != null && filterByItem.isNotEmpty) {
//         query = query.where(
//           'antecedents',
//           arrayContains: filterByItem,
//         ); // Changed to only antecedents for simplicity in this filter
//       }

//       if (sortBy != null &&
//           ['support', 'confidence', 'lift'].contains(sortBy)) {
//         query = query.orderBy(sortBy, descending: descending);
//       } else {
//         query = query.orderBy('lift', descending: true);
//       }

//       final querySnapshot = await query.limit(1000).get();

//       return querySnapshot.docs
//           .map((doc) => AssociationRule.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       print("Error fetching all association rules: $e");
//       return [];
//     }
//   }
// }
