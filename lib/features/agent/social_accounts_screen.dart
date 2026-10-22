import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../design/tokens.dart';
import 'agent_api.dart';
import 'platform_meta.dart';

/// Which accounts can Bradi publish to directly, and which work through drafts you share yourself.
class SocialAccountsScreen extends StatefulWidget {
  const SocialAccountsScreen({super.key, required this.api});
  final AgentApi api;

  @override
  State<SocialAccountsScreen> createState() => _SocialAccountsScreenState();
}

const _extraField = {'facebook': ('page_id', 'معرّف الصفحة (Page ID)'), 'instagram': ('ig_user_id', 'معرّف حساب إنستغرام (IG User ID)'),
  'linkedin': ('author_urn', 'urn:li:person:…')};

class _SocialAccountsScreenState extends State<SocialAccountsScreen> {
  late Future<List<SocialAccount>> accounts = widget.api.accounts();

  void _reload() => setState(() => accounts = widget.api.accounts());

  Future<void> _connect(PlatformMeta meta) async {
    final handle = TextEditingController();
    final token = TextEditingController();
    final extra = TextEditingController();
    final field = _extraField[meta.id];
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('ربط ${meta.name}', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(meta.connectHint, style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(controller: handle, decoration: const InputDecoration(labelText: 'اسم الحساب (مثل ‎@mybrand)')),
            const SizedBox(height: 10),
            if (field != null) ...[
              TextField(controller: extra, decoration: InputDecoration(labelText: field.$2)),
              const SizedBox(height: 10),
            ],
            TextField(controller: token, obscureText: true,
                decoration: const InputDecoration(labelText: 'رمز الوصول (Access token)')),
            const SizedBox(height: 8),
            Text('يُحفظ الرمز مشفّرًا على الخادم ولا يُخزَّن في الهاتف.', style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ربط')),
          ]),
        ),
      ),
    );
    if (ok != true) return;
    try {
      await widget.api.connect(meta.id, {
        'handle': handle.text.trim(),
        'access_token': token.text.trim(),
        if (field != null) field.$1: extra.text.trim(),
      });
      _reload();
    } on AgentException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الحسابات المرتبطة')),
        body: FutureBuilder<List<SocialAccount>>(
          future: accounts,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Center(child: Text(snap.error.toString()));
            final byId = {for (final a in snap.data!) a.platform: a};
            return ListView(padding: const EdgeInsets.all(16), children: [
              Text('بدون ربط، يجهّز برادي المسودات وتنشرها أنت عبر المشاركة. مع الربط، يُنشر المنشور مباشرة '
                  'بعد ضغطك على تأكيد.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              for (final meta in platforms) ...[
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(backgroundColor: meta.color.withValues(alpha: 0.15),
                        child: FaIcon(meta.icon, color: meta.color, size: 20)),
                    title: Text(meta.name, style: theme.textTheme.titleSmall),
                    subtitle: Text(byId[meta.id]?.connected == true
                        ? 'نشر مباشر · ${byId[meta.id]!.handle}'
                        : 'مسودات تنشرها بنفسك'),
                    trailing: byId[meta.id]?.connected == true
                        ? TextButton(
                            onPressed: () async {
                              await widget.api.disconnect(meta.id);
                              _reload();
                            },
                            child: const Text('فصل'))
                        : OutlinedButton(onPressed: () => _connect(meta), child: const Text('ربط')),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTokens.surfaceRaised, borderRadius: BorderRadius.circular(16)),
                child: Text('الأمان: لا يملك برادي صلاحية النشر وحده. كل منشور أو رد يحتاج تأكيدك، '
                    'وكل عملية تُسجَّل في سجل التدقيق.', style: theme.textTheme.bodySmall),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
