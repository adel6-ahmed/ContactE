import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/firestore_functions.dart';
import '../services/models.dart';
import '../shared/theme/colors.dart';
import '../shared/theme/texet.dart';
import '../shared/widgets/Paction_bottom.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import '../shared/widgets/loader.dart';
import 'widgets/social_media_icon.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FireBaseServices().getUser(),
      builder: (context, AsyncSnapshot<MyUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return LoaderScreen();
          }else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        } else if (snapshot.hasData) {
          MyUser profileOwner = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '${profileOwner.name}',
                style: title1.copyWith(color: Lyellow),
              ),
              backgroundColor: Ldark,
              leading: MyBackButton(),
            ),
            backgroundColor: Ldark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Lyellow,
                          Ldark,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Lyellow,
                                Ldark,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(profileOwner.img),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${profileOwner.name}',
                          style: TextStyle(
                            fontSize: 33,
                            color: light,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ActionButton(
                              title: 'Edit Profile',
                              onPressed: () {
                                print('Edit Profile');
                              },
                              buttonColor: gri,
                              textColor: light,
                            ),
                            SizedBox(width: 20),
                            ActionButton(
                              title: 'Delete Profile',
                              onPressed: () {
                                AwesomeDialog(
                                  titleTextStyle:
                                      h4Bold.merge(TextStyle(color: black)),
                                  context: context,
                                  dialogType: DialogType.warning,
                                  borderSide: const BorderSide(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                  width: 280,
                                  buttonsBorderRadius: const BorderRadius.all(
                                    Radius.circular(2),
                                  ),
                                  dismissOnTouchOutside: true,
                                  dismissOnBackKeyPress: false,
                                  onDismissCallback: (type) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Dismissed by $type'),
                                      ),
                                    );
                                  },
                                  headerAnimationLoop: false,
                                  animType: AnimType.bottomSlide,
                                  title: 'Delete Profile',
                                  desc:
                                      'Are you sure that you want to delete your profile?',
                                  showCloseIcon: true,
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () {
                                    print("Delete My Profile");
                                  },
                                ).show();
                              },
                              buttonColor: red,
                              textColor: light,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: title1,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              Text(
                              '${profileOwner.phoneNumber}',
                              style: title2,
                            ),
                            IconButton(
                              onPressed: () async {
                               await launchUrl(Uri.parse(
                                    'tel:${profileOwner.phoneNumber}'));
                              },
                              icon: Icon(Icons.phone, color: light),
                            ),
                          
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Social Media',
                          style: title2,
                        ),
                        SizedBox(height: 40),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: profileOwner.socialMediaPlatforms.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ContactChanelCard(
                              platform: profileOwner.socialMediaPlatforms.keys
                                  .toList()[index],
                              url:
                                  '${profileOwner.socialMediaPlatforms.values.toList()[index]}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: ButtomNavBar(),
            extendBody: true,
          );
        } else {
          return Scaffold(
            body: Center(
              child: Text('No Profile was found'),
            ),
          );
        }
      },
    );
  }
}
