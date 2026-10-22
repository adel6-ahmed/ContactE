import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sad/features/agent/agent_api.dart';
import 'package:sad/features/agent/agent_screen.dart';
import 'package:sad/features/agent/draft_card.dart';
import 'package:sad/features/card/my_card_screen.dart';
import 'package:sad/features/card/vcard.dart';
import 'package:sad/l10n/strings.dart';
import 'package:sad/services/models.dart';

Map<String, dynamic> _proposal({String status = 'pending', String text = 'Hello from ContactE'}) => {
      'id': 'prp_1', 'kind': 'post', 'platform': 'x', 'text': text, 'status': status,
      'media_url': null, 'scheduled_for': null, 'result': null,
    };

http.Response _json(Object body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status, headers: {'content-type': 'application/json'});

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData.dark(useMaterial3: true), home: child);

void main() {
  setUp(() => S.load('ar'));

  group('vCard', () {
    test('contains name, phone and https social links only', () {
      final v = buildVCard(name: 'Adel; Ahmed', phone: '+90 501 342 24 54', socials: {
        'Instagram': 'https://instagram.com/adel',
        'tiktok': 'not-a-url',
      });
      expect(v, startsWith('BEGIN:VCARD\r\nVERSION:3.0'));
      expect(v, contains(r'FN:Adel\; Ahmed'));
      expect(v, contains('TEL;TYPE=CELL:+905013422454'));
      expect(v, contains('X-SOCIALPROFILE;TYPE=instagram:https://instagram.com/adel'));
      expect(v, isNot(contains('not-a-url')));
      expect(v, endsWith('END:VCARD'));
    });

    test('empty name falls back', () {
      expect(buildVCard(name: '  '), contains('FN:ContactE'));
    });
  });

  group('Agent', () {
    late List<http.Request> requests;
    AgentApi api(Future<http.Response> Function(http.Request) handler) {
      requests = [];
      return AgentApi(
        baseUrl: 'http://test',
        idToken: () async => 'firebase-id-token',
        client: MockClient((r) {
          requests.add(r);
          return handler(r);
        }),
      );
    }

    testWidgets('sends the Firebase token and history, shows reply and drafts', (tester) async {
      final a = api((r) async => r.url.path == '/agent/chat'
          ? _json({'reply': 'جهزت مسودة.', 'proposals': [_proposal()]})
          : _json([]));
      await tester.pumpWidget(_wrap(AgentScreen(api: a)));
      await tester.enterText(find.byType(TextField), 'منشور عن الإطلاق');
      await tester.tap(find.byTooltip('إرسال'));
      await tester.pumpAndSettle();

      expect(find.text('جهزت مسودة.'), findsOneWidget);
      expect(find.text('Hello from ContactE'), findsOneWidget);
      expect(find.text('بانتظار تأكيدك'), findsOneWidget);
      final chat = requests.singleWhere((r) => r.url.path == '/agent/chat');
      expect(chat.headers['Authorization'], 'Bearer firebase-id-token');
      expect(jsonDecode(chat.body)['message'], 'منشور عن الإطلاق');
    });

    testWidgets('a draft is only sent when the user taps Confirm', (tester) async {
      final a = api((r) async => r.url.path.endsWith('/confirm')
          ? _json(_proposal(status: 'published'))
          : _json({}));
      await tester.pumpWidget(_wrap(Scaffold(body: Directionality(
        textDirection: TextDirection.rtl,
        child: DraftCard(proposal: Proposal.fromJson(_proposal()), api: a),
      ))));
      expect(requests, isEmpty);
      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle();
      expect(requests.single.url.path, '/proposals/prp_1/confirm');
      expect(find.text('منشور'), findsOneWidget); // status chip
      expect(find.text('تأكيد'), findsNothing);
    });

    testWidgets('backend errors are shown, not thrown', (tester) async {
      final a = api((r) async => _json({'detail': 'the assistant is unavailable right now'}, 503));
      await tester.pumpWidget(_wrap(AgentScreen(api: a)));
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.tap(find.byTooltip('إرسال'));
      await tester.pumpAndSettle();
      expect(find.text('the assistant is unavailable right now'), findsOneWidget);
    });
  });

  testWidgets('digital card renders name and QR', (tester) async {
    await tester.pumpWidget(_wrap(Scaffold(body: Directionality(
      textDirection: TextDirection.rtl,
      child: CardView(user: MyUser(name: 'Adel', phoneNumber: '+222 1234')),
    ))));
    expect(find.text('Adel'), findsOneWidget);
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, 'رمز QR لبطاقة Adel');
    expect(find.text('مشاركة البطاقة'), findsOneWidget);
  });

  testWidgets('English UI follows the device language', (tester) async {
    S.load('en');
    final api = AgentApi(baseUrl: 'http://test', idToken: () async => 't', client: MockClient((_) async => _json([])));
    await tester.pumpWidget(_wrap(AgentScreen(api: api)));
    expect(find.text("Hi! I'm Bradi."), findsOneWidget);
    expect(find.text('Write a launch post for a new service on Instagram and LinkedIn'), findsOneWidget);
    expect(find.text('Bradi'), findsOneWidget); // navigation label
    final dir = tester.widget<Directionality>(find.byType(Directionality).first);
    expect(dir.textDirection, TextDirection.ltr);
  });
}
