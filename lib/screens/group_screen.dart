import 'package:flutter/material.dart';
import 'package:sad/services/firebase_functions.dart';

import '../shared/theme/colors.dart';
import '../shared/widgets/GroupItem.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
        future: FireBaseServices().getGroups(id: '2j8M93CHwcvgL4KfAFaq'),
   
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var groups = snapshot.data;
            return Scaffold(
              backgroundColor: Ldark,
              appBar: AppBar(
                title: Text(
                  'Groups',
                  style: TextStyle(
                      color: Colors.white), // Change text color to white
                ),
                
                leading: MyBackButton(),
              ),
              body: GridView.builder(
                itemCount: groups!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemBuilder: (BuildContext context, index) {
                  return GroupItem(
                    myGroup: groups[index],
                  );
                },
                physics: BouncingScrollPhysics(),
                //shrinkWrap: true,
                //primary: false,
                padding: const EdgeInsets.all(10),
              ),
              bottomNavigationBar: ButtomNavBar(),
              extendBody: true,
            );
          } else {
            return Center(
              child: Text('No groups !'),
            );
          }
        });
        
  }
  
}
