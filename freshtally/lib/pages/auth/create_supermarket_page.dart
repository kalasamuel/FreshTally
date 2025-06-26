import 'package:flutter/material.dart';

class CreateSupermarketPage extends StatefulWidget {
  @override
  _CreateSupermarketPageState createState() => _CreateSupermarketPageState();
}

class _CreateSupermarketPageState extends State<CreateSupermarketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supermarketNameController =
      TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),

            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Supermarket',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),

                  TextFormField(
                    controller: _supermarketNameController,
                    decoration: InputDecoration(
                      labelText: 'Supermarket Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 29, 124, 32),

                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a supermarket name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Text("Manager details"),

                  SizedBox(height: 16),
                  TextFormField(
                    controller: _managerNameController,
                    decoration: InputDecoration(
                      labelText: 'Manager Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 29, 124, 32),
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the manager\'s name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
