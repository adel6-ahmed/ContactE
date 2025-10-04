import 'package:flutter/material.dart';
import 'package:sad/screens/contact_screen.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/methods/navigation.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';


class SearchResultsItem extends StatelessWidget {
  const SearchResultsItem({
    super.key,
    required this.contact,
  });

  final MyUser contact;

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
            onTap: () {
              GoTo(
                context: context,
                screen: ContactScreen(contact:contact),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38.5,
                  backgroundImage: NetworkImage(contact.img),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name, style: title1),
                    Text(
                      contact.phoneNumber,
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
}
