import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactChannelCard extends StatelessWidget {
  final String platform;
  final String url;

  const ContactChannelCard({super.key, required this.platform, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Card(
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link, // 
                size: 40,
                color: Colors.blue,
              ),
              SizedBox(height: 10),
              Text(
                platform,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
