import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import for TypeAheadField
import 'package:intl/intl.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

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
            .collection('products')
            .where('discountPercentage', isGreaterThan: 0)
            .orderBy('discountExpiry')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading promotions.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No discounts applied yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed';
              final discount = (data['discountPercentage'] ?? 0).toDouble();
              final expiry = (data['discountExpiry'] as Timestamp).toDate();
              final imageUrl = data['imageUrl'] ?? '';
              final discountedPrice = (data['discountedPrice'] ?? 0).toDouble();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/placeholder.png', // Ensure this asset exists
                            width: 50,
                            height: 50,
                          ),
                        )
                      : Image.asset(
                          'assets/images/placeholder.png', // Ensure this asset exists
                          width: 50,
                          height: 50,
                        ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discount: ${discount.toStringAsFixed(0)}%'),
                      Text(
                        'Discounted Price: UGX ${discountedPrice.toStringAsFixed(0)}',
                      ),
                      Text(
                        'Expires: ${DateFormat('yyyy-MM-dd').format(expiry)}',
                      ),
                      if (expiry.isBefore(DateTime.now()))
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
                  onTap: () => _showEditDialog(context, doc, data),
                ),
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

  /// Displays a dialog to edit an existing product promotion.
  ///
  /// This function takes the [BuildContext], the [DocumentSnapshot] of the product,
  /// and the [Map] of its data to pre-fill the dialog fields. It allows the user
  /// to update the discount percentage and the expiry date.
  void _showEditDialog(
    BuildContext context,
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) {
    final formKey = GlobalKey<FormState>();
    double discount = (data['discountPercentage'] ?? 0).toDouble();
    // Initialize expiry date controller with current value
    _expiryDateDialogController.text = DateFormat(
      'yyyy-MM-dd',
    ).format((data['discountExpiry'] as Timestamp).toDate());
    DateTime expiry = (data['discountExpiry'] as Timestamp).toDate();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit Promotion - ${data['name']}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: discount.toString(),
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
                          return 'Enter 0–100';
                        }
                        return null;
                      },
                      onSaved: (value) => discount = double.parse(value!),
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
                              initialDate:
                                  expiry, // Use the current 'expiry' for initial date
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 5),
                              ),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                expiry = picked;
                                _expiryDateDialogController.text = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(picked);
                              });
                            }
                          },
                        ),
                      ),
                      // Allow manual input, so remove readOnly
                      onChanged: (value) {
                        try {
                          expiry = DateFormat('yyyy-MM-dd').parseStrict(value);
                          // Clear any previous validation errors if the format is correct
                          formKey.currentState!.validate();
                        } catch (e) {
                          // Handle invalid date format, but don't set expiry to null immediately
                          // The validator will catch it.
                        }
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
                          expiry =
                              parsedDate; // Update expiry if validation passes
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

                      final price = (data['price'] ?? 0).toDouble();
                      final discountedPrice = (price * (1 - discount / 100))
                          .clamp(0, price);

                      await doc.reference.update({
                        'discountPercentage': discount,
                        'discountExpiry': Timestamp.fromDate(expiry),
                        'discountedPrice': discountedPrice,
                      });

                      if (!mounted) return;
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Updated promotion for ${data['name']}',
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

  /// Displays a dialog to add a new discount for a product.
  ///
  /// This function allows the user to search for a product, specify a discount
  /// percentage, and set an expiry date for the discount.
  void _showAddDiscountDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String productName = '';
    String productId = '';
    String imageUrl = '';
    double discount = 0;
    DateTime? expiryDate;
    double originalPrice = 0;

    _productNameDialogController.clear();
    _expiryDateDialogController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Apply Discount'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TypeAheadField<Map<String, dynamic>>(
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
                                  productId.isEmpty) {
                                return 'Please select a product from suggestions';
                              }
                              return null;
                            },
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          if (pattern.trim().isEmpty) return [];

                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('products')
                              .where('name', isGreaterThanOrEqualTo: pattern)
                              .where(
                                'name',
                                isLessThanOrEqualTo: '$pattern\uf8ff',
                              )
                              .limit(10)
                              .get();

                          return querySnapshot.docs.map((doc) {
                            final data = doc.data();
                            return {
                              'id': doc.id,
                              'name': data['name'] ?? '',
                              'imageUrl': data['imageUrl'] ?? '',
                              'price': (data['price'] ?? 0).toDouble(),
                              'expiryDate':
                                  data['expiryDate'], // Keep fetching this
                            };
                          }).toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading:
                                suggestion['imageUrl'].toString().isNotEmpty
                                ? Image.network(
                                    suggestion['imageUrl'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    ),
                                  )
                                : const Icon(Icons.image, size: 40),
                            title: Text(suggestion['name'] ?? 'Unnamed'),
                          );
                        },
                        onSelected: (suggestion) async {
                          productName = suggestion['name'] ?? '';
                          productId = suggestion['id'] ?? '';
                          imageUrl = suggestion['imageUrl'] ?? '';
                          originalPrice = (suggestion['price'] ?? 0.0);

                          _productNameDialogController.text = productName;

                          final productDoc = await FirebaseFirestore.instance
                              .collection('products')
                              .doc(productId)
                              .get();

                          final productData = productDoc.data();
                          if (productData != null &&
                              productData['expiryDate'] != null) {
                            final Timestamp ts = productData['expiryDate'];
                            expiryDate = ts.toDate();
                            _expiryDateDialogController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(expiryDate!);
                          } else {
                            expiryDate = null;
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
                        initialValue: discount.toString(),
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
                            return 'Enter 0–100';
                          }
                          return null;
                        },
                        onSaved: (value) => discount = double.parse(value!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _expiryDateDialogController,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date (YYYY-MM-DD)',
                          hintText: 'YYYY-MM-DD', // Add a hint for manual input
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: expiryDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 5),
                                ),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  expiryDate = picked;
                                  _expiryDateDialogController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                        ),
                        // Remove readOnly to allow manual input
                        onChanged: (value) {
                          try {
                            expiryDate = DateFormat(
                              'yyyy-MM-dd',
                            ).parseStrict(value);
                            // Clear any previous validation errors if the format is correct
                            formKey.currentState!.validate();
                          } catch (e) {
                            // The validator will catch invalid format
                          }
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
                            expiryDate =
                                parsedDate; // Update expiryDate if validation passes
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

                      if (productId.isEmpty) {
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

                      if (expiryDate == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cannot apply discount: Expiry date is missing or invalid.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );

                        return;
                      }

                      final discountedPrice =
                          (originalPrice * (1 - discount / 100)).clamp(
                            0,
                            originalPrice,
                          );

                      try {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(productId)
                            .update({
                              'discountPercentage': discount,
                              'discountExpiry': Timestamp.fromDate(expiryDate!),
                              'discountedPrice': discountedPrice,
                            });

                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully applied discount to $productName!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to apply discount: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
