import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' show TextDirection;

/// Strings for the new screens (agent, digital card, navigation) in Arabic and English.
/// The language follows the device; `--dart-define=APP_LANG=en|ar` forces one (previews, screenshots).
class S {
  S._(this.isArabic);
  final bool isArabic;

  static S? _current;
  static S get current => _current ??= S._(_detect() == 'ar');

  /// Tests and previews can pin a language.
  static void load(String languageCode) => _current = S._(languageCode == 'ar');

  static String _detect() {
    const forced = String.fromEnvironment('APP_LANG');
    if (forced.isNotEmpty) return forced;
    return PlatformDispatcher.instance.locale.languageCode;
  }

  TextDirection get dir => isArabic ? TextDirection.rtl : TextDirection.ltr;
  String _t(String ar, String en) => isArabic ? ar : en;

  // Navigation
  String get navNetwork => _t('شبكتي', 'Network');
  String get navGroups => _t('مجموعاتي', 'Groups');
  String get navHome => _t('الرئيسية', 'Home');
  String get navBradi => _t('برادي', 'Bradi');
  String get navProfile => _t('ملفي', 'Profile');

  // Agent screen
  String get agentTitle => _t('برادي · مساعد السوشيال', 'Bradi · social assistant');
  String get linkedAccounts => _t('الحسابات المرتبطة', 'Connected accounts');
  String get tabChat => _t('المحادثة', 'Chat');
  String get tabDrafts => _t('المسودات', 'Drafts');
  String get agentHello => _t('أهلًا! أنا برادي.', "Hi! I'm Bradi.");
  String get agentIntro => _t(
      'أكتب منشوراتك، وأكيّفها لكل منصة، وأقترح ردودًا على التعليقات وأوقات النشر. لا يُنشر شيء قبل أن تؤكده أنت.',
      'I write your posts, adapt them for each platform, and suggest replies and posting times. '
          'Nothing is published until you confirm it.');
  List<String> get suggestions => isArabic
      ? const [
          'جهّز منشورًا لإطلاق خدمة جديدة على إنستغرام ولينكدإن',
          'اقترح خطة محتوى لأسبوع مع أوقات نشر',
          'اقرأ آخر التعليقات على إنستغرام واقترح ردودًا',
          'حوّل هذه الفكرة إلى منشور قصير لـ X',
        ]
      : const [
          'Write a launch post for a new service on Instagram and LinkedIn',
          'Plan a week of content with posting times',
          'Read my latest Instagram comments and suggest replies',
          'Turn this idea into a short post for X',
        ];
  String get askHint => _t('اطلب من برادي…', 'Ask Bradi…');
  String get send => _t('إرسال', 'Send');
  String get typing => _t('برادي يكتب…', 'Bradi is typing…');
  String get noDrafts => _t('لا توجد مسودات بانتظار تأكيدك.', 'No drafts are waiting for your confirmation.');

  // Draft card
  String postOn(String platform) => _t('منشور $platform', '$platform post');
  String replyOn(String platform) => _t('رد على $platform', 'Reply on $platform');
  String chars(int n, int limit) => _t('$n / $limit حرف', '$n / $limit characters');
  String get confirm => _t('تأكيد', 'Confirm');
  String get confirmSchedule => _t('تأكيد وجدولة', 'Confirm & schedule');
  String get edit => _t('تعديل', 'Edit');
  String get reject => _t('رفض', 'Reject');
  String get editDraft => _t('تعديل المسودة', 'Edit draft');
  String get save => _t('حفظ', 'Save');
  String get nothingUntilConfirm => _t('لن يُنشر أي شيء قبل أن تضغط تأكيد.', 'Nothing is published until you tap Confirm.');
  String get shareAgain => _t('مشاركة مرة أخرى', 'Share again');
  String get saved => _t('تم حفظ التعديل.', 'Changes saved.');
  String get done => _t('تم.', 'Done.');
  String get rejected => _t('تم رفض المسودة.', 'Draft rejected.');
  String status(String s) => switch (s) {
        'pending' => _t('بانتظار تأكيدك', 'Awaiting you'),
        'scheduled' => _t('مجدول', 'Scheduled'),
        'published' => _t('منشور', 'Published'),
        'shared' => _t('جاهز للمشاركة', 'Ready to share'),
        'rejected' => _t('مرفوض', 'Rejected'),
        'failed' => _t('فشل', 'Failed'),
        _ => s,
      };

