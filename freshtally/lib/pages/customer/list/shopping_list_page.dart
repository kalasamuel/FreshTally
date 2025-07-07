import 'package:flutter/material.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ['Milk', 'Bread', 'Apples'];

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => CheckboxListTile(
                  value: i.isEven,
                  onChanged: (v) {},
                  title: Text('${items[i]}  x${i + 1}'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Clear Found Items'),
            ),
          ],
        ),
      ),
    );
  }
}
