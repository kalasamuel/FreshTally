import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  bool isFormComplete = false;

  @override
  void initState() {
    super.initState();
    //Listens to all changes from all fields
    supplierController.addListener(_checkFormCompletion);
    deliveryController.addListener(_checkFormCompletion);
    expiryController.addListener(_checkFormCompletion);
    quantityController.addListener(_checkFormCompletion);
  }

  void _checkFormCompletion() {
    setState(() {
      isFormComplete =
          supplierController.text.isNotEmpty &&
          deliveryController.text.isNotEmpty &&
          expiryController.text.isNotEmpty &&
          quantityController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    supplierController.dispose();
    deliveryController.dispose();
    expiryController.dispose();
    quantityController.dispose();
    super.dispose();
  }

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
              onPressed: isFormComplete ? () {
                //to add logic for pressing the save product button
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Product'),
            ),
            const SizedBox(height: 50),

            //I do not yet know what this button is really for on this page.
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

  Widget _buildInputField(String label, TextEditingController controller) {
    bool isDateField = label.toLowerCase().contains("expiry") || label.toLowerCase().contains("delivery");

    return Card(
      color: Colors.grey[200],
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextField(
          controller: controller,
          readOnly: isDateField,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onTap: isDateField
              ? () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat(
                      'd MMMM yyyy',
                    ).format(pickedDate);
                    setState(() {
                      controller.text = formattedDate;
                    });
                  }
                }
              : null,//Only allow date picker for delivery and expiry fields 
        ),
      ),
    );
  }
}
