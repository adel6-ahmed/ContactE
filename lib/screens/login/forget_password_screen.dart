import 'package:flutter/material.dart';

import '../../shared/theme/colors.dart';
import '../../shared/theme/texet.dart';
import '../../shared/widgets/action_button.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // blueContainerHeight was unused and removed

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150), // Adjust the height of the app bar as needed
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0), // Adjust the top padding here
          child: AppBar(
            title: Text(
              'Forget my password',
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  size: 40, color: Lyellow), // Ensure the icon color is white
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: Color.fromARGB(255, 28, 33, 32),
            elevation: 0,
            flexibleSpace: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Ldark,
          child: Column(
            children: [
              Container(
                height: 653, // Set a fixed height for the white section
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType
                          .emailAddress, // Use appropriate keyboard type for email
                      cursorColor: white,
                      style: title1.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'new passaword',
                        labelStyle: title1.merge(TextStyle(color: gri)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: gri,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Lyellow,
                            width: 2,
                          ),
                        ),
                      ),
                    ), // Add your text field for email or username
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true, // Hide entered text for passwords
                      cursorColor: gri,
                      style: title1.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'now passaword',
                        labelStyle: title1.merge(TextStyle(color: gri)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: gri,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Lyellow,
                            width: 2,
                          ),
                        ),
                      ),
                    ), // Add your text field for password
                    SizedBox(height: 20),
                    ActionButton(
                        title: '                    Login                    ',
                        action: () {}),
                        SizedBox(height: 150)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
