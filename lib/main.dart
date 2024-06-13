import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sad/screens/EditProfileScreen.dart';
import 'package:sad/screens/SuggestionScreen.dart';
import 'package:sad/screens/crud/create_profile.dart';
import 'package:sad/screens/group_screen.dart';
import 'package:sad/screens/onboarding/onboarding1.dart';

import 'firebase_options.dart';
import 'shared/theme/theme.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
       theme: appTheme,
      home:   CreateProfileScreen(userId: 'some_user_id')
    );
  }
}




