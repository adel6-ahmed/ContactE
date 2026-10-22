import 'package:flutter/material.dart';

/// Design tokens for ContactE (dark-first). One amber accent on calm, near-black surfaces;
/// colours meet WCAG AA contrast for text on the surfaces they are used on.
abstract final class AppTokens {
  // Surfaces (elevation by lightness, not shadows)
  static const background = Color(0xFF0E1116);
  static const surface = Color(0xFF151A21);
  static const surfaceRaised = Color(0xFF1C222B);
  static const surfaceHigh = Color(0xFF242B36);
  static const outline = Color(0xFF2E3642);

  // Text
  static const textPrimary = Color(0xFFEEF1F5);
  static const textSecondary = Color(0xFFB4BCC8);
  static const textMuted = Color(0xFF8A94A3);

  // Brand
  static const amber = Color(0xFFF2B14C);
  static const amberDeep = Color(0xFFC98E2E);
  static const onAmber = Color(0xFF1F1405);
  static const navy = Color(0xFF1B2A4A);
  static const navyDeep = Color(0xFF13203E);

  // Status
  static const success = Color(0xFF46C99B);
  static const warning = Color(0xFFF0A040);
  static const danger = Color(0xFFF2555A);
  static const info = Color(0xFF6CA8F0);

  // Social platform colours (for small marks and chips only)
  static const instagram = Color(0xFFE1306C);
  static const facebook = Color(0xFF1877F2);
  static const linkedin = Color(0xFF0A66C2);
  static const x = Color(0xFFE7E9EA);

  // Shape & spacing
  static const radiusSm = 10.0;
  static const radiusMd = 16.0;
  static const radiusLg = 24.0;
  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 24.0;
  static const space6 = 32.0;
}
