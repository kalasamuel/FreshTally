import 'package:flutter/material.dart';

const List<Map<String, dynamic>> products = [
  {
    'name': 'Chocolate Bar',
    'price': 2000.0,
    'discount': 20.0,
    'locations': [
      {'floor': 1, 'shelf': 3, 'position': 'top'},
      {'floor': 2, 'shelf': 1, 'position': 'middle'},
    ],
  },
  {
    'name': 'Fresh Milk 1L',
    'price': 3500.0,
    'discount': null,
    'locations': [
      {'floor': 1, 'shelf': 5, 'position': 'middle'},
    ],
  },
  {
    'name': 'Apple Juice 500ml',
    'price': 1800.0,
    'discount': 10.0,
    'locations': [
      {'floor': 2, 'shelf': 8, 'position': 'bottom'},
      {'floor': 1, 'shelf': 2, 'position': 'top'},
    ],
  },
];

class ProductAllocationView extends StatelessWidget {
  const ProductAllocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Locations & Pricing')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final locations = product['locations'] as List<dynamic>;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ${product['price']} UGX',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (product['discount'] != null)
                    Text(
                      'Discount: ${product['discount']}%',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Locations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...locations.map(
                    (loc) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(_locationString(loc)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String _locationString(dynamic loc) {
  if (loc is Map &&
      loc.containsKey('floor') &&
      loc.containsKey('shelf') &&
      loc.containsKey('position')) {
    return 'Floor: ${loc['floor']}, Shelf: ${loc['shelf']}, Position: ${loc['position']}';
  }
  return loc.toString();
}
