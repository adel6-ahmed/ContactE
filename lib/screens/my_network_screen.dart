import 'package:flutter/material.dart';

import '../../services/firebase_functions.dart';
import '../shared/theme/colors.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import '../shared/widgets/contact_card.dart';
class MyNetworkScreen extends StatelessWidget {
  const MyNetworkScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FireBaseServices().getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Text('Now is waiting'),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        } else if (snapshot.hasData) {
          var user = snapshot.data;
          var myNetwork = user!.uid;
          if (myNetwork.isEmpty) {
            return Center(
              child: Text('No Friends to show'),
            );
          } else {
            return FutureBuilder(
              future: FireBaseServices().getNetwork(id: myNetwork),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  var myNetworkObj = snapshot.data;
                  var myNetworkList = myNetworkObj!.myNetwork;
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(
                        'My Network',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      leading: MyBackButton(),
                    ),
                    backgroundColor: Ldark,
                    body: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return ContactCard(
                            userId: myNetworkList[index],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 20,
                            color: gri,
                            thickness: 1,
                          );
                        },
                        itemCount: myNetworkList.length,
                        physics: BouncingScrollPhysics(),
                      ),
                    ),
                    bottomNavigationBar: ButtomNavBar(),
                    extendBody: true,
                  );
                } else {
                  return SizedBox();
                }
              },
            );
          }
        } else {
          return Scaffold(
            body: Center(
              child: Text('There are no Friends'),
            ),
          );
        }
      },
    );
  }
}
