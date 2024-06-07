import 'package:flutter/material.dart';
import 'package:sad/screens/friend_screen.dart';
import 'package:sad/shared/methods/navigation.dart';

import '../../services/firebase_functions.dart';
import '../../services/models.dart';
import '../theme/colors.dart';
import '../theme/texet.dart';

class ContactCard extends StatelessWidget {
  ContactCard({
    Key? key,
    required this.userId,
  }) : super(key: key);
  String userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FireBaseServices().getUserById(id: userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var friend = snapshot.data;
          return GestureDetector(
            onTap: () {
              GoTo(
                context: context,
                screen: FriendScreen(friend: friend),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38.5,
                  backgroundImage: NetworkImage(friend!.img),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: title1,
                    ),
                    Text(
                      friend.phoneNumber,
                      style: title1.merge(
                        TextStyle(color: gri),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        else {
          return SizedBox();
        }
      },
    );
  }
}
