import 'package:flutter/material.dart';
import 'package:sad/shared/theme/texet.dart';

import '../theme/colors.dart';

class action_button extends StatelessWidget {
  action_button({
    Key? key,
    required this.title,
    required this.action,
    this.ButtonColor,
    this.fontSize,
    this.buttonWidth,
  });
  final String title;
  final Color? ButtonColor;
  final double? fontSize; // New parameter for font size
  final Function() action;
  double? buttonWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width:  buttonWidth,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: ButtonColor ?? Lyellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          title,
          style: title1Bold.copyWith(color: Ldark),
        ),
      ),
    );
  }
}

class action_buttonWithIcon extends StatelessWidget {
  action_buttonWithIcon(
      {Key? key,
      required this.title,
      required this.icon,
      required this.action,
      this.ButtonColor,
      this.fontSize});
  final String title;
  final Color? ButtonColor;
  final IconData icon;
  final VoidCallback action;
  final double? fontSize; // New parameter for font size

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(
        title,
        style:
            TextStyle(color: Ldark, fontSize: fontSize), // Apply font size here
      ),
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: ButtonColor ?? Lyellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
