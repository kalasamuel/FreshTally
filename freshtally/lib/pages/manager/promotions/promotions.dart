import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

// --- Models ---
/// Represents a product with all its attributes.
class Product {
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double productOriginalPrice;
  final DateTime? productExpiryDate;
  final String productSku;
  final String productDescription;
  final String productCategory;
  final DateTime productCreatedAt;
  final DateTime productLastSoldAt;
  final String productLowerName;

  Product({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.productOriginalPrice,
    this.productExpiryDate,
    required this.productSku,
    required this.productDescription,
    required this.productCategory,
    required this.productCreatedAt,
    required this.productLastSoldAt,
    required this.productLowerName,
  });

  /// Factory constructor to create a [Product] from a Firestore [DocumentSnapshot].
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      productId: doc.id,
      productName: data['name'] ?? 'Unnamed Product',
      productImageUrl: data['imageUrl'],
      productOriginalPrice: (data['current_price'] ?? 0.0).toDouble(),
      productExpiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      productSku: data['sku'] ?? '',
      productDescription: data['description'] ?? '',
      productCategory: data['category'] ?? '',
      productCreatedAt: (data['created_at'] as Timestamp).toDate(),
      productLastSoldAt: (data['last_sold_at'] as Timestamp).toDate(),
      productLowerName: data['name_lower'] ?? '',
    );
  }

  /// Converts this [Product] instance into a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': productName,
      'imageUrl': productImageUrl,
      'current_price': productOriginalPrice,
      'expiryDate': productExpiryDate != null
          ? Timestamp.fromDate(productExpiryDate!)
          : null,
      'sku': productSku,
      'description': productDescription,
      'category': productCategory,
      'created_at': Timestamp.fromDate(productCreatedAt),
      'last_sold_at': Timestamp.fromDate(productLastSoldAt),
      'name_lower': productLowerName,
    };
  }
}

/// Represents a promotion or discount.
class Promotion {
  final String promotionId;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double originalPrice;
  final double discountPercentage;
  final double discountedPrice;
  final DateTime discountExpiry;
  final DateTime createdAt;

  Promotion({
    required this.promotionId,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.discountExpiry,
    required this.createdAt,
  });

