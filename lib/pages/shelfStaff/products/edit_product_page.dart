import 'package:flutter/material.dart';
import 'package:freshtally/pages/shelfStaff/products/product_entry_page.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({super.key});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final bool _isFormValid = false;

  final List<String> _categories = [
    'Beverages',
    'Snacks',
    'Dairy',
    'Produce',
    'Statinary',
    'toiletries',
    'technology',
    'Household',
    'Frozen Foods',
    'Bakery',
    'Other',
  ];
  String? _selectedCategory;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _productSuplierController =
      TextEditingController();
  final TextEditingController _productExpiryController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Edit Product Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/barcode.jpg', // <-- your barcode image path
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(width: 16.0),
                    const Text(
                      'Scan Barcode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(
                thickness: 2.0,
                color: Color.fromARGB(251, 0, 0, 0),
              ),
              const SizedBox(height: 16.0),
              FormTextField(
                controller: _productNameController,
                hintText: 'Product Name',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product Name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              FormTextField(
                controller: _productPriceController,
                hintText: "Product price",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (value) =>
                    value == null ? "Select a category" : null,
              ),
              const SizedBox(height: 16),
              FormTextField(
                controller: _productSuplierController,
                hintText: 'Supplier',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product quantity';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              FormTextField(
                controller: _productExpiryController,
                hintText: 'Expiry Date',
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product quantity';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              FormTextField(
                controller: _productQuantityController,
                hintText: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 34),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Add product logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product details updated successfully!'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Add Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1.5),
              const SizedBox(height: 24),
              // Need to assign shelf? Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.green,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Assign shelf logic here
                },
                child: const Text(
                  "Need to assign shelf?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
