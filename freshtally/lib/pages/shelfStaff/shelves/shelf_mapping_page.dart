import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';

enum ShelfPosition { top, middle, bottom }

class ShelfMappingPage extends StatefulWidget {
  final String supermarketId;

  const ShelfMappingPage({super.key, required this.supermarketId});

  @override
  State<ShelfMappingPage> createState() => _ShelfMappingPageState();
}

class _ShelfMappingPageState extends State<ShelfMappingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _currentPriceController =
      TextEditingController(); // Renamed from _priceController
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _skuController =
      TextEditingController(); // Added SKU controller

  String? _selectedFloor;
  String? _selectedShelf;
  ShelfPosition? _shelfPosition = ShelfPosition.top;
  DocumentSnapshot? _selectedProduct;
  File? _image;
  bool _isLoading = false;

  final List<String> _floors = ['1', '2', '3', '4'];
  final List<String> _shelves = ['1', '2', '3', '4', '5'];

  @override
  void dispose() {
    _productController.dispose();
    _currentPriceController.dispose(); // Disposing renamed controller
    _categoryController.dispose();
    _skuController.dispose(); // Dispose SKU controller
    super.dispose();
  }

  // --- Adjusted _searchProducts to match the new path ---
  Future<List<DocumentSnapshot>> _searchProducts(String pattern) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(widget.supermarketId)
        .collection('products')
        .where(
          'name_lower',
          isGreaterThanOrEqualTo: pattern.toLowerCase(),
        ) // Search by name_lower
        .where(
          'name_lower',
          isLessThanOrEqualTo: '${pattern.toLowerCase()}\uf8ff',
        )
        .limit(5)
        .get();
    return snapshot.docs;
  }

  Future<List<String>> _fetchCategories(String pattern) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();
    return snapshot.docs
        .map((e) => e['name'] as String)
        .where((cat) => cat.toLowerCase().contains(pattern.toLowerCase()))
        .toList();
  }

  // --- Adjusted _selectProduct to handle new fields ---
  void _selectProduct(DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>;
    setState(() {
      _selectedProduct = product;
      _productController.text = data['name'] ?? '';
      _currentPriceController.text =
          data['current_price']?.toString() ?? ''; // Use current_price
      _categoryController.text = data['category'] ?? '';
      _skuController.text = data['sku'] ?? ''; // Set SKU

      final productFloorNum = data['location']?['floor'];
      final productShelfNum = data['location']?['shelf'];
      final String? productFloor = productFloorNum?.toString();
      final String? productShelf = productShelfNum?.toString();

      _selectedFloor = _floors.contains(productFloor) ? productFloor : null;
      _selectedShelf = _shelves.contains(productShelf) ? productShelf : null;

      final String? pos = data['location']?['position']
          ?.toString()
          .toLowerCase();
      _shelfPosition = ShelfPosition.values.firstWhere(
        (e) => e.name.toLowerCase() == pos,
        orElse: () => ShelfPosition.top,
      );
    });
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String?> _uploadImage(String productName) async {
    if (_image == null) return null;
    final ref = FirebaseStorage.instance.ref().child(
      'product_images/${productName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(_image!);
    return await ref.getDownloadURL();
  }

  // --- Adjusted _saveProduct to handle new fields and path ---
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFloor == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a Floor.')));
      return;
    }
    if (_selectedShelf == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Shelf Number.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_productController.text.trim());
      }

      final String productName = _productController.text.trim();
      final productData = {
        'created_at': _selectedProduct != null
            ? (_selectedProduct!.data()
                  as Map<
                    String,
                    dynamic
                  >)['created_at'] // Keep existing created_at if updating
            : FieldValue.serverTimestamp(), // Set created_at only on new products
        'current_price':
            double.tryParse(_currentPriceController.text) ??
            0, // Use current_price
        'last_sold_at':
            FieldValue.serverTimestamp(), // Update last_sold_at on save (can be adjusted based on actual sales)
        'name': productName,
        'name_lower': productName
            .toLowerCase(), // Store lowercase name for searching
        // 'sku': _skuController.text.trim(), // Save SKU
        'supermarketId': widget.supermarketId, // Save supermarketId
        'category': _categoryController.text.trim(),
        'location': {
          'floor': int.tryParse(_selectedFloor!),
          'shelf': int.tryParse(_selectedShelf!),
          'position': _shelfPosition.toString().split('.').last,
        },
        'updated_at': FieldValue.serverTimestamp(),
        if (imageUrl != null) 'image_url': imageUrl,
      };

      if (_selectedProduct != null) {
        // If updating an existing product
        await FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('products')
            .doc(_selectedProduct!.id) // Use the existing document ID
            .update(productData);
      } else {
        // If adding a new product
        await FirebaseFirestore.instance
            .collection('supermarkets')
            .doc(widget.supermarketId)
            .collection('products')
            .add(productData); // Firestore will generate a new document ID
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product saved successfully!')),
      );
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _productController.clear();
      _currentPriceController.clear(); // Clear renamed controller
      _categoryController.clear();
      _skuController.clear(); // Clear SKU controller
      _selectedFloor = null;
      _selectedShelf = null;
      _shelfPosition = ShelfPosition.top;
      _image = null;
      _selectedProduct = null;
    });
  }

  // --- Adjusted _deleteProduct to match the new path ---
  Future<void> _deleteProduct() async {
    if (_selectedProduct == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('supermarkets')
          .doc(widget.supermarketId)
          .collection('products')
          .doc(_selectedProduct!.id) // Use the existing document ID
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🗑 Product deleted!')));
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0.0,
        title: const Text(
          'Shelf Mapping',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  TypeAheadField<DocumentSnapshot>(
                    controller: _productController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: _buildInputDecoration(
                          hintText: 'Enter product name',
                          labelText: 'Product Name',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      );
                    },
                    suggestionsCallback: _searchProducts,
                    itemBuilder: (context, DocumentSnapshot product) {
                      final data = product.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(
                          '${data['current_price']} UGX',
                        ), // Display current_price
                      );
                    },
                    onSelected: _selectProduct,
                  ),
                  const SizedBox(height: 16),

                  _buildStyledTextFormField(
                    controller:
                        _currentPriceController, // Use current_price controller
                    hintText: 'Enter current price',
                    labelText: 'Current Price',
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || double.tryParse(val) == null
                        ? 'Enter valid price'
                        : null,
                  ),

                  // _buildStyledTextFormField(
                  //   // Added SKU input
                  //   controller: _skuController,
                  //   hintText: 'Enter SKU',
                  //   labelText: 'SKU',
                  //   validator: (val) => val == null || val.isEmpty
                  //       ? 'SKU cannot be empty'
                  //       : null,
                  // ),
                  const SizedBox(height: 2),
                  TypeAheadField<String>(
                    controller: _categoryController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: _buildInputDecoration(
                          hintText: 'Enter category',
                          labelText: 'Category',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      );
                    },
                    suggestionsCallback: _fetchCategories,
                    itemBuilder: (context, String category) =>
                        ListTile(title: Text(category)),
                    onSelected: (val) =>
                        setState(() => _categoryController.text = val),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Shelf Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildStyledDropdown(
                    value: _selectedFloor,
                    hint: 'Select Floor',
                    items: _floors,
                    onChanged: (val) => setState(() => _selectedFloor = val),
                  ),
                  const SizedBox(height: 16),

                  _buildStyledDropdown(
                    value: _selectedShelf,
                    hint: 'Select Shelf Number',
                    items: _shelves,
                    onChanged: (val) => setState(() => _selectedShelf = val),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Shelf Position:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Column(
                    children: ShelfPosition.values.map((pos) {
                      return RadioListTile<ShelfPosition>(
                        title: Text(
                          pos.name[0].toUpperCase() + pos.name.substring(1),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        value: pos,
                        groupValue: _shelfPosition,
                        onChanged: (value) =>
                            setState(() => _shelfPosition = value),
                        activeColor: const Color(0xFF4CAF50),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Product Image:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo, color: Colors.black87),
                        label: const Text(
                          'Select Image',
                          style: TextStyle(color: Colors.black87),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F6FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                          elevation: 0.1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
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
                              _selectedProduct != null
                                  ? 'Update Product'
                                  : 'Add Product',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (_selectedProduct != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _deleteProduct,
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
                                  'Delete Product',
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

  InputDecoration _buildInputDecoration({
    required String hintText,
    required String labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: _buildInputDecoration(
          hintText: hintText,
          labelText: labelText,
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    String? displayValue = (value != null && items.contains(value))
        ? value
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: displayValue,
          hint: Text(
            hint,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String itemValue) {
            return DropdownMenuItem<String>(
              value: itemValue,
              child: Text(itemValue),
            );
          }).toList(),
        ),
      ),
    );
  }
}
