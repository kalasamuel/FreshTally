import 'package:flutter/material.dart';

class ExpiredDetailsPage extends StatelessWidget {
  final String productName;
  final String productCode;
  final DateTime expiryDate;
  final int quantity;
  final String shelfLocation;

  const ExpiredDetailsPage({
    super.key,
    required this.productName,
    required this.productCode,
    required this.expiryDate,
    required this.quantity,
    required this.shelfLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expired Product Details'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red[700],
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 32, thickness: 1.2),
                _detailRow('Product Code:', productCode),
                _detailRow(
                  'Expiry Date:',
                  "${expiryDate.toLocal()}".split(' ')[0],
                ),
                _detailRow('Quantity:', quantity.toString()),
                _detailRow('Shelf Location:', shelfLocation),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Remove from Shelf'),
                    onPressed: () {
                      // TODO: Implement removal logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product removal action triggered.'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ), //Rows
    );
  }
}
