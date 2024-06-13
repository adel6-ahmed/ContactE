import 'package:flutter/material.dart';
import 'package:sad/screens/search_reasults_item.dart';
import 'package:sad/shared/widgets/loader.dart';

import '../services/firestore_functions.dart';
import '../shared/theme/colors.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
class SearchResultScreen extends StatelessWidget {
  final String phoneNumber;

  const SearchResultScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FireBaseServices().searchForContact(phoneNumber: phoneNumber), // Use phoneNumber directly
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
            return LoaderScreen();
          } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var results = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Search Results',
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
                  return SearchResultsItem(
                    contact: results[index],
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 20,
                    color: gri,
                    thickness: 1,
                  );
                },
                itemCount: results!.length,
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
}
