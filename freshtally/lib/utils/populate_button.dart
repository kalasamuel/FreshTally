import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Freshtally/utils/firestore_uploader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Upload Products')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await uploadProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Products uploaded!')),
              );
            },
            child: const Text('Upload Products to Firestore'),
          ),
        ),
      ),
    );
  }
}
