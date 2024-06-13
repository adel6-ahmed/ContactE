import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:sad/screens/home_screen.dart';
import 'package:sad/screens/login/InterestsScreen.dart';
import 'package:sad/services/firestore_functions.dart';
import 'package:sad/shared/methods/navigation.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';

class Auth {
  void createUserByEmail({
    required String email,
    required String password,
    required BuildContext context,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
      .then((value) async {
        await FireBaseServices().createNewUser(
          name: name,
          uid: value.user!.uid,
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
          SnackBar(
            content: Text(
              'User Added Successfully',
              style: TextStyle(fontSize: 16), // تعديل في نمط النص لضمان التوافق
            ),
            backgroundColor: Colors.yellow, // لون الخلفية
            showCloseIcon: true,
            duration: Duration(seconds: 2),
            closeIconColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Future.delayed(
          Duration(seconds: 2),
        );

        GoToReplacement(
          context: context,
          screen: InterestsScreen(
            name: name,
            phoneNumber: phoneNumber,
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Password Error',
          desc: 'The password provided is too weak.',
        ).show();
      } else if (e.code == 'email-already-in-use') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Email Error',
          desc: 'The account already exists for that email.',
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Sign Up Failed',
          desc: 'An error occurred while signing up. Please try again later.',
        ).show();
      }
    } catch (e) {
      print(e);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Sign Up Failed',
        desc: 'An error occurred while signing up. Please try again later.',
      ).show();
    }
  }

  void userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      GoToReplacement(
        context: context,
        screen: HomeScreen(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Password Error',
          desc: 'The password is incorrect.',
        ).show();
      } else if (e.code == 'user-not-found') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Email Error',
          desc: 'No user found for that email.',
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Login Failed',
          desc: 'An error occurred while logging in. Please try again later.',
        ).show();
      }
    } catch (e) {
      print(e);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Login Failed',
        desc: 'An error occurred while logging in. Please try again later.',
      ).show();
    }
  }
}