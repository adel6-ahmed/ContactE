import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sad/services/firestore_functions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: EditProfileScreen(),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color Ldark = Color.fromARGB(255, 28, 33, 32);
  final Color BottomNavBarColor = Color.fromARGB(191, 28, 33, 32);
  final Color socialMediaIconColor = Color.fromARGB(255, 255, 215, 0); // Gold color
  final Color buttonColor = Color.fromARGB(255, 255, 215, 0); // Gold color for button

  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        backgroundColor: BottomNavBarColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white), // Title color
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow color
          onPressed: () {
            // Back button action
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Edit Social Media',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              buildSocialMediaTextField(
                context,
                controller: youtubeController,
                icon: FontAwesomeIcons.youtube,
                hint: 'enter a YouTube link',
              ),
              buildSocialMediaTextField(
                context,
                controller: facebookController,
                icon: FontAwesomeIcons.facebook,
                hint: 'enter a Facebook link',
              ),
              buildSocialMediaTextField(
                context,
                controller: whatsappController,
                icon: FontAwesomeIcons.whatsapp,
                hint: 'enter a Whatsapp number',
              ),
              buildSocialMediaTextField(
                context,
                controller: linkedinController,
                icon: FontAwesomeIcons.linkedin,
                hint: 'enter a LinkedIn link',
              ),
              buildSocialMediaTextField(
                context,
                controller: githubController,
                icon: FontAwesomeIcons.github,
                hint: 'enter a GitHub link',
              ),
              buildSocialMediaTextField(
                context,
                controller: instagramController,
                icon: FontAwesomeIcons.instagram,
                hint: 'enter an Instagram link',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, // Text color
                  backgroundColor: buttonColor, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSocialMediaTextField(BuildContext context, {required TextEditingController controller, required IconData icon, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: socialMediaIconColor), // Icon color
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: BottomNavBarColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      Map<String, dynamic> socialMedia = {
        'YouTube': youtubeController.text,
        'Facebook': facebookController.text,
        'Whatsapp': whatsappController.text,
        'LinkedIn': linkedinController.text,
        'GitHub': githubController.text,
        'Instagram': instagramController.text,
      };

      await FireBaseServices().updateUserSocialMedia(uid: uid, socialMedia: socialMedia);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile Updated Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
