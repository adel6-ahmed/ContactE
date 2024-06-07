import 'package:flutter/material.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/models.dart';
import '../shared/widgets/action_button.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import 'widgets/screen_widgets.dart';

class FriendScreen extends StatelessWidget {
  FriendScreen({super.key,required this.friend});
 
 MyUser friend;

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
                    backgroundImage: NetworkImage(friend.img),
                    radius: 100,
                  ),
                  SizedBox(height: 15),
                  Text(
                    friend.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),

                  action_buttonWithIcon(
                    title: 'Add to a group',
                    icon: Icons.add,
                    action: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              color: Ldark,
                            ),
                            height: 300,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 20),
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Lyellow,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(9))),
                                        width: 75,
                                        height: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12, left: 16),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextButton(
                                                onPressed: () { print('Text button was pressed');},
                                                child: Text(
                                                  '. Work',
                                                  style: h3,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              TextButton(
                                                onPressed: () { print('Text button was pressed');},
                                                child: Text(
                                                  '. University',
                                                  style: h3,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              TextButton(
                                                onPressed: () { print('Text button was pressed');},
                                                child: Text(
                                                  '. Gym',
                                                  style: h3,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  print('Text button was pressed');
                                                },
                                                child: Text(
                                                  '. Cami',
                                                  style: h3,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              TextButton(
                                                onPressed: () { print('Text button was pressed');},
                                                child: Text(
                                                  '. Yurt',
                                                  style: h3,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              TextButton(
                                                onPressed: () { print('Text button was pressed');},
                                                child: Text(
                                                  '. Country',
                                                  style: h3,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      print('friend added to a group');
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        friend.phoneNumber,
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 125, 125, 125),
                        ),
                      ),
                      IconButton(
                         onPressed: () async {
                               await launchUrl(Uri.parse(
                                    'tel:${friend.phoneNumber}'),);
                              },
                        icon: Icon(Icons.phone), // corrected
                        iconSize: 30,
                        color: Color.fromARGB(255, 125, 125, 125),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.builder(
                    itemCount: friend.socialMediaPlatforms.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, index) {
                      return ContactChanelCard(
                        platform: friend.socialMediaPlatforms.keys.toList()[index],
                        url: friend.socialMediaPlatforms.values.toList()[index].toString(),
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
