import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import 'agent_api.dart';
import 'draft_card.dart';
import 'social_accounts_screen.dart';
import '../../shared/widgets/button_nav_bar.dart';
import '../../l10n/strings.dart';

/// Bradi, the social-media agent: chat on one tab, pending drafts on the other.
class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key, this.api});
  final AgentApi? api;

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _Message {
  _Message.user(this.text) : fromUser = true, proposals = const [], error = false;
  _Message.agent(this.text, this.proposals, {this.error = false}) : fromUser = false;
  final bool fromUser;
  final String text;
  final List<Proposal> proposals;
  final bool error;
}

class _AgentScreenState extends State<AgentScreen> with SingleTickerProviderStateMixin {
  late final AgentApi api = widget.api ?? AgentApi();
  late final TabController tabs = TabController(length: 2, vsync: this);
  final input = TextEditingController();
  final scroll = ScrollController();
  final messages = <_Message>[];
  bool sending = false;
  Future<List<Proposal>>? pending;

  @override
  void initState() {
    super.initState();
    BottomNavBar.index = 3; // highlight Bradi however the screen was opened
    tabs.addListener(() {
      if (tabs.index == 1 && !tabs.indexIsChanging) _reloadPending();
    });
  }

  @override
  void dispose() {
    tabs.dispose();
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  // ignore(): the FutureBuilder still receives the error and shows it; an error that arrives after the
  // tab was disposed is not reported as unhandled.
  Future<List<Proposal>> _loadPending() => api.proposals(status: 'pending')..ignore();

  void _reloadPending() => setState(() => pending = _loadPending());

  Future<void> _send([String? preset]) async {
    final text = (preset ?? input.text).trim();
    if (text.isEmpty || sending) return;
    final history = [
      for (final m in messages.where((m) => !m.error).toList().reversed.take(10).toList().reversed)
        ChatTurn(m.fromUser ? 'user' : 'assistant', m.text),
    ];
    setState(() {
      messages.add(_Message.user(text));
      sending = true;
      input.clear();
    });
    _scrollToEnd();
    try {
      final reply = await api.chat(text, history);
      setState(() => messages.add(_Message.agent(reply.text, reply.proposals)));
    } on AgentException catch (e) {
      setState(() => messages.add(_Message.agent(e.message, const [], error: true)));
    } finally {
      setState(() => sending = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroll.hasClients) {
          scroll.animateTo(scroll.position.maxScrollExtent + 200,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: S.current.dir,
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const CircleAvatar(radius: 16, backgroundColor: AppTokens.amber,
                child: Icon(Icons.auto_awesome, size: 18, color: AppTokens.onAmber)),
            const SizedBox(width: 10),
            Text(S.current.agentTitle),
          ]),
          actions: [
            IconButton(
              tooltip: S.current.linkedAccounts,
              icon: const Icon(Icons.manage_accounts_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SocialAccountsScreen(api: api))),
            ),
          ],
          bottom: TabBar(controller: tabs, tabs: [Tab(text: S.current.tabChat), Tab(text: S.current.tabDrafts)]),
        ),
        body: TabBarView(controller: tabs, children: [_chat(context), _drafts(context)]),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }

  Widget _chat(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Expanded(
        child: messages.isEmpty
            ? ListView(padding: const EdgeInsets.all(AppTokens.space5), children: [
                Text(S.current.agentHello, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(S.current.agentIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 20),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final s in S.current.suggestions) ActionChip(label: Text(s), onPressed: () => _send(s)),
                ]),
              ])
            : ListView.builder(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: messages.length + (sending ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == messages.length) return const _Typing();
                  final m = messages[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: m.fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        _Bubble(message: m),
                        for (final p in m.proposals)
                          Padding(padding: const EdgeInsets.only(top: 10), child: DraftCard(proposal: p, api: api)),
                      ],
                    ),
                  );
                },
              ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: input,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(hintText: S.current.askHint),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: S.current.send,
              onPressed: sending ? null : _send,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _drafts(BuildContext context) {
    pending ??= _loadPending();
    return RefreshIndicator(
      onRefresh: () async => _reloadPending(),
      child: FutureBuilder<List<Proposal>>(
        future: pending,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(children: [_EmptyState(icon: Icons.cloud_off, text: snap.error.toString())]);
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return ListView(children: [
              _EmptyState(icon: Icons.inbox_outlined, text: S.current.noDrafts),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => DraftCard(proposal: items[i], api: api),
          );
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromUser;
    final bg = mine ? AppTokens.amber : (message.error ? AppTokens.danger.withValues(alpha: 0.15) : AppTokens.surfaceRaised);
    final fg = mine ? AppTokens.onAmber : AppTokens.textPrimary;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(mine ? 4 : 18),
            bottomEnd: Radius.circular(mine ? 18 : 4),
          ),
        ),
        child: SelectableText(message.text, style: TextStyle(color: fg, height: 1.55)),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();
  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppTokens.surfaceRaised, borderRadius: BorderRadius.circular(18)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 10),
            Text(S.current.typing),
          ]),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
        child: Column(children: [
          Icon(icon, size: 40, color: AppTokens.textMuted),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}
