import 'package:flutter/material.dart';

import 'colors.dart';
import 'texet.dart';

var appTheme = ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: transparent,
    titleSpacing: 0,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: white,
  ),
  scaffoldBackgroundColor: Ldark,
  textTheme: TextTheme(
    displayLarge: h1,
    displayMedium: h2,
    displaySmall: h3,
    headlineMedium: h4,
    headlineSmall: h5,
    titleLarge: title1,
    titleSmall: title2,
    bodyLarge: body,
    bodySmall: caption,
  ),
);
