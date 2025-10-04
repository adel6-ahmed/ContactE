import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sad/services/firestore_functions.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:sad/shared/widgets/action_button.dart';
import 'package:sad/shared/widgets/back_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Map<TextEditingController, String> _socialMediaFields = {
    TextEditingController(): 'YouTube',
    TextEditingController(): 'Facebook',
    TextEditingController(): 'WhatsApp',
    TextEditingController(): 'LinkedIn',
    TextEditingController(): 'GitHub',
    TextEditingController(): 'Instagram',
  };

  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _socialMediaFields.keys) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          'Edit Social Media',
          style: h3Bold.copyWith(color: Lyellow),
        ),
        backgroundColor: Ldark,
        leading: MyBackButton(),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    color: Lyellow,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Social Media Links',
                          style: h4Bold.copyWith(color: Colors.white),
                        ),
                        Text(
                          'Add your social media profiles',
                          style: title2.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Social Media Fields
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ..._socialMediaFields.entries.map((entry) {
                    return _buildSocialMediaField(
                      controller: entry.key,
                      platform: entry.value,
                      icon: _getPlatformIcon(entry.value),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 30),
                  
                  // Update Button
                  _buildUpdateButton(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaField({
    required TextEditingController controller,
    required String platform,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Lyellow,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  platform,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your $platform link',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Lyellow, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return _isLoading 
        ? Container(
            height: 50,
            decoration: BoxDecoration(
              color: Lyellow.withOpacity(0.6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        : ActionButton(
            title: 'Update Profile',
            action: _updateProfile,
            buttonColor: Lyellow,
          );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'github':
        return FontAwesomeIcons.github;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      default:
        return Icons.link;
    }
  }

  void _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    final socialMedia = <String, dynamic>{};
    for (final entry in _socialMediaFields.entries) {
      if (entry.key.text.isNotEmpty) {
        socialMedia[entry.value] = entry.key.text;
      }
    }

    try {
      await FireBaseServices().updateUserSocialMedia(
        uid: user.uid,
        socialMedia: socialMedia,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully',
            style: TextStyle(color: Ldark),
          ),
          backgroundColor: Lyellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}