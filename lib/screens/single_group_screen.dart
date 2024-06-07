import 'package:flutter/material.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';

import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import '../shared/widgets/contact_card.dart';

class SingleGroupScreen extends StatelessWidget {
  SingleGroupScreen({super.key, required this.myGroup}); 
   Group myGroup;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          myGroup.name,
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        leading: MyBackButton(),
      ),
      backgroundColor: Colors.grey[900], // Change background color to dark
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image(
                  image:  NetworkImage(myGroup.img),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Group Members',
                style: h3Bold,
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return ContactCard(
                      userId: myGroup.members[index],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 20,
                      color: gri,
                      thickness: 1,
                    );
                  },
                  itemCount: myGroup.members.length,
                  physics: BouncingScrollPhysics(),
                ),
              ),
            ])),
      ),
      bottomNavigationBar: ButtomNavBar(
        selectedItemColor: gri,
      ),
      extendBody: true,
    );
  }
}