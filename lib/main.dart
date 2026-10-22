import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
    // يبقى المستخدم مسجّلًا إذا كانت جلسة Firebase ما زالت صالحة
    setState(() {
      _isLoggedIn = FirebaseAuth.instance.currentUser != null;
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
      title: 'ContactE',
      theme: appTheme,
      home: _isLoggedIn
          ? HomeScreen() // تم إزالة const من هنا
          : LoginScreen(
              onLoginSuccess: () => _updateAuthStatus(true),
            ),
    );
  }
}