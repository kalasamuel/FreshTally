import 'package:demoapp/list.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: WhatsApp()));

class WhatsApp extends StatefulWidget {
  @override
  State<WhatsApp> createState() => _WhatsAppState();
}

class _WhatsAppState extends State<WhatsApp> {
  int level = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "WhatsApp",
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuoteList()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            level += 1;
          });
        },
        child: Icon(Icons.add),

        backgroundColor: Colors.cyan[300],
      ),

      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/Heidelburg.jpg"),
                radius: 40.0,
              ),
            ),

            Divider(height: 60.0, color: Colors.cyan[200]),
            Text(
              "NAME",
              style: TextStyle(color: Colors.white, letterSpacing: 2.0),
            ),
            SizedBox(height: 10.0),
            Text(
              "Melissa",
              style: TextStyle(
                color: Colors.purple[300],
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "CURRENT LEVEL",
              style: TextStyle(color: Colors.white, letterSpacing: 2.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '$level',
              style: TextStyle(
                color: Colors.purple[300],
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.email, color: Colors.purple[400]),
                SizedBox(width: 10.0),
                Text(
                  "melissa@example.com",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2.0,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
