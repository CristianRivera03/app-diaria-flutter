import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String label;
  final VoidCallback press;
  final Color? color;
  final Color? textColor;

  const Button({
    super.key,
    required this.label,
    required this.press,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: press,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
