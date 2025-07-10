import 'package:cloud_firestore/cloud_firestore.dart';

/// Promotion model for managing discounts and special offers
/// Handles expiry-based promotions and general promotional campaigns
class Promotion {
  final String id;
  final String name;
  final String description;
  final PromotionType type;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> productIds; // Products included in promotion
  final List<String> categories; // Categories included in promotion
  final String createdBy; // Manager ID who created the promotion
  final DateTime createdAt;
  final bool isActive;
  final PromotionStatus status;
  final int? maxUsageCount;
  final int currentUsageCount;
  final double? minPurchaseAmount;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    this.productIds = const [],
    this.categories = const [],
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
    required this.status,
    this.maxUsageCount,
    this.currentUsageCount = 0,
    this.minPurchaseAmount,
  });

  /// Check if promotion is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate) &&
           status == PromotionStatus.active &&
           (maxUsageCount == null || currentUsageCount < maxUsageCount!);
  }

  /// Calculate days remaining for promotion
  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Calculate promotion usage percentage
  double get usagePercentage {
    if (maxUsageCount == null) return 0.0;
    return (currentUsageCount / maxUsageCount!) * 100;
  }

  /// Calculate estimated recovery amount for expiry promotions
  double calculateEstimatedRecovery(List<Product> products) {
    double totalRecovery = 0.0;
    for (final product in products) {
      if (productIds.contains(product.id) || categories.contains(product.category)) {
        final discountedPrice = product.price * (1 - discountPercentage / 100);
        totalRecovery += discountedPrice * product.totalQuantity;
      }
    }
    return totalRecovery;
  }

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: PromotionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PromotionType.general,
      ),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      productIds: List<String>.from(data['productIds'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      status: PromotionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PromotionStatus.draft,
      ),
      maxUsageCount: data['maxUsageCount'],
      currentUsageCount: data['currentUsageCount'] ?? 0,
      minPurchaseAmount: data['minPurchaseAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'discountPercentage': discountPercentage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'productIds': productIds,
      'categories': categories,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'status': status.name,
      'maxUsageCount': maxUsageCount,
      'currentUsageCount': currentUsageCount,
      'minPurchaseAmount': minPurchaseAmount,
    };
  }

  Promotion copyWith({
    String? name,
    String? description,
    PromotionType? type,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? productIds,
    List<String>? categories,
    bool? isActive,
    PromotionStatus? status,
    int? maxUsageCount,
    int? currentUsageCount,
    double? minPurchaseAmount,
  }) {
    return Promotion(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productIds: productIds ?? this.productIds,
      categories: categories ?? this.categories,
      createdBy: createdBy,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      maxUsageCount: maxUsageCount ?? this.maxUsageCount,
      currentUsageCount: currentUsageCount ?? this.currentUsageCount,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
    );
  }
}

/// Types of promotions available
enum PromotionType {
  expiry,     // Promotions for products nearing expiry
  general,    // General promotional campaigns
  seasonal,   // Seasonal promotions
  clearance,  // Clearance sales
  bulk,       // Bulk purchase discounts
}

/// Status of promotions
enum PromotionStatus {
  draft,      // Being created/edited
  active,     // Currently running
  paused,     // Temporarily paused
  completed,  // Ended successfully
  cancelled,  // Cancelled before completion
}

/// Extension to get display names for enums
extension PromotionTypeExtension on PromotionType {
  String get displayName {
    switch (this) {
      case PromotionType.expiry:
        return 'Expiry Promotion';
      case PromotionType.general:
        return 'General Promotion';
      case PromotionType.seasonal:
        return 'Seasonal Promotion';
      case PromotionType.clearance:
        return 'Clearance Sale';
      case PromotionType.bulk:
        return 'Bulk Discount';
    }
  }
}

extension PromotionStatusExtension on PromotionStatus {
  String get displayName {
    switch (this) {
      case PromotionStatus.draft:
        return 'Draft';
      case PromotionStatus.active:
        return 'Active';
      case PromotionStatus.paused:
        return 'Paused';
      case PromotionStatus.completed:
        return 'Completed';
      case PromotionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Analytics data for promotions
class PromotionAnalytics {
  final String promotionId;
  final double totalSales;
  final int totalTransactions;
  final double totalDiscount;
  final double averageOrderValue;
  final Map<String, int> productSales; // Product ID -> quantity sold
  final DateTime calculatedAt;

  PromotionAnalytics({
    required this.promotionId,
    required this.totalSales,
    required this.totalTransactions,
    required this.totalDiscount,
    required this.averageOrderValue,
    required this.productSales,
    required this.calculatedAt,
  });

  /// Calculate return on investment for the promotion
  double calculateROI(double promotionCost) {
    if (promotionCost == 0) return 0.0;
    return ((totalSales - promotionCost) / promotionCost) * 100;
  }

  factory PromotionAnalytics.fromMap(Map<String, dynamic> map) {
    return PromotionAnalytics(
      promotionId: map['promotionId'] ?? '',
      totalSales: (map['totalSales'] ?? 0).toDouble(),
      totalTransactions: map['totalTransactions'] ?? 0,
      totalDiscount: (map['totalDiscount'] ?? 0).toDouble(),
      averageOrderValue: (map['averageOrderValue'] ?? 0).toDouble(),
      productSales: Map<String, int>.from(map['productSales'] ?? {}),
      calculatedAt: (map['calculatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'promotionId': promotionId,
      'totalSales': totalSales,
      'totalTransactions': totalTransactions,
      'totalDiscount': totalDiscount,
      'averageOrderValue': averageOrderValue,
      'productSales': productSales,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }