// shared/theme/colors.dart
//
// Legacy palette names used across the existing screens, remapped (2026-10) onto the new
// design tokens in lib/design/tokens.dart so every screen picks up the refreshed look.
// New code should use Theme.of(context).colorScheme / AppTokens instead of these.
import 'package:flutter/material.dart';

import '../../design/tokens.dart';

// ألوان أساسية
const Color navy = AppTokens.navy;
const Color black = Colors.black;
const Color gri = AppTokens.textMuted;
const Color yellowDark = AppTokens.navyDeep;
const Color light = AppTokens.textPrimary;
const Color transparent = Colors.transparent;
const Color white = AppTokens.textPrimary;

// ألوان مخصصة
const Color yellow = AppTokens.amberDeep;
const Color adel = AppTokens.amber;
const Color red = AppTokens.danger;
const Color Lyellow = AppTokens.amber;

// ألوان واجهة المستخدم
const Color Ldark = AppTokens.background;
const Color BottomNavBarColor = AppTokens.surfaceRaised;
