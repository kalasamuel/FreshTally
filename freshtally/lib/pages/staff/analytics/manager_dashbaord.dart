import 'package:flutter/material.dart';

class ManagerDashboard extends StatelessWidget {
  final String supermarketName;
  final String location;

  const ManagerDashboard({
    super.key,
    required this.supermarketName,
    required this.location,
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //I will add an appbar to show a back button and the supermarket name and location and the settings action later.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              children: [
                const BackButton(),
                const SizedBox(width: 10),
                Text(
                  supermarketName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton( 
                    icon: Icon(Icons.settings),
                    iconSize: 30,
                    color: Colors.grey[800],
                    onPressed: () {
                      //add logic for going to settings page
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            )
            ],

          ),
        ),
      ),
    );
  }
}
