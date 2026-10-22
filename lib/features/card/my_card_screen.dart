import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../design/tokens.dart';
import '../../services/models.dart';
import '../agent/platform_meta.dart';
import 'vcard.dart';
import '../../l10n/strings.dart';

/// Digital business card: a QR code holding a standard vCard (scan with any camera to save the
/// contact), plus one-tap sharing of the same card.
class MyCardScreen extends StatelessWidget {
  const MyCardScreen({super.key});

  Future<MyUser?> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return MyUser.fromMap(doc.data(), user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: S.current.dir,
      child: Scaffold(
        appBar: AppBar(title: Text(S.current.myCard)),
        body: FutureBuilder<MyUser?>(
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            final user = snap.data;
            if (user == null) {
              return Center(child: Text(S.current.signInForCard));
            }
            return CardView(user: user, email: FirebaseAuth.instance.currentUser?.email);
          },
        ),
      ),
    );
  }
}

class CardView extends StatelessWidget {
  const CardView({super.key, required this.user, this.email});
  final MyUser user;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vcard = buildVCard(name: user.name, phone: user.phoneNumber, email: email, socials: user.socialMediaPlatforms);
    final links = user.socialMediaPlatforms.entries.where((e) => '${e.value}'.startsWith('http')).toList();

    return ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [AppTokens.navy, AppTokens.surfaceRaised],
          ),
          border: Border.all(color: AppTokens.outline),
        ),
        child: Column(children: [
          Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTokens.amber,
              backgroundImage: user.img.startsWith('http') && !user.img.contains('placeholder') ? NetworkImage(user.img) : null,
              child: user.img.startsWith('http') && !user.img.contains('placeholder')
                  ? null
                  : Text(user.name.isEmpty ? '?' : user.name.characters.first,
                      style: const TextStyle(color: AppTokens.onAmber, fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name.isEmpty ? S.current.defaultUser : user.name, style: theme.textTheme.titleLarge),
                if (user.phoneNumber.isNotEmpty)
                  Text(user.phoneNumber, textDirection: TextDirection.ltr, style: theme.textTheme.bodyMedium),
              ]),
            ),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: QrImageView(
              data: vcard,
              size: 210,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              semanticsLabel: S.current.qrLabel(user.name),
            ),
          ),
          const SizedBox(height: 12),
          Text(S.current.scanHint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          if (links.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              for (final e in links)
                Chip(
                  avatar: FaIcon(platformMeta(e.key.toLowerCase()).icon, size: 16, color: platformMeta(e.key.toLowerCase()).color),
                  label: Text(platformMeta(e.key.toLowerCase()).name),
                ),
            ]),
          ],
        ]),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => SharePlus.instance.share(ShareParams(text: vcard, subject: user.name)),
        icon: const Icon(Icons.ios_share),
        label: Text(S.current.shareCard),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: vcard));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.current.copied)));
          }
        },
        icon: const Icon(Icons.copy_rounded),
        label: Text(S.current.copy),
      ),
    ]);
  }
}