  /// Factory constructor to create a [Promotion] from a Firestore [DocumentSnapshot].
  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      promotionId: doc.id,
      productId: data['productId'] ?? '',
      productName: data['name'] ?? 'Unnamed Promotion',
      productImageUrl: data['imageUrl'],
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      discountedPrice: (data['discountedPrice'] ?? 0).toDouble(),
      discountExpiry: (data['discountExpiry'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this [Promotion] instance into a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': productName,
      'imageUrl': productImageUrl,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'discountedPrice': discountedPrice,
      'discountExpiry': Timestamp.fromDate(discountExpiry),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// --- PromotionsPage Widget ---
class PromotionsPage extends StatefulWidget {
  final String supermarketId;

  const PromotionsPage({super.key, required this.supermarketId});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final TextEditingController _productNameDialogController =
      TextEditingController();
  final TextEditingController _expiryDateDialogController =
      TextEditingController();

  @override
  void dispose() {
    _productNameDialogController.dispose();
    _expiryDateDialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promotions & Discounts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('promotions')
            .orderBy('discountExpiry')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading promotions.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final promotions = snapshot.data!.docs
              .map((doc) => Promotion.fromFirestore(doc))
              .toList();

          if (promotions.isEmpty) {
            return const Center(child: Text('No promotions added yet.'));
          }

          return ListView.builder(
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];

              return Builder(
                builder: (BuildContext validContext) {
                  return Dismissible(
                    key: Key(promotion.promotionId),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: validContext,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: Text(
                            'Delete the promotion for "${promotion.productName}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      await FirebaseFirestore.instance
                          .collection('supermarkets')
                          .doc(widget.supermarketId)
                          .collection('promotions')
                          .doc(promotion.promotionId)
                          .delete();

                      // Use captured valid context here
                      ScaffoldMessenger.of(validContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deleted promotion for ${promotion.productName}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading:
                            promotion.productImageUrl != null &&
                                promotion.productImageUrl!.isNotEmpty
                            ? Image.network(
                                promotion.productImageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/placeholder.png',
                                  width: 50,
                                  height: 50,
                                ),
                              )
                            : Image.asset(
                                'assets/images/placeholder.png',
                                width: 50,
                                height: 50,
                              ),
                        title: Text(
                          promotion.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Original Price: UGX ${promotion.originalPrice.toStringAsFixed(0)}',
                            ),
                            Text(
                              'Discount: ${promotion.discountPercentage.toStringAsFixed(0)}%',
                            ),
                            Text(
                              'Discounted Price: UGX ${promotion.discountedPrice.toStringAsFixed(0)}',
                            ),
                            Text(
                              'Expires: ${DateFormat('yyyy-MM-dd').format(promotion.discountExpiry)}',
                            ),
                            if (promotion.discountExpiry.isBefore(
                              DateTime.now(),
                            ))
                              const Text(
                                'EXPIRED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showEditDialog(context, promotion),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDiscountDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Promotion promotion) {
    final formKey = GlobalKey<FormState>();
    double discountPercentage = promotion.discountPercentage;
    _expiryDateDialogController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(promotion.discountExpiry);
    DateTime discountExpiry = promotion.discountExpiry;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit Promotion - ${promotion.productName}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: discountPercentage.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter discount';
                        }
                        final d = double.tryParse(value);
                        if (d == null || d < 0 || d > 100) {
                          return 'Enter 0-100';
                        }
                        return null;
                      },
                      onSaved: (value) =>
                          discountPercentage = double.parse(value!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _expiryDateDialogController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date (YYYY-MM-DD)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: discountExpiry,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 5),
                              ),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                discountExpiry = picked;
                                _expiryDateDialogController.text = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(picked);
                              });
                            }
                          },
                        ),
                      ),
                      onChanged: (value) {
                        try {
                          discountExpiry = DateFormat(
                            'yyyy-MM-dd',
                          ).parseStrict(value);
                          formKey.currentState!.validate();
                        } catch (e) {}
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Expiry date is required';
                        }
                        try {
                          final parsedDate = DateFormat(
                            'yyyy-MM-dd',
                          ).parseStrict(value);
                          if (parsedDate.isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          )) {
                            return 'Date cannot be in the past';
                          }
                          discountExpiry = parsedDate;
                        } catch (e) {
                          return 'Enter a valid date (YYYY-MM-DD)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      final newDiscountedPrice =
                          (promotion.originalPrice *
                                  (1 - discountPercentage / 100))
                              .clamp(0, promotion.originalPrice);

                      await FirebaseFirestore.instance
                          .collection('supermarkets')
                          .doc(widget.supermarketId)
                          .collection('promotions')
                          .doc(promotion.promotionId)
                          .update({
                            'discountPercentage': discountPercentage,
                            'discountExpiry': Timestamp.fromDate(
                              discountExpiry,
                            ),
                            'discountedPrice': newDiscountedPrice,
                          });

                      if (!mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Updated promotion for ${promotion.productName}',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDiscountDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String selectedProductName = '';
    String selectedProductId = '';
    String? selectedProductImageUrl;
    double newDiscountPercentage = 0;
    DateTime? newDiscountExpiryDate;
    double selectedProductOriginalPrice = 0;

    _productNameDialogController.clear();
    _expiryDateDialogController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Create New Promotion'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TypeAheadField<Product>(
                        controller: _productNameDialogController,
                        builder: (context, controller, focusNode) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Product Name',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  selectedProductId.isEmpty) {
                                return 'Please select a product from suggestions';
                              }
                              return null;
                            },
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          if (pattern.trim().isEmpty) return [];

                          final lowercasePattern = pattern.toLowerCase();

                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('supermarkets')
                              .doc(widget.supermarketId)
                              .collection('products')
                              .where(
                                'name_lower',
                                isGreaterThanOrEqualTo: lowercasePattern,
                              )
                              .where(
                                'name_lower',
                                isLessThanOrEqualTo: '$lowercasePattern\uf8ff',
                              )
                              .limit(10)
                              .get();

                          return querySnapshot.docs
                              .map((doc) => Product.fromFirestore(doc))
                              .toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading:
                                suggestion.productImageUrl != null &&
                                    suggestion.productImageUrl!.isNotEmpty
                                ? Image.network(
                                    suggestion.productImageUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    ),
                                  )
                                : const Icon(Icons.image, size: 40),
                            title: Text(suggestion.productName),
                          );
                        },
                        onSelected: (suggestion) async {
                          selectedProductName = suggestion.productName;
                          selectedProductId = suggestion.productId;
                          selectedProductImageUrl = suggestion.productImageUrl;
                          selectedProductOriginalPrice =
                              suggestion.productOriginalPrice;
                          newDiscountExpiryDate = suggestion.productExpiryDate;

                          _productNameDialogController.text =
                              selectedProductName;
                          if (newDiscountExpiryDate != null) {
                            _expiryDateDialogController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(newDiscountExpiryDate!);
                          } else {
                            _expiryDateDialogController.clear();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Warning: Selected product has no expiry date set.',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                          setStateDialog(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: newDiscountPercentage.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Discount %',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter discount';
                          }
                          final d = double.tryParse(value);
                          if (d == null || d < 0 || d > 100) {
                            return 'Enter 0-100';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            newDiscountPercentage = double.parse(value!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _expiryDateDialogController,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date (YYYY-MM-DD)',
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    newDiscountExpiryDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 5),
                                ),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  newDiscountExpiryDate = picked;
                                  _expiryDateDialogController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                        ),
                        onChanged: (value) {
                          try {
                            newDiscountExpiryDate = DateFormat(
                              'yyyy-MM-dd',
                            ).parseStrict(value);
                            formKey.currentState!.validate();
                          } catch (e) {}
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Expiry date is required';
                          }
                          try {
                            final parsedDate = DateFormat(
                              'yyyy-MM-dd',
                            ).parseStrict(value);
                            if (parsedDate.isBefore(
                              DateTime.now().subtract(const Duration(days: 1)),
                            )) {
                              return 'Date cannot be in the past';
                            }
                            newDiscountExpiryDate = parsedDate;
                          } catch (e) {
                            return 'Enter a valid date (YYYY-MM-DD)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      if (selectedProductId.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a product from the suggestions.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newDiscountExpiryDate == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cannot create promotion: Expiry date is missing or invalid.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final newDiscountedPrice =
                          (selectedProductOriginalPrice *
                                  (1 - newDiscountPercentage / 100))
                              .clamp(0, selectedProductOriginalPrice);

                      try {
                        final promotionRef = FirebaseFirestore.instance
                            .collection('supermarkets')
                            .doc(widget.supermarketId)
                            .collection('promotions')
                            .doc();

                        await promotionRef.set(
                          Promotion(
                            promotionId: promotionRef.id,
                            productId: selectedProductId,
                            productName: selectedProductName,
                            productImageUrl: selectedProductImageUrl,
                            originalPrice: selectedProductOriginalPrice,
                            discountPercentage: newDiscountPercentage,
                            discountedPrice: newDiscountedPrice.toDouble(),
                            discountExpiry: newDiscountExpiryDate!,
                            createdAt: DateTime.now(),
                          ).toFirestore(),
                        );

                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully created promotion for $selectedProductName!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create promotion: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
