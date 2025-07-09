import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierEntryPage extends StatefulWidget {
  const SupplierEntryPage({super.key});

  @override
  State<SupplierEntryPage> createState() => _SupplierEntryPageState();
}

class _SupplierEntryPageState extends State<SupplierEntryPage> {
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Supplier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Supplier Name'),
            ),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSupplier,
              child: const Text('Save Supplier'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSupplier() {
    FirebaseFirestore.instance.collection('suppliers').add({
      'name': nameController.text,
      'contact': contactController.text,
      'address': addressController.text,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Supplier added')));
    Navigator.pop(context);
  }
}
