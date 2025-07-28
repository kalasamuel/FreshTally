import 'package:flutter/material.dart';
import 'quotes.dart';

class QuoteList extends StatefulWidget {
  //const QuoteList({super.key});

  @override
  _QuoteListState createState() => _QuoteListState();
}

class _QuoteListState extends State<QuoteList> {
  List<Quote> quotes = [
    Quote(text: "You are more than enough.", author: "Oscar wild"),
    Quote(text: "You are loved and cherished", author: "Blue Ivy"),
    Quote(text: "You must be earned", author: "Shuga"),
  ];

  Widget quoteTemplate(quote) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              quote.text,
              style: TextStyle(fontSize: 18.0, color: Colors.cyan[300]),
            ),
            SizedBox(height: 6.0),
            Text(
              quote.author,
              style: TextStyle(fontSize: 18.0, color: Colors.cyan[300]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Amazing Quotes"),
        centerTitle: true,
        backgroundColor: Colors.cyan[200],
      ),

      body: Column(
        children: quotes.map((quote) {
          return quoteTemplate(quote);
        }).toList(),
      ),
    );
  }
}
