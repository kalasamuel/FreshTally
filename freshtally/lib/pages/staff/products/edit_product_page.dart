import 'package:flutter/material.dart';
import 'package:freshtally/pages/staff/products/product_entry_page.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({super.key});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final bool _isFormValid = false;

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
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset(
                  'assets/images/barcode.jpg', // <-- your barcode image path
                  height: 32,
                  width: 32,
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
                onPressed: _isFormValid
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account created successfully!'),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],

                  padding: const EdgeInsets.symmetric(vertical: 16.0),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
