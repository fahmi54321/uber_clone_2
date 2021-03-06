import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {

  static const String id = 'main';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Uber clone'),),
      body: Center(
        child: MaterialButton(
          onPressed: (){
            DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('ges');
            databaseReference.set('IsConnected');
          },
          height: 50,
          minWidth: 300,
          color: Colors.green,
          child: Text('Text Connection'),
        ),
      ),
    );
  }
}
