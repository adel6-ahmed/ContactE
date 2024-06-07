import 'package:flutter/material.dart';
import 'package:sad/screens/home_screen.dart';

import '../../shared/methods/navigation.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/action_button.dart';
import 'onboarding2.dart';
import 'onboarding3.dart';

class OnBoarding3 extends StatelessWidget {
  const OnBoarding3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // One-fifth of the screen height with Ldark color
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 5,
            child: Container(
              color: Ldark,
            ),
          ),
          // Remaining four-fifths with white color
          Positioned.fill(
            top: MediaQuery.of(context).size.height / 5,
            child: Container(
              color: Colors.white,
            ),
          ),
          // Image positioned above the white section
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/5.png',
                  fit: BoxFit.fill, // Ensure the image fills the container
                ),
                   Text(
                        'Share it!\n',
                        style: TextStyle(
                          fontSize: 24, // Larger font size for "ContactE"
                          fontWeight: FontWeight.bold, // Optional: Add bold font weight
                        ),
                      ),
                         Text(
                        'A simple explanation to the audience \n             regarding the headline',
                        style: TextStyle(
                          fontSize: 16, // Font size for the rest of the sentence
                        ),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150, right: 100),
        child: action_button(
          title: '         Next          ', 
          
          action: () {
            GoTo(context: context, screen: HomeScreen());
          },
          fontSize: 20,
        ),
      ),
    );
  }
}