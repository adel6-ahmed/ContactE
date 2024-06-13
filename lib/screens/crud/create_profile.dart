import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sad/screens/login/signup_screen.dart';
import 'package:sad/shared/methods/navigation.dart';

import '../../shared/theme/colors.dart';
import '../../shared/theme/texet.dart';
import '../../shared/widgets/action_button.dart';

class CreateProfileScreen extends StatelessWidget {
  String userId;
  CreateProfileScreen({super.key, required this.userId});
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
  late TextEditingController name;
  late TextEditingController phoneNumberController;
  late GlobalKey<FormState> formKey;
  late FocusNode phoneNumberNode;

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    phoneNumberController = TextEditingController();
    formKey = GlobalKey<FormState>();
    phoneNumberNode = FocusNode();
  }

  @override
  void dispose() {
    name.dispose();
    phoneNumberController.dispose();
    phoneNumberNode.dispose();
    super.dispose();
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
                          crossAxisAlignment: CrossAxisAlignment
                              .stretch, // Stretch items horizontally
                          children: [
                            SizedBox(
                                height: 20), // Added SizedBox with height 20
                            Text(
                              'Create User',
                              textAlign: TextAlign.center,
                              style: h2Bold,
                            ),
                            SizedBox(
                                height: 20), // Adjusted height here if needed
                            TextFormField(
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(phoneNumberNode);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "name can't be empty";
                                }
                                return null;
                              },
                              controller: name,
                              keyboardType: TextInputType.name,
                              cursorColor: Colors.white,
                              style: title1.copyWith(color: Colors.black),
                              decoration: InputDecoration(
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                labelText: 'Enter a valid name',
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
                              focusNode: phoneNumberNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "phone Number can't be empty";
                                }
                                return null;
                              },
                              controller: phoneNumberController,
                              cursorColor: Colors.grey,
                              style: title1.copyWith(color: Colors.black),
                              decoration: InputDecoration(
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                labelText: 'Enter a phone number',
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
                            SizedBox(height: 25),
                            action_button(
                                title: 'Creat User',
                                action: () async {
                                  if (formKey.currentState!.validate()) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                     GoTo(
                                    context: context,
                                    screen: SignupScreen(
                                      name: name.text,
                                      phoneNumber: phoneNumberController.text,
                                    ),
                                  );
                                  }
                            
                                }),
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
