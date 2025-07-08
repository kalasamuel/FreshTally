import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model representing items in the supermarket
/// Contains all essential product information including location, pricing, and expiry details
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final ShelfLocation location;
  final List<Batch> batches;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // Staff ID who created the product
  final bool isActive;
  final double? discountPercentage;
  final DateTime? discountExpiry;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imageUrl = '',
    this.description = '',
    required this.location,
    this.batches = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
    this.discountPercentage,
    this.discountExpiry,
  });

  /// Calculate total quantity from all batches
  int get totalQuantity {
    return batches.fold(0, (sum, batch) => sum + batch.quantity);
  }

  /// Get earliest expiry date from all batches
  DateTime? get earliestExpiry {
    if (batches.isEmpty) return null;
    return batches
        .map((batch) => batch.expiryDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Check if product is expiring soon (within 7 days)
  bool get isExpiringSoon {
    final expiry = earliestExpiry;
    if (expiry == null) return false;
    return expiry.difference(DateTime.now()).inDays <= 7;
  }

  /// Calculate current effective price (with discount if applicable)
  double get effectivePrice {
    if (discountPercentage != null && 
        discountExpiry != null && 
        discountExpiry!.isAfter(DateTime.now())) {
      return price * (1 - discountPercentage! / 100);
    }
    return price;
  }

  /// Calculate projected loss from expired products
  double get projectedLoss {
    final expiredQuantity = batches
        .where((batch) => batch.expiryDate.isBefore(DateTime.now()))
        .fold(0, (sum, batch) => sum + batch.quantity);
    return expiredQuantity * price;
  }

  /// Factory constructor from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      location: ShelfLocation.fromMap(data['location'] ?? {}),
      batches: (data['batches'] as List<dynamic>? ?? [])
          .map((b) => Batch.fromMap(b as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      isActive: data['isActive'] ?? true,
      discountPercentage: data['discountPercentage']?.toDouble(),
      discountExpiry: data['discountExpiry'] != null 
          ? (data['discountExpiry'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'location': location.toMap(),
      'batches': batches.map((b) => b.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'isActive': isActive,
      'discountPercentage': discountPercentage,
      'discountExpiry': discountExpiry != null 
          ? Timestamp.fromDate(discountExpiry!)
          : null,
    };
  }

  /// Create a copy with updated fields
  Product copyWith({
    String? name,
    String? category,
    double? price,
    String? imageUrl,
    String? description,
    ShelfLocation? location,
    List<Batch>? batches,
    DateTime? updatedAt,
    bool? isActive,
    double? discountPercentage,
    DateTime? discountExpiry,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      location: location ?? this.location,
      batches: batches ?? this.batches,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
      isActive: isActive ?? this.isActive,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountExpiry: discountExpiry ?? this.discountExpiry,
    );
  }
}

/// Represents the physical location of a product in the supermarket
class ShelfLocation {
  final int floor;
  final int shelfNumber;
  final String position; // 'top', 'middle', 'bottom'

  ShelfLocation({
    required this.floor,
    required this.shelfNumber,
    required this.position,
  });

  /// Display location as readable string
  String get displayLocation => 'Floor $floor - Shelf $shelfNumber';
  
  /// Full location description
  String get fullLocation => 'Floor $floor • Shelf $shelfNumber • ${position.toUpperCase()}';

  factory ShelfLocation.fromMap(Map<String, dynamic> map) {
    return ShelfLocation(
      floor: map['floor'] ?? 1,
      shelfNumber: map['shelfNumber'] ?? 1,
      position: map['position'] ?? 'middle',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'floor': floor,
      'shelfNumber': shelfNumber,
      'position': position,
    };
  }
}

/// Represents a batch of products with expiry tracking
class Batch {
  final String id;
  final String batchNumber;
  final int quantity;
  final DateTime expiryDate;
  final DateTime receivedDate;
  final String supplierId;
  final double costPrice;

  Batch({
    required this.id,
    required this.batchNumber,
    required this.quantity,
    required this.expiryDate,
    required this.receivedDate,
    required this.supplierId,
    required this.costPrice,
  });

  /// Check if batch is expired
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  /// Days until expiry (negative if expired)
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      id: map['id'] ?? '',
      batchNumber: map['batchNumber'] ?? '',
      quantity: map['quantity'] ?? 0,
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      receivedDate: (map['receivedDate'] as Timestamp).toDate(),
      supplierId: map['supplierId'] ?? '',
      costPrice: (map['costPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'quantity': quantity,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'receivedDate': Timestamp.fromDate(receivedDate),
      'supplierId': supplierId,
      'costPrice': costPrice,
    };
  }
}