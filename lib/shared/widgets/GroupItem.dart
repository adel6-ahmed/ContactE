import 'package:flutter/material.dart';
import 'package:sad/screens/single_group_screen.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/methods/navigation.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';

class GroupItem extends StatelessWidget {
  GroupItem({super.key, required this.myGroup});
   Group myGroup;
  @override
  Widget build(BuildContext context) {
    print("=====================");
    print(myGroup.members);
     print("=====================");
    return GestureDetector(
      onTap: () {
        GoTo(context: context, screen: SingleGroupScreen(myGroup: myGroup));
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(gri, BlendMode.darken),
                fit: BoxFit.cover,
                image: NetworkImage(myGroup.img),
              ),
              color: Lyellow,
              borderRadius: BorderRadius.circular(39),
            ),
          ),
          Center(
              child: Text(
                myGroup.name,
                style: h3Bold,
              ),
            ),
        ],
      ),
    );
  }
}
