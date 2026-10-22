import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../design/tokens.dart';
import '../../l10n/strings.dart';

class PlatformMeta {
  const PlatformMeta(this.id, this.icon, this.color);
  final String id;
  final FaIconData icon;
  final Color color;
  String get name => S.current.platformName(id);
  String get connectHint => S.current.platformHint(id);
}

const platforms = <PlatformMeta>[
  PlatformMeta('instagram', FontAwesomeIcons.instagram, AppTokens.instagram),
  PlatformMeta('facebook', FontAwesomeIcons.facebook, AppTokens.facebook),
  PlatformMeta('linkedin', FontAwesomeIcons.linkedin, AppTokens.linkedin),
  PlatformMeta('x', FontAwesomeIcons.xTwitter, AppTokens.x),
];

PlatformMeta platformMeta(String id) =>
    platforms.firstWhere((p) => p.id == id, orElse: () => PlatformMeta(id, FontAwesomeIcons.globe, AppTokens.textMuted));
