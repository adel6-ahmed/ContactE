import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sad/screens/SuggestionScreen.dart';

import '../../screens/group_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/my_network_screen.dart';
import '../../screens/profile_screen.dart';

import '../methods/navigation.dart';
import '../theme/colors.dart';

class ButtomNavBar extends StatelessWidget {
  ButtomNavBar({
    super.key,
    this.selectedItemColor,
  });
  static int index = 2;
  Color? selectedItemColor;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomNavigationBar(
        backgroundColor: BottomNavBarColor,
        selectedItemColor: selectedItemColor ?? Lyellow,
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.earthAfrica), label: ''),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.peopleGroup), label: ''),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.house), label: ''),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userLarge), label: ''),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bell), label: ''),
        ],
        onTap: (value) {
          if (value == 0) {
            index = 0;
            GoTo(
              context: context,
              screen: MyNetworkScreen(),
            );
          } else if (value == 1) {
            index = value;
            GoTo(
              context: context,
              screen: GroupScreen(),
            );
          } else if (value == 2) {
            index = value;
            GoTo(
              context: context,
              screen: HomeScreen(),
            );
          } else if (value == 3) {
            index = value;
            GoTo(
              context: context,
              screen: ProfileScreen(),
            );
          } else if (value == 4) {
            index = value;
            GoTo(
              context: context,
              screen: SuggestionScreen(userId: 'some_user_id'),
            );
          }
        },
      ),
    );
  }
}
