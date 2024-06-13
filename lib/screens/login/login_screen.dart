import 'package:flutter/material.dart';
import 'package:sad/screens/crud/create_profile.dart';
import 'package:sad/screens/login/signup_screen.dart';
import 'package:sad/services/auth_service.dart';
import 'package:sad/shared/theme/colors.dart';

import '../../shared/theme/texet.dart';
import '../../shared/widgets/action_button.dart';
import 'package:sad/screens/login/InterestsScreen.dart';


class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _LoginScreenContent();
  }
}

class _LoginScreenContent extends StatefulWidget {
  @override
  _LoginScreenContentState createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late GlobalKey<FormState> formKey;
  late FocusNode passwordNode;
  bool isHidden = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    formKey = GlobalKey<FormState>();
    passwordNode = FocusNode();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  void toggleVisibility() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 190, // Adjust height as needed
          backgroundColor: Color.fromARGB(255, 28, 33, 32),
          elevation: 0,
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
              ),
              child: Image.asset(
                'assets/ContactE.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        body: Container(
          color: Ldark, // Adjust as needed
          child: SizedBox(
            height: 650, // Set the desired height
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align items at the top
                children: [
                  Container(
                    height: 610,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(70),
                        topLeft: Radius.circular(70),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch items horizontally
                          children: [
                            SizedBox(height: 20), // Added SizedBox with height 20
                            Image.asset(
                              'assets/L.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 20), // Adjusted height here if needed
                            TextFormField(
                              onFieldSubmitted: (value) {
                                FocusScope.of(context).requestFocus(passwordNode);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email can't be empty";
                                }
                                return null;
                              },
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Colors.white,
                              style: title1.copyWith(color: Colors.black),
                              decoration: InputDecoration(
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                labelText: 'Enter a valid email',
                                labelStyle: TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(
                                    color: red,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.yellow),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            TextFormField(
                              focusNode: passwordNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password can't be empty";
                                }
                                return null;
                              },
                              controller: passwordController,
                              obscureText: isHidden,
                              cursorColor: Colors.grey,
                              style: title1.copyWith(color: Colors.black),
                              decoration: InputDecoration(
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                labelText: 'Enter a password',
                                labelStyle: TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(
                                    color: red,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.yellow),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    toggleVisibility();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            action_button(
                              title: 'Login',
                              action: () async {
                                if (formKey.currentState!.validate()) {
                                  FocusScope.of(context).requestFocus(
                                    FocusNode(),
                                  );
                                    Auth().userLogin(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    context: context);
                                }
                              },
                            ),

                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forget my password',
                                style: title2.copyWith(color: Colors.grey),
                              ),
                            ),
                            SizedBox(height: 10),
                            action_button(
                              title: '  Login with Google  ',
                              action: () {
                              
                              },
                            ),
                            SizedBox(height: 10),
                            action_button(
                              title: 'Login with Facebook',
                              action: () {},
                            ),
                            SizedBox(height: 0),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateProfileScreen(userId: 'some_user_id')),
                                );
                              },
                              child: Text(
                                "Don't have an account",
                                style: title2.copyWith(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
