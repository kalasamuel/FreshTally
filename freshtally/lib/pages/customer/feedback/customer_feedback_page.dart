import 'package:flutter/material.dart';

class CustomerFeedbackPage extends StatelessWidget {
  const CustomerFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (_, i) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product ${i + 1}'),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(Icons.star, color: Colors.orange),
                          ),
                        ),
                        const TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
