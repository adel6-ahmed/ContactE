import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sad/screens/home_screen.dart';
import 'package:sad/services/auth_service.dart';

class InterestsScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;

  InterestsScreen({required this.name, required this.phoneNumber});

  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  late TextEditingController countryController;
  late TextEditingController ageController;
  late TextEditingController socialMediaController;
  late TextEditingController occupationController;
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    countryController = TextEditingController();
    ageController = TextEditingController();
    socialMediaController = TextEditingController();
    occupationController = TextEditingController();
    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    countryController.dispose();
    ageController.dispose();
    socialMediaController.dispose();
    occupationController.dispose();
    super.dispose();
  }

  void submitInterests() async {
    if (formKey.currentState!.validate()) {
      try {
        // Save interests to Firestore
        await FirebaseFirestore.instance.collection('users').add({
          'name': widget.name,
          'phoneNumber': widget.phoneNumber,
          'interests': {
            'country': countryController.text,
            'age': ageController.text,
            'social_media': socialMediaController.text,
            'occupation': occupationController.text,
          },
        });

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (error) {
        print("Failed to add interests: $error");
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: Text(
          'Interests',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255), // Change color here
          ),
        ),
        backgroundColor: Color.fromARGB(255, 28, 33, 32), // Dark background color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 28, 33, 32),
              Color.fromARGB(255, 255, 215, 0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: socialMediaController,
                decoration: InputDecoration(
                  labelText: 'Favorite Social Media',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your favorite social media';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: occupationController,
                decoration: InputDecoration(
                  labelText: 'Occupation',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your occupation';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitInterests,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Color.fromARGB(255, 255, 215, 0), // Text color
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

