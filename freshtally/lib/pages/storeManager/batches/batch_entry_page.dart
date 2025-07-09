import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BatchEntryPage extends StatefulWidget {
  const BatchEntryPage({super.key});

  @override
  State<BatchEntryPage> createState() => _BatchEntryPageState();
}

class _BatchEntryPageState extends State<BatchEntryPage> {
  final productIdController = TextEditingController();
  final supplierIdController = TextEditingController();
  final quantityController = TextEditingController();
  final expiryDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Batch')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: productIdController,
              decoration: const InputDecoration(labelText: 'Product ID'),
            ),
            TextField(
              controller: supplierIdController,
              decoration: const InputDecoration(labelText: 'Supplier ID'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: expiryDateController,
              decoration: const InputDecoration(
                labelText: 'Expiry Date (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBatch,
              child: const Text('Save Batch'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBatch() {
    FirebaseFirestore.instance.collection('batches').add({
      'product_id': productIdController.text,
      'supplier_id': supplierIdController.text,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'expiry_date': Timestamp.fromDate(
        DateTime.parse(expiryDateController.text),
      ),
      'delivery_date': Timestamp.now(),
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Batch added')));
    Navigator.pop(context);
  }
}
