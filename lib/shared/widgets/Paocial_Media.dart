import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../theme/texet.dart';

class SocialMediaIcon extends StatelessWidget {
  final String platform;
  final Uri url;

  const SocialMediaIcon({
    required this.platform,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(url.toString())) {
          launch(url.toString());
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Column(
        children: [
          Icon(
            Icons.link,
            size: 30,
            color: light, // Using light color from colors.dart
          ),
          SizedBox(height: 5),
          Text(
            platform,
            style: body, // Using body from colors.dart
          ),
        ],
      ),
    );
  }
}
