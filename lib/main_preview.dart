// Design preview of the new screens, without Firebase (for designers, reviews and Flutter web).
//
//   flutter run -d chrome -t lib/main_preview.dart \
//     --dart-define=AGENT_BASE_URL=http://localhost:8090 --dart-define=AGENT_DEV_USER=preview-user
//
// The agent talks to a local agent_backend started with AUTH_MODE=dev. Not used in release builds.
import 'package:flutter/material.dart';

import 'design/tokens.dart';
import 'features/agent/agent_api.dart';
import 'features/agent/agent_screen.dart';
import 'features/agent/social_accounts_screen.dart';
import 'features/card/my_card_screen.dart';
import 'services/models.dart';
import 'shared/theme/theme.dart';
import 'l10n/strings.dart';

void main() => runApp(const PreviewApp());

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ContactE preview',
        theme: appTheme,
        home: const _Launcher(),
      );
}

class _Launcher extends StatelessWidget {
  const _Launcher();

  static final _sample = MyUser(
    name: S.current.isArabic ? 'محمد بوحمادي' : 'Mohamd Bouhemadi',
    phoneNumber: '+90 501 342 24 54',
    socialMediaPlatforms: {
      'linkedin': 'https://linkedin.com/in/mohamd-bouhemadi',
      'instagram': 'https://instagram.com/contacte.app',
      'x': 'https://x.com/contacte',
    },
  );

  @override
  Widget build(BuildContext context) {
    final api = AgentApi();
    final items = [
      (Icons.auto_awesome, S.current.agentTitle, () => AgentScreen(api: api)),
      (Icons.qr_code_2_rounded, S.current.myCard,
          () => Directionality(textDirection: S.current.dir,
              child: Scaffold(appBar: AppBar(title: Text(S.current.myCard)), body: CardView(user: _sample)))),
      (Icons.manage_accounts_outlined, S.current.linkedAccounts, () => SocialAccountsScreen(api: api)),
    ];
    return Directionality(
      textDirection: S.current.dir,
      child: Scaffold(
        appBar: AppBar(title: Text(S.current.isArabic ? 'ContactE · معاينة التصميم' : 'ContactE · design preview')),
        body: ListView(padding: const EdgeInsets.all(AppTokens.space4), children: [
          for (final (icon, title, builder) in items) ...[
            Card(
              child: ListTile(
                leading: Icon(icon, color: AppTokens.amber),
                title: Text(title),
                trailing: Icon(S.current.isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => builder())),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ]),
      ),
    );
  }
}
