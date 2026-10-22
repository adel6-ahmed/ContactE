import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Material 3 theme for ContactE (dark-first, Arabic-first typography).
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppTokens.amber,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppTokens.amber,
    onPrimary: AppTokens.onAmber,
    secondary: AppTokens.info,
    surface: AppTokens.surface,
    onSurface: AppTokens.textPrimary,
    onSurfaceVariant: AppTokens.textSecondary,
    surfaceContainerLowest: AppTokens.background,
    surfaceContainerLow: AppTokens.surface,
    surfaceContainer: AppTokens.surfaceRaised,
    surfaceContainerHigh: AppTokens.surfaceHigh,
    outline: AppTokens.outline,
    outlineVariant: AppTokens.outline,
    error: AppTokens.danger,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark);
  final text = GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme).apply(
    bodyColor: AppTokens.textPrimary,
    displayColor: AppTokens.textPrimary,
  );
  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd));

  return base.copyWith(
    scaffoldBackgroundColor: AppTokens.background,
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: text.bodyMedium?.copyWith(height: 1.5, color: AppTokens.textSecondary),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppTokens.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      iconTheme: const IconThemeData(color: AppTokens.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppTokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: const BorderSide(color: AppTokens.outline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: rounded,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: rounded,
        side: const BorderSide(color: AppTokens.outline),
        foregroundColor: AppTokens.textPrimary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 44), foregroundColor: AppTokens.amber),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.surfaceRaised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppTokens.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppTokens.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppTokens.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppTokens.amber, width: 1.6),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppTokens.surfaceRaised,
      side: const BorderSide(color: AppTokens.outline),
      labelStyle: text.labelMedium?.copyWith(color: AppTokens.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppTokens.surface,
      indicatorColor: AppTokens.amber.withValues(alpha: 0.18),
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) => text.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppTokens.amber : AppTokens.textMuted,
          )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? AppTokens.amber : AppTokens.textMuted,
          )),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppTokens.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTokens.surfaceHigh,
      contentTextStyle: text.bodyMedium?.copyWith(color: AppTokens.textPrimary),
      shape: rounded,
    ),
    dividerTheme: const DividerThemeData(color: AppTokens.outline, space: 1),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppTokens.amber,
      foregroundColor: AppTokens.onAmber,
    ),
  );
}
