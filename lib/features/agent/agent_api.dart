import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Client for the agent backend (agent_backend/). The app never holds an AI key or a
/// social-media token: it sends the signed-in user's Firebase ID token only.
///
/// Configure at build time:
///   flutter run --dart-define=AGENT_BASE_URL=https://agent.example.com
/// Local development against AUTH_MODE=dev:
///   --dart-define=AGENT_DEV_USER=dev-user-1   (ignored in release builds)
class AgentApi {
  AgentApi({http.Client? client, String? baseUrl, Future<String?> Function()? idToken, String? devUser})
      : _http = client ?? http.Client(),
        baseUrl = baseUrl ?? const String.fromEnvironment('AGENT_BASE_URL', defaultValue: 'http://localhost:8090'),
        _idToken = idToken ?? (() async => FirebaseAuth.instance.currentUser?.getIdToken()),
        _devUser = devUser ?? const String.fromEnvironment('AGENT_DEV_USER');

  final http.Client _http;
  final String baseUrl;
  final Future<String?> Function() _idToken;
  final String _devUser;

  Future<Map<String, String>> _headers() async {
    final headers = {'Content-Type': 'application/json'};
    if (!kReleaseMode && _devUser.isNotEmpty) {
      headers['X-Dev-User'] = _devUser;
      return headers;
    }
    String? token;
    try {
      token = await _idToken();
    } catch (_) {
      token = null; // Firebase not initialised or session expired
    }
    if (token == null) throw AgentException('سجّل الدخول أولًا لاستخدام المساعد.');
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    late http.Response r;
    try {
      final Future<http.Response> request = switch (method) {
        'GET' => _http.get(uri, headers: headers),
        'POST' => _http.post(uri, headers: headers, body: jsonEncode(body ?? {})),
        'PATCH' => _http.patch(uri, headers: headers, body: jsonEncode(body ?? {})),
        'DELETE' => _http.delete(uri, headers: headers),
        _ => throw ArgumentError(method),
      };
      r = await request.timeout(const Duration(seconds: 90));
    } on Exception {
      throw AgentException('تعذّر الاتصال بالخادم. تحقق من الإنترنت ثم حاول مجددًا.');
    }
    final decoded = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 400) {
      final detail = decoded is Map ? decoded['detail']?.toString() : null;
      throw AgentException(detail ?? 'حدث خطأ (${r.statusCode}).', statusCode: r.statusCode);
    }
    return decoded;
  }

  Future<AgentReply> chat(String message, List<ChatTurn> history) async {
    final data = await _send('POST', '/agent/chat', {
      'message': message,
      'history': history.map((t) => t.toJson()).toList(),
    }) as Map<String, dynamic>;
    return AgentReply(
      text: (data['reply'] ?? '') as String,
      proposals: [for (final p in (data['proposals'] as List? ?? [])) Proposal.fromJson(p)],
    );
  }

  Future<List<SocialAccount>> accounts() async =>
      [for (final a in await _send('GET', '/accounts') as List) SocialAccount.fromJson(a)];

  Future<void> connect(String platform, Map<String, String> fields) => _send('POST', '/accounts/$platform', fields);

  Future<void> disconnect(String platform) => _send('DELETE', '/accounts/$platform');

  Future<List<Proposal>> proposals({String? status}) async =>
      [for (final p in await _send('GET', '/proposals${status == null ? '' : '?status=$status'}') as List) Proposal.fromJson(p)];

  Future<Proposal> edit(String id, String text) async =>
      Proposal.fromJson(await _send('PATCH', '/proposals/$id', {'text': text}));

  Future<Proposal> confirm(String id, {bool publishNow = false}) async =>
      Proposal.fromJson(await _send('POST', '/proposals/$id/confirm', {'publish_now': publishNow}));

  Future<Proposal> reject(String id) async => Proposal.fromJson(await _send('POST', '/proposals/$id/reject'));
}

class AgentException implements Exception {
  AgentException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ChatTurn {
  ChatTurn(this.role, this.content);
  final String role; // user | assistant
  final String content;
  Map<String, String> toJson() => {'role': role, 'content': content};
}

class AgentReply {
  AgentReply({required this.text, required this.proposals});
  final String text;
  final List<Proposal> proposals;
}

class Proposal {
  Proposal({
    required this.id,
    required this.kind,
    required this.platform,
    required this.text,
    required this.status,
    this.mediaUrl,
    this.scheduledFor,
    this.result,
  });

  final String id, kind, platform, text, status;
  final String? mediaUrl, scheduledFor;
  final Map<String, dynamic>? result;

  /// Text to hand to the share sheet when the platform is not connected.
  String? get shareText => result?['share_text'] as String?;

  factory Proposal.fromJson(Map<String, dynamic> j) => Proposal(
        id: j['id'] as String,
        kind: j['kind'] as String,
        platform: j['platform'] as String,
        text: j['text'] as String,
        status: j['status'] as String,
        mediaUrl: j['media_url'] as String?,
        scheduledFor: j['scheduled_for'] as String?,
        result: (j['result'] as Map?)?.cast<String, dynamic>(),
      );
}

class SocialAccount {
  SocialAccount({required this.platform, required this.connected, this.handle});
  final String platform;
  final bool connected;
  final String? handle;
  factory SocialAccount.fromJson(Map<String, dynamic> j) =>
      SocialAccount(platform: j['platform'] as String, connected: j['connected'] as bool, handle: j['handle'] as String?);
}
