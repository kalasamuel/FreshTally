import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';

enum ShelfPosition { top, middle, bottom }

class ShelfMappingPage extends StatefulWidget {
  const ShelfMappingPage({super.key, required String supermarketId});

  @override
  State<ShelfMappingPage> createState() => _ShelfMappingPageState();
}

class _ShelfMappingPageState extends State<ShelfMappingPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String? _selectedFloor; // Keep as String for dropdown value
  String? _selectedShelf; // Keep as String for dropdown value
  ShelfPosition? _shelfPosition = ShelfPosition.top;

  DocumentSnapshot? _selectedProduct;
  File? _image;
  bool _isLoading = false;

  // --- HARDCODED FLOOR AND SHELF OPTIONS ---
  final List<String> _floors = [
    '1',
    '2',
    '3',
    '4',
  ]; // Changed to strings to match dropdown value type
  final List<String> _shelves = ['1', '2', '3', '4', '5']; // Changed to strings
  // ------------------------------------------

  @override
  void initState() {
    super.initState();
    // Removed _loadFloorsAndShelves() as options are now hardcoded
  }

  @override
  void dispose() {
    _productController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<List<DocumentSnapshot>> _searchProducts(String pattern) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: pattern)
        .where('name', isLessThanOrEqualTo: '$pattern\uf8ff')
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

  void _selectProduct(DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>;
    setState(() {
      _selectedProduct = product;
      _productController.text = data['name'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _categoryController.text = data['category'] ?? '';

      // Set selected floor and shelf if present in the product data
      // Read floor and shelf as numbers from Firestore
      final productFloorNum = data['location']?['floor'];
      final productShelfNum = data['location']?['shelf'];

      // Convert numbers to string for dropdown selection
      final String? productFloor = productFloorNum?.toString();
      final String? productShelf = productShelfNum?.toString();

      // Now, check against the hardcoded lists
      if (_floors.contains(productFloor)) {
        _selectedFloor = productFloor;
      } else {
        _selectedFloor = null; // Reset if invalid or not in hardcoded list
      }

      if (_shelves.contains(productShelf)) {
        _selectedShelf = productShelf;
      } else {
        _selectedShelf = null; // Reset if invalid or not in hardcoded list
      }

      final String? pos = data['location']?['position']
          ?.toString()
          .toLowerCase();
      _shelfPosition = ShelfPosition.values.firstWhere(
        (e) => e.name.toLowerCase() == pos, // Compare lowercase names
        orElse: () => ShelfPosition.top, // Default if not found
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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Added validation for hardcoded dropdowns
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

      // Convert selected floor and shelf from String to int for Firestore
      final int? floorNumber = int.tryParse(_selectedFloor!);
      final int? shelfNumber = int.tryParse(_selectedShelf!);

      // Add null checks for safety, although the validator should catch this
      if (floorNumber == null || shelfNumber == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Floor or Shelf number could not be parsed.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final productData = {
        'name': _productController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'category': _categoryController.text.trim(),
        'location': {
          'floor': floorNumber, // Store as int
          'shelf': shelfNumber, // Store as int
          'position': _shelfPosition
              .toString()
              .split('.')
              .last, // Store as is (e.g., "top")
        },
        'updated_at': FieldValue.serverTimestamp(),
        if (imageUrl != null) 'image_url': imageUrl,
      };

      if (_selectedProduct != null) {
        await _selectedProduct!.reference.update(productData);
      } else {
        await FirebaseFirestore.instance
            .collection('products')
            .add(productData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct() async {
    if (_selectedProduct == null) return;

    setState(() => _isLoading = true);

    try {
      await _selectedProduct!.reference.delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🗑 Product deleted!')));
      Navigator.pop(context);
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
      backgroundColor: const Color(0xFFFFFFFF), // Set background color
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // AppBar background color
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

                  // Product Name Field with TypeAhead
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
                        subtitle: Text('${data['price']} UGX'),
                      );
                    },
                    onSelected: (DocumentSnapshot product) {
                      _selectProduct(product);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price Field
                  _buildStyledTextFormField(
                    controller: _priceController,
                    hintText: 'Enter price',
                    labelText: 'Price',
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || double.tryParse(val) == null
                        ? 'Enter valid price'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Category Field with TypeAhead
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
                    onSelected: (val) {
                      setState(() => _categoryController.text = val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Shelf Details Section Title
                  const Text(
                    'Shelf Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Floor Dropdown (now hardcoded)
                  _buildStyledDropdown(
                    value: _selectedFloor,
                    hint: 'Select Floor',
                    items: _floors, // Using hardcoded _floors
                    onChanged: (val) {
                      print('DEBUG: Floor selected: $val');
                      setState(() => _selectedFloor = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Shelf Number Dropdown (now hardcoded)
                  _buildStyledDropdown(
                    value: _selectedShelf,
                    hint: 'Select Shelf Number',
                    items: _shelves, // Using hardcoded _shelves
                    onChanged: (val) {
                      print('DEBUG: Shelf selected: $val');
                      setState(() => _selectedShelf = val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Shelf Position Radio Buttons
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
                        onChanged: (ShelfPosition? value) {
                          setState(() {
                            _shelfPosition = value;
                          });
                        },
                        activeColor: const Color(0xFF4CAF50),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Product Image Section
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
                          backgroundColor: const Color(
                            0xFFF5F6FA,
                          ), // Match background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none, // No border
                          ),
                          elevation: 0.1, // Slight elevation
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Increased spacing
                      if (_image != null)
                        ClipRRect(
                          // Clip image to rounded rectangle
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

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFC8E6C9,
                        ), // Light green background
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
                            elevation: 0.1, // Slight elevation
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

  // --- Helper Widgets for consistent styling ---

  InputDecoration _buildInputDecoration({
    required String hintText,
    required String labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: const Color(0xFFF5F6FA), // Background color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF4CAF50),
          width: 1.5,
        ), // Green border on focus
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54, // Lighter hint text
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
    // If the current value is not in the items list, set it to null
    // This is crucial for the dropdown to be functional if the value is invalid.
    String? displayValue = (value != null && items.contains(value))
        ? value
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA), // Background color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent), // No border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: displayValue, // Use displayValue here
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
