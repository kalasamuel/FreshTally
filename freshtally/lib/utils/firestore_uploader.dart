import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadProducts() async {
  final products = await loadProductsFromJson();
  final firestore = FirebaseFirestore.instance;

  for (var product in products) {
    final expiry = product['expiry_date'].split('-');
    final expiryDate = DateTime(
      int.parse('20${expiry[2]}'),
      int.parse(expiry[1]),
      int.parse(expiry[0]),
    );

    product['expiry_date'] = Timestamp.fromDate(expiryDate);

    await firestore
        .collection('products')
        .doc(product['product_id'])
        .set(product);
  }

  print('✅ Products uploaded!');
}

Future<List<Map<String, dynamic>>> loadProductsFromJson() async {
  final jsonStr = await rootBundle.loadString('assets/products.json');
  final List<dynamic> jsonData = json.decode(jsonStr);
  return jsonData.cast<Map<String, dynamic>>();
}
