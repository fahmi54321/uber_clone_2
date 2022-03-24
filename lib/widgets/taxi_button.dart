import 'package:flutter/material.dart';

class TaxiButton extends StatelessWidget {
  final String title;
  final Color color;
  VoidCallback onPressed;

  TaxiButton({
    @required this.title,
    @required this.color,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      textColor: Colors.white,
      color: color,
      child: Container(
          height: 50,
          child: Center(
              child: Text(
            title,
            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
          ))),
      onPressed: onPressed,
    );
  }
}
