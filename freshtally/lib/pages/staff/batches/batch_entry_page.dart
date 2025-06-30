import 'package:flutter/material.dart';

class BatchDetailsEntry extends StatefulWidget {
  const BatchDetailsEntry({super.key});

  @override
  State<BatchDetailsEntry> createState() => _BatchDetailsEntryState();
}

class _BatchDetailsEntryState extends State<BatchDetailsEntry> {
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'Batch Detail Entry',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputField("Supplier", supplierController),
            _buildInputField("Delivery", deliveryController),
            _buildInputField("Expiry Date", expiryController),
            _buildInputField("Quantity", quantityController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Product'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Need to assign shellf'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
