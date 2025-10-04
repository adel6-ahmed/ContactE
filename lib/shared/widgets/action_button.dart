import 'package:flutter/material.dart';
import 'package:sad/shared/theme/texet.dart';

import '../theme/colors.dart';

export 'animated_action_button.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.action,
    this.buttonColor,
    this.fontSize,
    this.buttonWidth,
  });

  final String title;
  final Color? buttonColor;
  final double? fontSize; // New parameter for font size
  final VoidCallback action;
  final double? buttonWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? Lyellow,
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

class ActionButtonWithIcon extends StatelessWidget {
  const ActionButtonWithIcon(
      {super.key,
      required this.title,
      required this.icon,
      required this.action,
      this.buttonColor,
      this.fontSize});

  final String title;
  final Color? buttonColor;
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
        backgroundColor: buttonColor ?? Lyellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}

// Re-export animated action button so older call sites that expect
// AnimatedActionButton(...) can resolve. The real widget lives in
// animated_action_button.dart
// (export is already at the top)
