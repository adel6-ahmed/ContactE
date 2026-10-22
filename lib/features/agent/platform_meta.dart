import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../design/tokens.dart';

class PlatformMeta {
  const PlatformMeta(this.id, this.name, this.icon, this.color, this.connectHint);
  final String id;
  final String name;
  final FaIconData icon;
  final Color color;
  final String connectHint;
}

const platforms = <PlatformMeta>[
  PlatformMeta('instagram', 'إنستغرام', FontAwesomeIcons.instagram, AppTokens.instagram,
      'حساب أعمال أو صانع محتوى مرتبط بصفحة فيسبوك.'),
  PlatformMeta('facebook', 'فيسبوك', FontAwesomeIcons.facebook, AppTokens.facebook, 'صفحة فيسبوك تديرها.'),
  PlatformMeta('linkedin', 'لينكدإن', FontAwesomeIcons.linkedin, AppTokens.linkedin, 'حسابك الشخصي على لينكدإن.'),
  PlatformMeta('x', 'X', FontAwesomeIcons.xTwitter, AppTokens.x, 'يتطلب النشر المباشر اشتراكًا مدفوعًا في واجهة X.'),
];

PlatformMeta platformMeta(String id) =>
    platforms.firstWhere((p) => p.id == id, orElse: () => PlatformMeta(id, id, FontAwesomeIcons.globe, AppTokens.textMuted, ''));
