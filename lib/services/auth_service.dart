import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sad/screens/home_screen.dart';
import 'package:sad/screens/login/InterestsScreen.dart';
import 'package:sad/services/firestore_functions.dart';
import 'package:sad/shared/methods/navigation.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserByEmail({
    required String email,
    required String password,
    required BuildContext context,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FireBaseServices().createNewUser(
        name: name,
        uid: userCredential.user!.uid,
        phoneNumber: phoneNumber,
        context: context,
        interests: {
          'Country': '',
          'Age': '',
          'Favorite Social Media': '',
          'Occupation': ''
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(  // تم إزالة const من هنا
          content: Text(
            'User Added Successfully',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.yellow,
          showCloseIcon: true,
          duration: Duration(seconds: 2),
          closeIconColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(Duration(seconds: 2));

      GoToReplacement(
        context: context,
        screen: InterestsScreen(
          name: name,
          phoneNumber: phoneNumber,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred while signing up.';
      
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Sign Up Failed',
        desc: errorMessage,
      ).show();
    } catch (e) {
      print('Sign up error: $e');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Sign Up Failed',
        desc: 'An unexpected error occurred. Please try again later.',
      ).show();
    }
  }

  Future<void> userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      GoToReplacement(
        context: context,
        screen: HomeScreen(),  // تم إزالة const من هنا أيضاً
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred while logging in.';
      
      if (e.code == 'wrong-password') {
        errorMessage = 'The password is incorrect.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Login Failed',
        desc: errorMessage,
      ).show();
    } catch (e) {
      print('Login error: $e');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Login Failed',
        desc: 'An unexpected error occurred. Please try again later.',
      ).show();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}