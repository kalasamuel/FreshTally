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
      //I did body at once because I wanted to make the top part customized. 
      //I have not even used an appbar for that reason.
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
              ],
            ),

            const SizedBox(height: 20),
            
            //The Cards for the different functions.
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  dashboardCard(Icons.bar_chart, 'Analytics', Colors.grey[200]),
                  dashboardCard(Icons.calendar_month, 'Expiry date Tracker', Colors.pink[200]),
                  dashboardCard(Icons.people, 'User Role Management', Colors.green[100]),
                  dashboardCard(Icons.notifications, 'Notifications', Colors.yellow[300]),
                  dashboardCard(Icons.map, 'Shelf Mapping', Colors.teal[200]),
                  dashboardCard(Icons.inventory, 'Inventory List', Colors.green[200]),
                  dashboardCard(Icons.lightbulb, 'Smart Suggestions', Colors.orange[200]),
                  dashboardCard(Icons.sync, 'Sync Status', Colors.grey[300]),
                  dashboardCard(Icons.qr_code_2, 'Product Entry', Colors.green[100]),
                ],
              )
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(IconData icon, String title, Color? bgColor) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black54),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
