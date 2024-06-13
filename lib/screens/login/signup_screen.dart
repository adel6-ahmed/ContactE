import 'package:flutter/material.dart';
import 'package:sad/screens/login/login_screen.dart';
import 'package:sad/services/auth_service.dart';
import 'package:sad/shared/theme/colors.dart';

import '../../shared/theme/texet.dart';
import '../../shared/widgets/action_button.dart';
import 'package:sad/screens/login/InterestsScreen.dart';


class SignupScreen extends StatelessWidget {
  final String name;
  final String phoneNumber;

  SignupScreen({required this.name, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return _SignupScreenContent(name: name, phoneNumber: phoneNumber);
  }
}

class _SignupScreenContent extends StatefulWidget {
  final String name;
  final String phoneNumber;

  _SignupScreenContent({required this.name, required this.phoneNumber});

  @override
  _SignupScreenContentState createState() => _SignupScreenContentState();
}

class _SignupScreenContentState extends State<_SignupScreenContent> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController passwordController1;
  late GlobalKey<FormState> formKey;
  late FocusNode passwordNode;
  late FocusNode passwordNode1;
  bool isHidden = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordController1 = TextEditingController();
    formKey = GlobalKey<FormState>();
    passwordNode = FocusNode();
    passwordNode1 = FocusNode();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordNode.dispose();
    passwordNode1.dispose();
    passwordController1.dispose();
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
          toolbarHeight: 70, // Adjust height as needed
          backgroundColor: Color.fromARGB(255, 28, 33, 32),
          elevation: 0,
        ),
        body: Container(
          color: Ldark, // Adjust as needed
          child: SizedBox(
            height: 734, // Set the desired height
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align items at the top
                children: [
                  Container(
                    height: 734,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(70),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .stretch, // Stretch items horizontally
                          children: [
                            SizedBox(
                                height: 20), // Added SizedBox with height 20
                            Image.asset(
                              'assets/CA.png',
                              width: 90,
                              height: 90,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(
                                height: 20), // Adjusted height here if needed
                            TextFormField(
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(passwordNode);
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
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(passwordNode1);
                              },
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
                                  onPressed: toggleVisibility,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              focusNode: passwordNode1,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password can't be empty";
                                }
                                if (value != passwordController.text) {
                                  return "Passwords don't match";
                                }
                                return null;
                              },
                              controller: passwordController1,
                              obscureText: isHidden,
                              cursorColor: Colors.grey,
                              style: title1.copyWith(color: Colors.black),
                              decoration: InputDecoration(
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                labelText: 'Confirm password',
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
                                  onPressed: toggleVisibility,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            action_button(
                              title: 'Sign up',
                              action: () async {
                                if (formKey.currentState!.validate()) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  Auth().createUserByEmail(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    context: context,
                                    name: widget.name,
                                    phoneNumber: widget.phoneNumber,
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Or',
                                style: h5Bold.merge(TextStyle(color: gri)),
                              ),
                            ),
                            SizedBox(height: 10),
                            action_button(
                              title: '  Sign Up With Google  ',
                              action: () {},
                            ),
                            SizedBox(height: 10),
                            action_button(
                              title: 'Sign Up With Facebook',
                              action: () {},
                            ),
                            SizedBox(height: 5),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Already have an account",
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
