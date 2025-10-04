import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'shared/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // تحميل متغيرات البيئة
  try {
    await dotenv.load(fileName: '.env');
    print('Environment variables loaded');
  } catch (e) {
    print('Error loading environment variables: $e');
  }

  runApp(MyApp()); // تم إزالة const من هنا أيضاً
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // يمكن ربطها بـ FirebaseAuth لاحقًا
    setState(() {
      _isLoggedIn = false; // تغيير إلى true للاختبار
    });
  }

  void _updateAuthStatus(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: _isLoggedIn
          ? HomeScreen() // تم إزالة const من هنا
          : LoginScreen(
              onLoginSuccess: () => _updateAuthStatus(true),
            ),
    );
  }
}