import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id;
  final String name;
  final double discountPercentage;
  final DateTime discountExpiry;
  final String imageUrl;

  Promotion({
    required this.id,
    required this.name,
    required this.discountPercentage,
    required this.discountExpiry,
    required this.imageUrl,
  });

  factory Promotion.fromJson(Map<String, dynamic> json, String id) {
    return Promotion(
      id: id,
      name: json['name'] ?? '',
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      discountExpiry: (json['discountExpiry'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'discountPercentage': discountPercentage,
      'discountExpiry': Timestamp.fromDate(discountExpiry),
      'imageUrl': imageUrl,
    };
  }
}
