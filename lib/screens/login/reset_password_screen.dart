import 'package:flutter/material.dart';

class RestPasswoorddScreen extends StatelessWidget {
  const RestPasswoorddScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200,
        backgroundColor: Color.fromARGB(255, 28, 33, 32),
        elevation: 0,
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/ContactE.png',
              width: 260, // Adjust the width as needed
              height: 260, // Adjust the height as needed
              fit: BoxFit.contain, // Ensure the image fits within the available space
            ),
          ),
        ),
      ),
      body: body(context),
      extendBody: true,
    );
  }

  Widget body(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double blueContainerHeight = screenHeight * 0.8;

    return Container(
      color: Color.fromARGB(255, 28, 33, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(top: .0),
              decoration: BoxDecoration(),
            ),
          ),
          Expanded(
            child: Container(
              height: blueContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}