// shared/theme/theme.dart
import 'package:flutter/material.dart';

import 'colors.dart'; // هنا ألوانك المخصصة مثل Ldark, white, transparent
import 'texet.dart';  // هنا النصوص/ستايلات الخطوط مثل h1, h2, body, caption

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Ldark, // لون خلفية التطبيق
  appBarTheme: const AppBarTheme(
    backgroundColor: transparent, // شفاف
    titleSpacing: 0,              // مسافة العنوان صفر
    elevation: 0,                 // بدون ظل
    iconTheme: IconThemeData(color: white),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: white,       // لون زر الفلواتنج أبيض
  ),
  textTheme: TextTheme(
    displayLarge: h1,        // أكبر عنوان
    displayMedium: h2,       // عنوان متوسط
    displaySmall: h3,        // عنوان صغير
    headlineMedium: h4,      // عنوان فرعي
    headlineSmall: h5,       // عنوان فرعي أصغر
    titleLarge: title1,      // عنوان رئيسي للنصوص
    titleSmall: title2,      // عنوان فرعي للنصوص
    bodyLarge: body,         // النصوص الرئيسية
    bodySmall: caption,      // النصوص الصغيرة/تلميحات
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: white,           // اللون الأساسي
    secondary: white,         // اللون الثانوي
  ),
);

// A dark theme variant. Main app toggles between appTheme and darkTheme.
final ThemeData darkTheme = appTheme.copyWith(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Ldark,
  appBarTheme: appTheme.appBarTheme.copyWith(
    backgroundColor: Ldark,
    iconTheme: const IconThemeData(color: Lyellow),
  ),
  floatingActionButtonTheme:
      appTheme.floatingActionButtonTheme.copyWith(backgroundColor: Lyellow),
  textTheme: appTheme.textTheme,
  colorScheme: appTheme.colorScheme.copyWith(
    primary: Lyellow,
    secondary: Lyellow,
  ),
);
