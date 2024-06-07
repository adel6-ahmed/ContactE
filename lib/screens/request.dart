import 'package:flutter/material.dart';
import 'package:sad/shared/theme/colors.dart';

import '../services/models.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import 'friend_screen.dart';
// Import FriendScreen if not already imported
// import '../screens/friend_screen.dart';

class request extends StatelessWidget {
 request({Key? key,});


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suggestions',
          style: TextStyle(color: light),
        ),
        backgroundColor: Ldark,
        leading: MyBackButton(), // Dark background color for AppBar
      ),
      
      body: Container(
        color: Ldark, // Dark blue background color
        child: Container(
          decoration: BoxDecoration(
            color: Ldark, // White color for the section
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(70),
              topLeft: Radius.circular(70),
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/whatsapp.png'),
                  ),
                  title: Text(
                    'Adel AHMED',
                    style: TextStyle(color: light),
                  ),
                  subtitle: Text(
                    '2 mutual friends',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                  
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.yellow),
                    ),
                    child: Text(
                      'Add Friend',
                      style: TextStyle(color: Ldark),
                    ),
                  ),
                ),
              ),
              // Add more ListTile widgets for other suggestions
            ],
          ),
        ),
      ),
      // Replace ButtomNavBar with your actual bottom navigation bar
       bottomNavigationBar: ButtomNavBar(),
        extendBody: true,
    );
  }
}
