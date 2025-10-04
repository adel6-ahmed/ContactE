import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGptService {
  static String get _apiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('OPENAI_API_KEY not found in environment variables');
    }
    return key;
  }

  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getChatResponse(String userMessage, List<Map<String, dynamic>> conversationHistory) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''أنت مساعد ذكي اسمك "برادي" في تطبيق ContactE. 
تطبيق ContactE هو تطبيق لإدارة جهات الاتصال والمجموعات. 
كن مفيداً، ودوداً، ومختصراً في ردودك. 
استخدم اللغة العربية الفصحى أو العامية المناسبة. 
ركز على مساعدة المستخدم في:
- إنشاء وإدارة المجموعات
- البحث عن جهات الاتصال
- مشاركة المعلومات
- إعدادات الحساب
- استكشاف المشاكل التقنية'''
            },
            ...conversationHistory.map((msg) => {
              'role': msg['sender'] == 'user' ? 'user' : 'assistant',
              'content': msg['text']
            }),
            {
              'role': 'user',
              'content': userMessage
            }
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        throw Exception('فشل في الحصول على الرد: ${response.statusCode}');
      }
    } catch (e) {
      return getFallbackResponse(userMessage);
    }
  }

  static String getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('مرحبا') || message.contains('اهلا') || message.contains('السلام')) {
      return 'أهلاً وسهلاً! 😊 كيف يمكنني مساعدتك في تطبيق ContactE اليوم؟';
    } else if (message.contains('مساعدة') || message.contains('مساعده') || message.contains('help')) {
      return '''يمكنني مساعدتك في:
• إنشاء وإدارة المجموعات
• البحث عن جهات الاتصال
• مشاركة المعلومات
• إعدادات الحساب
• استكشاف المشاكل

أخبرني ما الذي تريد المساعدة فيه تحديداً؟''';
    } else if (message.contains('مجموعة') || message.contains('group') || message.contains('شلة')) {
      return 'لإنشاء مجموعة جديدة، اضغط على زر "إنشاء مجموعة" في قسم القصص. يمكنك إضافة أعضاء، مشاركة المعلومات، وتنظيم اتصالاتك بسهولة!';
    } else if (message.contains('بحث') || message.contains('search') || message.contains('دور')) {
      return 'استخدم حقل البحث في الأعلى للعثور على جهات اتصال محددة. يمكنك البحث بالاسم، رقم الهاتف، أو أي معلومات أخرى.';
    } else if (message.contains('اتصال') || message.contains('contact') || message.contains('رقم')) {
      return 'لإضافة جهة اتصال جديدة، انتقل إلى شاشة "شبكتي" ثم اضغط على زر الإضافة. يمكنك إضافة معلومات متعددة لكل جهة اتصال.';
    } else if (message.contains('مشكلة') || message.contains('problem') || message.contains('غلط')) {
      return 'أخبرني بالمشكلة التي تواجهها وسأحاول مساعدتك في حلها. يمكنك وصف ما يحدث بالتفصيل.';
    } else if (message.contains('شكر') || message.contains('thank') || message.contains('متشكر')) {
      return 'العفو! 😊 دائماً سعيد لمساعدتك. هل هناك شيء آخر تحتاج إليه؟';
    } else if (message.contains('وداع') || message.contains('bye') || message.contains('مع السلامة')) {
      return 'مع السلامة! 👋 لا تتردد في العودة إذا احتجت إلى أي مساعدة أخرى.';
    } else if (message.contains('اسمك') || message.contains('who are you')) {
      return 'أنا برادي! 🤖 مساعدك الذكي في تطبيق ContactE. مهمتي هي مساعدتك في استخدام التطبيق والاستفادة القصوى من ميزاته.';
    } else {
      return 'شكراً على رسالتك! 🤖 يمكنني مساعدتك في استخدام تطبيق ContactE، إنشاء المجموعات، إدارة جهات الاتصال، والمزيد. ما الذي تريد معرفته بالضبط؟';
    }
  }
}