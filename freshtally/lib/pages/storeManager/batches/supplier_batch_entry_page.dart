import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

class SupplierBatchEntryPage extends StatefulWidget {
  final DocumentSnapshot? batchToEdit;
  final DocumentSnapshot?
  supplierOfBatch; // This is the actual supplier doc for the batch
  final String supermarketId; // Crucial for multi-supermarket support

  const SupplierBatchEntryPage({
    super.key,
    this.batchToEdit,
    this.supplierOfBatch,
    required this.supermarketId,
  });

  @override
  State<SupplierBatchEntryPage> createState() => _SupplierBatchEntryPageState();
}

class _SupplierBatchEntryPageState extends State<SupplierBatchEntryPage> {
  final _formKey = GlobalKey<FormState>();

  final supplierNameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final productNameController = TextEditingController();
  final quantityController = TextEditingController();
  final expiryDateController = TextEditingController();

  DocumentSnapshot? selectedSupplier;
  DocumentSnapshot? selectedProduct;
  DateTime? _selectedExpiryDate;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.batchToEdit != null) {
      _isEditing = true;
      _initializeEditMode();
    }
  }

  Future<void> _initializeEditMode() async {
    final batchData = widget.batchToEdit!.data() as Map<String, dynamic>;

    final productRef = batchData['product_ref'] as DocumentReference?;
    if (productRef != null) {
      final productDoc = await productRef.get();
      if (productDoc.exists) {
        selectedProduct = productDoc;
        productNameController.text =
            (productDoc.data() as Map<String, dynamic>)['name'] ?? '';
      }
    }

    final supplierRef = batchData['supplier_ref'] as DocumentReference?;
    if (supplierRef != null) {
      final supplierDoc = await supplierRef.get();
      if (supplierDoc.exists) {
        selectedSupplier = supplierDoc;
        final supplierData = supplierDoc.data() as Map<String, dynamic>;
        supplierNameController.text = supplierData['name'] ?? '';
        contactController.text = supplierData['contact'] ?? '';
        addressController.text = supplierData['address'] ?? '';
      }
    }

    quantityController.text = batchData['quantity']?.toString() ?? '';

    final expiryTimestamp = batchData['expiry_date'] as Timestamp?;
    if (expiryTimestamp != null) {
      _selectedExpiryDate = expiryTimestamp.toDate();
      expiryDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedExpiryDate!);
    }

    setState(() {});
  }

  @override
  void dispose() {
    supplierNameController.dispose();
    contactController.dispose();
    addressController.dispose();
    productNameController.dispose();
    quantityController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  // MODIFIED: Search for suppliers within the supermarket's subcollection
  Future<List<DocumentSnapshot>> _searchSuppliers(String pattern) async {
    if (pattern.isEmpty) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(widget.supermarketId)
        .collection('suppliers') // Corrected path
        .where('name_lower', isGreaterThanOrEqualTo: pattern.toLowerCase())
        .where(
          'name_lower',
          isLessThanOrEqualTo: '${pattern.toLowerCase()}\uf8ff',
        )
        .limit(5)
        .get();
    return snapshot.docs;
  }

  // MODIFIED: Search for products within the supermarket's subcollection
  Future<List<DocumentSnapshot>> _searchProducts(String pattern) async {
    if (pattern.isEmpty) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(widget.supermarketId)
        .collection('products') // Corrected path
        .where('name_lower', isGreaterThanOrEqualTo: pattern.toLowerCase())
        .where(
          'name_lower',
          isLessThanOrEqualTo: '${pattern.toLowerCase()}\uf8ff',
        )
        .limit(5)
        .get();
    return snapshot.docs;
  }

  void _selectSupplier(DocumentSnapshot supplier) {
    final data = supplier.data() as Map<String, dynamic>;
    setState(() {
      selectedSupplier = supplier;
      supplierNameController.text = data['name'] ?? '';
      contactController.text = data['contact'] ?? '';
      addressController.text = data['address'] ?? '';
    });
    FocusScope.of(context).unfocus();
  }

  void _selectProduct(DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>;
    setState(() {
      selectedProduct = product;
      productNameController.text = data['name'] ?? '';
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
        expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        'Please fill all required fields correctly.',
        isError: true,
      );
      return;
    }

    if (selectedProduct == null) {
      _showSnackBar('Please select a product.', isError: true);
      return;
    }
    if (selectedSupplier == null && !_isEditing) {
      // If not editing, and no supplier is selected, it means we're creating a new one
      if (supplierNameController.text.trim().isEmpty) {
        _showSnackBar(
          'Please select an existing supplier or enter details for a new one.',
          isError: true,
        );
        return;
      }
    }

    final bool confirmSave = await _showConfirmationDialog(
      title: _isEditing ? 'Confirm Update' : 'Confirm Save',
      content: _isEditing
          ? 'Are you sure you want to update this batch and supplier information?'
          : 'Are you sure you want to save this new batch and supplier information?',
    );

    if (!confirmSave) {
      _showSnackBar('Save operation cancelled.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supplierData = {
        'name': supplierNameController.text.trim(),
        'name_lower': supplierNameController.text.trim().toLowerCase(),
        'contact': contactController.text.trim(),
        'address': addressController.text.trim(),
        // 'supermarketId' is implicitly handled by the path now, but can be kept for queries if needed
      };

      DocumentReference supplierRef;
      // If editing and a supplier was selected
      if (_isEditing && selectedSupplier != null) {
        // Update the existing supplier document within its supermarket subcollection
        await selectedSupplier!.reference.update(supplierData);
        supplierRef = selectedSupplier!.reference;
      } else if (selectedSupplier != null) {
        // This case handles selecting an existing supplier when adding a new batch
        supplierRef = selectedSupplier!.reference;
      } else {
        // If no supplier was selected (meaning a new one needs to be created)
        supplierRef = await FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('suppliers') // Corrected path for new supplier
            .add(supplierData);
      }

      final batchData = {
        'supplier_ref': supplierRef,
        'product_ref': selectedProduct!.reference,
        'quantity': int.tryParse(quantityController.text) ?? 0,
        'expiry_date': _selectedExpiryDate != null
            ? Timestamp.fromDate(_selectedExpiryDate!)
            : null,
        'created_at': FieldValue.serverTimestamp(),
        // 'supermarketId' is implicitly handled by the path here as well.
      };

      DocumentReference batchRef;
      if (_isEditing && widget.batchToEdit != null) {
        // Update the existing batch document within its supermarket subcollection
        await widget.batchToEdit!.reference.update(batchData);
        batchRef = widget.batchToEdit!.reference;
      } else {
        // Add a new batch document to the supermarket's batches subcollection
        batchRef = await FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('batches') // Corrected path for new batch
            .add(batchData);

        // Create notification only for new entries (not for edits)
        final notificationData = {
          'product_name': productNameController.text.trim(),
          'quantity': int.tryParse(quantityController.text) ?? 0,
          'supplier': supplierNameController.text.trim(),
          'expiry_date': _selectedExpiryDate != null
              ? Timestamp.fromDate(_selectedExpiryDate!)
              : null,
          'batch_ref': batchRef,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        };

        await FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('notifications')
            .add(notificationData);
      }

      if (!mounted) return;
      _showSnackBar(
        _isEditing
            ? '✅ Batch & Supplier updated successfully!'
            : '✅ Supplier & Batch saved successfully!',
      );

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _showSnackBar('❌ Firestore Error: ${e.message}', isError: true);
      debugPrint('Firestore Error: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('❌ An unexpected error occurred: $e', isError: true);
      debugPrint('General Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBatch() async {
    if (widget.batchToEdit == null) {
      _showSnackBar('No batch selected for deletion.', isError: true);
      return;
    }

    final bool confirmDelete = await _showConfirmationDialog(
      title: 'Confirm Deletion',
      content:
          'Are you sure you want to delete this batch entry? This action cannot be undone.',
    );

    if (!confirmDelete) {
      _showSnackBar('Deletion cancelled.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // The reference of batchToEdit is already correct, as it was fetched from the subcollection.
      await widget.batchToEdit!.reference.delete();
      if (!mounted) return;
      _showSnackBar('🗑️ Batch deleted successfully!');
      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _showSnackBar('❌ Error deleting batch: ${e.message}', isError: true);
      debugPrint('Firestore Delete Error: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        '❌ An unexpected error occurred during deletion: $e',
        isError: true,
      );
      debugPrint('General Delete Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Batch Entry' : 'Supplier & Batch Entry',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Supplier Info
                  const Text(
                    'Supplier Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Supplier Name (with suggestions)
                  TypeAheadField<DocumentSnapshot>(
                    controller: supplierNameController,
                    builder: (context, controller, focusNode) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: _inputDecoration('Supplier Name'),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter supplier name'
                            : null,
                        enabled: !_isEditing || selectedSupplier == null,
                      );
                    },
                    suggestionsCallback: _searchSuppliers,
                    itemBuilder: (_, DocumentSnapshot doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(
                          '${data['contact'] ?? ''} - ${data['address'] ?? ''}',
                        ),
                      );
                    },
                    onSelected: _selectSupplier,
                    // These properties are removed in flutter_typeahead 5.x.x+
                    // hideSuggestionsOnSelect: _isEditing && selectedSupplier != null,
                    // hideOnEmpty: _isEditing && selectedSupplier != null,
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    decoration: _inputDecoration('Contact'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter contact' : null,
                    enabled: !_isEditing || selectedSupplier == null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: _inputDecoration('Address'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter address' : null,
                    enabled: !_isEditing || selectedSupplier == null,
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  /// Product Info
                  const Text(
                    'Product & Batch Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Product Name (with suggestions)
                  TypeAheadField<DocumentSnapshot>(
                    controller: productNameController,
                    builder: (context, controller, focusNode) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: _inputDecoration('Product Name'),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter product name'
                            : null,
                        enabled: !_isEditing || selectedProduct == null,
                      );
                    },
                    suggestionsCallback: _searchProducts,
                    itemBuilder: (_, DocumentSnapshot doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(
                          'Category: ${data['category'] ?? 'N/A'}',
                        ),
                      );
                    },
                    onSelected: _selectProduct,
                    // These properties are removed in flutter_typeahead 5.x.x+
                    // hideSuggestionsOnSelect: _isEditing && selectedProduct != null,
                    // hideOnEmpty: _isEditing && selectedProduct != null,
                  ),
                  const SizedBox(height: 12),

                  /// Batch Info
                  TextFormField(
                    controller: quantityController,
                    decoration: _inputDecoration('Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Enter quantity';
                      }
                      if (int.tryParse(val) == null || int.parse(val) <= 0) {
                        return 'Enter a valid positive quantity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  /// Expiry Date with DatePicker
                  TextFormField(
                    controller: expiryDateController,
                    decoration: _inputDecoration('Expiry Date (YYYY-MM-DD)')
                        .copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.black54,
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Select expiry date'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  /// Save/Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8E6C9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0.1,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.black87,
                            )
                          : Text(
                              _isEditing ? 'Update Batch' : 'Save Batch',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _deleteBatch,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0.1,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.red,
                                )
                              : const Text(
                                  'Delete Batch',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
