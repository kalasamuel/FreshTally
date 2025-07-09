import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> loadProductsFromJson() async {
  String jsonString = await rootBundle.loadString('assets/products.json');
  List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.cast<Map<String, dynamic>>();
}

Future<void> uploadProductsToFirestore() async {
  final products = await loadProductsFromJson();
  final firestore = FirebaseFirestore.instance;

  for (var product in products) {
    // Convert expiry_date to Firestore Timestamp
    final expiryDateParts = product['expiry_date'].split('-');
    final expiryDate = DateTime(
      int.parse('20${expiryDateParts[2]}'),
      int.parse(expiryDateParts[1]),
      int.parse(expiryDateParts[0]),
    );

    product['expiry_date'] = Timestamp.fromDate(expiryDate);

    await firestore
        .collection('products')
        .doc(product['product_id'])
        .set(product);
  }
}
