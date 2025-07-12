// import 'package:flutter/material.dart';

// class ProductEntryPage extends StatefulWidget {
//   const ProductEntryPage({super.key});

//   @override
//   State<ProductEntryPage> createState() => _ProductEntryPageState();
// }

// class _ProductEntryPageState extends State<ProductEntryPage> {
//   final nameController = TextEditingController();
//   final categoryController = TextEditingController();
//   final priceController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//       appBar: AppBar(
//         title: const Text(
//           'Add Product',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 24.0,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Section Title
//                 const Text(
//                   'Product Details',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Product Name Field
//                 TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Product Name',
//                     labelStyle: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFFF5F6FA),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 16),

//                 // Category Field
//                 TextField(
//                   controller: categoryController,
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     labelStyle: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFFF5F6FA),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 16),

//                 // Price Field
//                 TextField(
//                   controller: priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     labelStyle: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFFF5F6FA),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 32),

//                 // Save Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _saveProduct,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFC8E6C9),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0.1,
//                     ),
//                     child: const Text(
//                       'Save Product',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _saveProduct() {
//     // Simulate saving (remove Firestore for static UI preview)
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Product added')));
//     Navigator.pop(context);
//   }
// }
