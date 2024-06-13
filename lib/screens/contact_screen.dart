import 'package:flutter/material.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/models.dart';
import '../shared/widgets/action_button.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import 'widgets/screen_widgets.dart';

class ContactScreen extends StatelessWidget {
  ContactScreen({super.key,required this.contact});
 
 MyUser contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'My Network',
            style: TextStyle(color: Colors.white), // Change text color to white
          ),
          leading: MyBackButton(),
        ),
        backgroundColor: Ldark,
        body: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  //SizedBox(height: 60),
                  CircleAvatar(
                    backgroundImage: NetworkImage(contact.img),
                    radius: 100,
                  ),
                  SizedBox(height: 15),
                  Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),

                  action_buttonWithIcon(
                    title: 'Add to my network',
                    icon: Icons.add,
                    action: () {},
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        contact.phoneNumber,
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 125, 125, 125),
                        ),
                      ),
                      IconButton(
                         onPressed: () async {
                               await launchUrl(Uri.parse(
                                    'tel:${contact.phoneNumber}'),);
                              },
                        icon: Icon(Icons.phone), // corrected
                        iconSize: 30,
                        color: Color.fromARGB(255, 125, 125, 125),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.builder(
                    itemCount: contact.socialMediaPlatforms.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, index) {
                      return ContactChanelCard(
                        platform: contact.socialMediaPlatforms.keys.toList()[index],
                        url: contact.socialMediaPlatforms.values.toList()[index].toString(),
                      );
                    },
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
       bottomNavigationBar: ButtomNavBar(selectedItemColor: gri,),
        extendBody: true,
      );
    
  }
}

