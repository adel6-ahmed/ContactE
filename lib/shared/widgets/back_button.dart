import 'package:flutter/material.dart';

import '../theme/colors.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
          icon: Icon(Icons.arrow_back, size: 40, color: Lyellow), // Ensure the icon color is white
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
  }
}