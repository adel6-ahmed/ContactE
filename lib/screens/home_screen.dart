import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'package:sad/screens/my_network_screen.dart';
import 'package:sad/shared/methods/navigation.dart';

import '../shared/theme/colors.dart';
import '../shared/theme/texet.dart';
import '../shared/widgets/action_button.dart';
import '../shared/widgets/button_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  var PhoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        titleSpacing: 16,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Lottie animation as a motion background
          InkWell(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(left: 65.0),
              decoration: BoxDecoration(),
              child: ClipRRect(
                // borderRadius: BorderRadius.circular(10.0),
                child: Image.asset('assets/ContactE.png',
                    width: 280.0, height: 280.0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Container(
                margin: EdgeInsets.only(
                    right: 150.0), // Adjust the right margin as needed
                child: Lottie.asset(
                  'assets/adel6.json', // Path to your Lottie animation file
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: PhoneNumber,
                    keyboardType: TextInputType.phone,
                    cursorColor: white,
                    style: title1,
                    decoration: InputDecoration(
                      label: Text(
                        'enter the phone number',
                        style: title1.merge(TextStyle(color: gri)),
                      ),
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
                          color: white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  action_buttonWithIcon(
                    title: 'Search',
                    icon: Icons.search,
                    action: () {
                      print(PhoneNumber.text);
                      GoTo(context: context, screen: MyNetworkScreen());
                      //GoTo(context: context,screen: OnBoarding1());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:ButtomNavBar(),
       extendBody: true,
    );
  }
}
