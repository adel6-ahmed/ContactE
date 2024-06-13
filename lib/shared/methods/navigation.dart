import 'package:flutter/material.dart';

void GoTo({required BuildContext context, required Widget screen}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => screen,
    ),
  );
}
void GoToWithNoBackButton({required BuildContext context, required Widget screen}) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => screen,
    ),
  );
}


void GoToReplacement({required BuildContext context, required Widget screen}) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}



