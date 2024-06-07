import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color textColor;

  const ActionButton({
    required this.title,
    required this.onPressed,
    required this.buttonColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(color: textColor), // Use provided text color
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor, // Using ButtonColor from colors.dart
      ),
    );
  }
}