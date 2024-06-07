import 'package:flutter/material.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/widgets/action_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import 'widgets/screen_widgets.dart'; // Make sure you import ContactChanelCard from the correct location

class ContactScreen extends StatelessWidget {
  ContactScreen({Key? key}) : super(key: key);

  final Uri phoneNumber = Uri.parse('tel:+22220831782');
 final Map<String, Uri> myContacts = {
  'GITHUB': Uri.parse('https://github.com/adel6-ahmed'),
  'INSTAGRAM': Uri.parse('https://www.instagram.com/adel.ahmedou/'),
  'threads': Uri.parse('https://www.youtube.com/@soloburadaydi/videos'),
  'Gmail': Uri.parse('mailto:example@gmail.com'),
  'X': Uri.parse('https://www.instagram.com/adel.ahmedou/'),
  'tiktok': Uri.parse('https://www.youtube.com/@soloburadaydi/videos'),
  'ms': Uri.parse('https://www.youtube.com/@soloburadaydi/videos'),
  'Snapchat': Uri.parse('https://www.youtube.com/@soloburadaydi/videos'),
  'LINK': Uri.parse('mailto:example@gmail.com'),
};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      left: true,
      top: true,
      right: true,
      maintainBottomViewPadding: true,
      minimum: EdgeInsets.zero,
      child: Scaffold(
          appBar: AppBar(
        title: Text(
          'My Network',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        leading: BackButton(),
      ),
        backgroundColor: Color.fromARGB(255,  28, 33, 32),
        body: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
               
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/whatsapp.png'),
                    radius: 100,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Mohamd ahmed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height:10),

                  action_buttonWithIcon(title: 'Add to my network', icon: Icons.add,
                    action: (){print('contact added to my network');
                     
                    }
                    ,
                 ),
                 
                 // SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+22220831782',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 125, 125, 125),
                        ),
                      ),

                      IconButton(
                        onPressed: () async {
                          launch(phoneNumber.toString());
                        },
                        icon: Icon(Icons.phone), // corrected
                        iconSize: 30,
                        color: Color.fromARGB(255, 125, 125, 125),
                      )
                    ],
                  ),
                  SizedBox(height: 20),

                  GridView.builder(
                    itemCount: myContacts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, index) {
                      return ContactChanelCard(
                        platform: myContacts.keys.toList()[index],
                        url: myContacts.values.toList()[index].toString(),
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
      ),
    );
  }
}
