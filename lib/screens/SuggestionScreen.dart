import 'package:flutter/material.dart';
import 'package:sad/services/firestore_functions.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/widgets/back_button.dart';
import 'package:sad/shared/widgets/button_nav_bar.dart';

class SuggestionScreen extends StatelessWidget {
  final String userId;

  SuggestionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions', style: TextStyle(color: Colors.white)),
        backgroundColor: Ldark,
        leading: MyBackButton(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Ldark,
              Colors.black87, // Adding some gradient for a stylish look
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<MyUser>>(
          future: FireBaseServices().getSuggestedFriends(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.yellow));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.redAccent)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No suggestions available', style: TextStyle(color: Colors.white)));
            } else {
              var suggestedFriends = snapshot.data!;
              return ListView.builder(
                itemCount: suggestedFriends.length,
                itemBuilder: (context, index) {
                  var friend = suggestedFriends[index];
                  return Card(
                    color: Colors.black54,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/whatsapp.png'),
                        radius: 30,
                      ),
                      title: Text(friend.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${friend.interests.length} common interests', style: TextStyle(color: Colors.grey)),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Functionality to add friend
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Ldark, backgroundColor: Colors.yellow, // Button text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Rounded corners
                          ),
                        ),
                        child: Text('Add Friend'),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: ButtomNavBar(),
      extendBody: true,
    );
  }
}
