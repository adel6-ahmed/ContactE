/// Builds a vCard 3.0 for the user's digital business card. Any phone camera that scans the
/// QR code offers to save it as a contact — no app install needed on the other side.
String buildVCard({
  required String name,
  String? phone,
  String? email,
  Map<String, dynamic> socials = const {},
}) {
  String esc(String v) => v
      .replaceAll(r'\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll(',', r'\,')
      .replaceAll(';', r'\;');

  final cleanName = name.trim().isEmpty ? 'ContactE' : name.trim();
  final lines = <String>[
    'BEGIN:VCARD',
    'VERSION:3.0',
    'N:;${esc(cleanName)};;;',
    'FN:${esc(cleanName)}',
    if (phone != null && phone.trim().isNotEmpty) 'TEL;TYPE=CELL:${phone.replaceAll(RegExp(r'[^\d+]'), '')}',
    if (email != null && email.trim().isNotEmpty) 'EMAIL;TYPE=INTERNET:${esc(email.trim())}',
  ];
  socials.forEach((platform, value) {
    final url = value?.toString().trim() ?? '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      final type = platform.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      lines.add('X-SOCIALPROFILE;TYPE=$type:${esc(url)}');
      lines.add('URL;TYPE=$type:${esc(url)}');
    }
  });
  lines.add('END:VCARD');
  return lines.join('\r\n');
}
