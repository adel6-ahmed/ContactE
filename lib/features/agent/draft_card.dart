import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../design/tokens.dart';
import 'agent_api.dart';
import 'platform_meta.dart';
import '../../l10n/strings.dart';

const _limits = {'x': 280, 'linkedin': 3000, 'instagram': 2200, 'facebook': 63206};

/// A draft from the agent. Nothing is published until the user taps Confirm.
class DraftCard extends StatefulWidget {
  const DraftCard({super.key, required this.proposal, required this.api, this.onChanged});

  final Proposal proposal;
  final AgentApi api;
  final ValueChanged<Proposal>? onChanged;

  @override
  State<DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<DraftCard> {
  late Proposal p = widget.proposal;
  bool busy = false;

  Future<void> _run(Future<Proposal> Function() action, {String? success}) async {
    setState(() => busy = true);
    try {
      final updated = await action();
      setState(() => p = updated);
      widget.onChanged?.call(updated);
      if (!mounted) return;
      if (updated.status == 'shared' && updated.shareText != null) {
        await SharePlus.instance.share(ShareParams(text: updated.shareText!));
      } else if (success != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
      }
    } on AgentException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _edit() async {
    final controller = TextEditingController(text: p.text);
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Directionality(
        textDirection: S.current.dir,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(S.current.editDraft, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(controller: controller, maxLines: 8, minLines: 4, autofocus: true),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(S.current.save)),
          ]),
        ),
      ),
    );
    if (text != null && text.trim().isNotEmpty && text != p.text) {
      await _run(() => widget.api.edit(p.id, text.trim()), success: S.current.saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = platformMeta(p.platform);
    final theme = Theme.of(context);
    final limit = _limits[p.platform];
    final pending = p.status == 'pending';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 16, backgroundColor: meta.color.withValues(alpha: 0.15),
                child: FaIcon(meta.icon, size: 16, color: meta.color)),
            const SizedBox(width: 10),
            Expanded(child: Text(p.kind == 'reply' ? S.current.replyOn(meta.name) : S.current.postOn(meta.name),
                style: theme.textTheme.titleSmall)),
            _StatusChip(status: p.status),
          ]),
          const SizedBox(height: 12),
          SelectableText(p.text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
          if (p.mediaUrl != null) ...[
            const SizedBox(height: 8),
            Text('🖼 ${p.mediaUrl}', style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 12, children: [
            if (limit != null)
              Text(S.current.chars(p.text.characters.length, limit), style: theme.textTheme.bodySmall),
            if (p.scheduledFor != null)
              Text('🕒 ${_friendlyTime(p.scheduledFor!)}', style: theme.textTheme.bodySmall),
          ]),
          if (pending) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : () => _run(() => widget.api.confirm(p.id), success: S.current.done),
                  icon: busy
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(p.scheduledFor != null ? S.current.confirmSchedule : S.current.confirm),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(tooltip: S.current.edit, onPressed: busy ? null : _edit, icon: const Icon(Icons.edit_outlined)),
              const SizedBox(width: 4),
              IconButton.outlined(
                tooltip: S.current.reject,
                onPressed: busy ? null : () => _run(() => widget.api.reject(p.id), success: S.current.rejected),
                icon: const Icon(Icons.close_rounded),
              ),
            ]),
            const SizedBox(height: 6),
            Text(S.current.nothingUntilConfirm, style: theme.textTheme.bodySmall),
          ],
          if (p.status == 'shared' && p.shareText != null)
            TextButton.icon(onPressed: () => SharePlus.instance.share(ShareParams(text: p.shareText!)), icon: const Icon(Icons.ios_share, size: 18),
                label: Text(S.current.shareAgain)),
        ]),
      ),
    );
  }
}

String _friendlyTime(String iso) {
  final t = DateTime.tryParse(iso)?.toLocal();
  if (t == null) return iso;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' => (S.current.status(status), AppTokens.warning),
      'scheduled' => (S.current.status(status), AppTokens.info),
      'published' || 'shared' => (S.current.status(status), AppTokens.success),
      'failed' => (S.current.status(status), AppTokens.danger),
      _ => (S.current.status(status), AppTokens.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
