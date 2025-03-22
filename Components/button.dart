import 'package:flutter/material.dart';

import 'colors.dart';

class Button extends StatelessWidget {
  final String label;
  final VoidCallback press;
  const Button({super.key, required this.label, required this.press});

  @override
  Widget build(BuildContext context) {
    // diseño responsivo

    Size size = MediaQuery.of(context).size;
    return  Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      width: size.width * 0.9,
      height: 55,

      decoration: BoxDecoration(
      color : primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      
      child: TextButton(
          onPressed: press,
          child: Text(label, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
    );
  }
}
