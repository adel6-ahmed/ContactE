import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class ContactChanelCard extends StatelessWidget {
  final String platform;
  final String url;

  const ContactChanelCard({
    super.key,
    required this.platform,
    required this.url,
  });

  @override

  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 4,
          child: InkWell(
            onTap: () async {
              await launchUrl(Uri.parse(url),  mode: LaunchMode.externalApplication);
            },
            child: Image(
              image: AssetImage(
                'assets/$platform.png',
                ),
                height: 80,
                width: 80,
                fit: BoxFit.cover),
              ))
      ]);

  }
}