  // Connected accounts
  String get accountsIntro => _t(
      'بدون ربط، يجهّز برادي المسودات وتنشرها أنت عبر المشاركة. مع الربط، يُنشر المنشور مباشرة بعد ضغطك على تأكيد.',
      'Without a connection, Bradi prepares drafts that you share yourself. Once connected, a post is published '
          'directly after you tap Confirm.');
  String get directPublishing => _t('نشر مباشر', 'Direct publishing');
  String get draftsYouShare => _t('مسودات تنشرها بنفسك', 'Drafts you share yourself');
  String get connect => _t('ربط', 'Connect');
  String get disconnect => _t('فصل', 'Disconnect');
  String connectTitle(String platform) => _t('ربط $platform', 'Connect $platform');
  String get handleLabel => _t('اسم الحساب (مثل ‎@mybrand)', 'Account name (e.g. @mybrand)');
  String get tokenLabel => _t('رمز الوصول (Access token)', 'Access token');
  String get tokenNote => _t('يُحفظ الرمز مشفّرًا على الخادم ولا يُخزَّن في الهاتف.',
      'The token is stored encrypted on the server, never on the phone.');
  String get securityNote => _t(
      'الأمان: لا يملك برادي صلاحية النشر وحده. كل منشور أو رد يحتاج تأكيدك، وكل عملية تُسجَّل في سجل التدقيق.',
      'Security: Bradi cannot publish on its own. Every post or reply needs your confirmation, and every action '
          'is recorded in an audit log.');

  // Platforms
  String platformName(String id) => switch (id) {
        'instagram' => _t('إنستغرام', 'Instagram'),
        'facebook' => _t('فيسبوك', 'Facebook'),
        'linkedin' => _t('لينكدإن', 'LinkedIn'),
        'x' => 'X',
        _ => id,
      };
  String platformHint(String id) => switch (id) {
        'instagram' => _t('حساب أعمال أو صانع محتوى مرتبط بصفحة فيسبوك.',
            'A Business or Creator account linked to a Facebook Page.'),
        'facebook' => _t('صفحة فيسبوك تديرها.', 'A Facebook Page you manage.'),
        'linkedin' => _t('حسابك الشخصي على لينكدإن.', 'Your personal LinkedIn profile.'),
        'x' => _t('يتطلب النشر المباشر اشتراكًا مدفوعًا في واجهة X.', 'Direct posting needs a paid X API tier.'),
        _ => '',
      };
  String extraFieldLabel(String id) => switch (id) {
        'facebook' => _t('معرّف الصفحة (Page ID)', 'Page ID'),
        'instagram' => _t('معرّف حساب إنستغرام (IG User ID)', 'Instagram user ID'),
        'linkedin' => 'urn:li:person:…',
        _ => '',
      };

  // Digital card
  String get myCard => _t('بطاقتي الرقمية', 'My digital card');
  String get signInForCard => _t('سجّل الدخول لعرض بطاقتك.', 'Sign in to see your card.');
  String get scanHint => _t('وجّه كاميرا أي هاتف إلى الرمز لحفظ جهة الاتصال.',
      'Point any phone camera at the code to save the contact.');
  String qrLabel(String name) => _t('رمز QR لبطاقة $name', 'QR code for $name');
  String get shareCard => _t('مشاركة البطاقة', 'Share card');
  String get copy => _t('نسخ', 'Copy');
  String get copied => _t('تم نسخ البطاقة.', 'Card copied.');
  String get defaultUser => _t('مستخدم ContactE', 'ContactE user');

  // Home quick actions
  String get quickActions => _t('إجراءات سريعة', 'Quick actions');
  String get cardSubtitle => _t('شارك جهة اتصالك برمز QR', 'Share your contact with a QR code');
  String get bradiSubtitle => _t('أدر حساباتك على السوشيال', 'Manage your social accounts');
  String get suggestionsTitle => _t('اقتراحات', 'Suggestions');
  String get suggestionsSubtitle => _t('أشخاص قد تعرفهم', 'People you may know');

  // Errors from the agent API
  String get signInFirst => _t('سجّل الدخول أولًا لاستخدام المساعد.', 'Sign in to use the assistant.');
  String get networkError => _t('تعذّر الاتصال بالخادم. تحقق من الإنترنت ثم حاول مجددًا.',
      'Could not reach the server. Check your connection and try again.');
  String httpError(int code) => _t('حدث خطأ ($code).', 'Something went wrong ($code).');
}
