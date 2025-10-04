import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:sad/services/models.dart';
import 'package:sad/services/firestore_functions.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/widgets/button_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      body: FutureBuilder<MyUser>(
        future: FireBaseServices().getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          } else if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            _debugUserData(user); // Debug data
            return _buildProfileScreen(user);
          } else {
            return _buildEmptyScreen();
          }
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildProfileScreen(MyUser user) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar with centered profile image
        SliverAppBar(
          expandedHeight: 280.0,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: Icon(Icons.arrow_back_ios_rounded, 
                color: Lyellow, size: 20),
            ),
          ),
          actions: [
            IconButton(
              onPressed: _refreshProfile,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Icon(Icons.refresh_rounded, 
                  color: Lyellow, size: 20),
              ),
            ),
          ],
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final top = constraints.biggest.height;
              return FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Lyellow.withOpacity(0.8),
                        Ldark.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background decorative elements
                      Positioned(
                        top: 50,
                        right: 20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        left: 20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Centered Profile Content
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Image - Perfectly Centered
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    user.img.isNotEmpty ? user.img : 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [Colors.white, Colors.grey],
                                          ),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / 
                                                  loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: Lyellow,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [Lyellow, Color(0xFFFFC400)],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Display occupation if available
                              if (_getInterestValue(user.interests, 'occupation').isNotEmpty)
                                Text(
                                  _getInterestValue(user.interests, 'occupation'),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              // Display location if available
                              if (_getInterestValue(user.interests, 'country').isNotEmpty)
                                Text(
                                  _getInterestValue(user.interests, 'country'),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Profile content
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Basic Information
                        _buildBasicInfo(user),
                        const SizedBox(height: 20),
                        
                        // Contact Information
                        _buildContactInfo(user),
                        const SizedBox(height: 20),
                        
                        // Social Media
                        _buildSocialMedia(user),
                        const SizedBox(height: 20),
                        
                        // Interests - FIXED VERSION
                        _buildInterestsFixed(user),
                        const SizedBox(height: 30),
                        
                        // Action Buttons
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(MyUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Ldark.withOpacity(0.1),
                ),
                child: Icon(Icons.person_rounded, color: Ldark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Ldark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Phone Number
          _buildInfoRow('Phone Number', user.phoneNumber, Icons.phone_rounded),
          
          // Additional info from interests
          if (_getInterestValue(user.interests, 'occupation').isNotEmpty)
            _buildInfoRow('Occupation', _getInterestValue(user.interests, 'occupation'), Icons.work_rounded),
          
          if (_getInterestValue(user.interests, 'country').isNotEmpty)
            _buildInfoRow('Location', _getInterestValue(user.interests, 'country'), Icons.location_on_rounded),
          
          if (_getInterestValue(user.interests, 'age').isNotEmpty)
            _buildInfoRow('Age', '${_getInterestValue(user.interests, 'age')} years', Icons.cake_rounded),
          
          // Email if available
          if (_getInterestValue(user.interests, 'email').isNotEmpty)
            _buildInfoRow('Email', _getInterestValue(user.interests, 'email'), Icons.email_rounded),
          
          // Account status
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Account',
                        style: TextStyle(
                          color: Ldark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Your profile is active and complete',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lyellow.withOpacity(0.1),
            ),
            child: Icon(icon, color: Ldark, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Ldark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(MyUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Ldark.withOpacity(0.1),
                ),
                child: Icon(Icons.contact_phone_rounded, color: Ldark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Ldark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Call button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _makePhoneCall(user.phoneNumber),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Lyellow.withOpacity(0.2),
                      ),
                      child: Icon(Icons.phone_rounded, color: Ldark, size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mobile Number',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.phoneNumber,
                            style: TextStyle(
                              color: Ldark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMedia(MyUser user) {
    final validSocialMedia = user.socialMediaPlatforms.entries
        .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Ldark.withOpacity(0.1),
                ),
                child: Icon(Icons.public_rounded, color: Ldark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Social Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Ldark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (validSocialMedia.isEmpty)
            _buildEmptySection(
              icon: Icons.link_off_rounded,
              title: 'No Social Media',
              subtitle: 'Connect your social media accounts',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: validSocialMedia.length,
              itemBuilder: (context, index) {
                final platform = validSocialMedia[index].key;
                final url = validSocialMedia[index].value.toString();
                return _buildSocialMediaItem(platform, url);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaItem(String platform, String url) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Lyellow.withOpacity(0.1),
                ),
                child: Icon(
                  _getPlatformIcon(platform),
                  color: Ldark,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getPlatformName(platform),
                style: TextStyle(
                  fontSize: 10,
                  color: Ldark,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsFixed(MyUser user) {
    // Get all interests excluding basic profile fields
    final validInterests = user.interests.entries
        .where((entry) => 
            entry.value != null && 
            entry.value.toString().isNotEmpty &&
            !['occupation', 'country', 'age', 'email', 'phone'].contains(entry.key.toLowerCase()))
        .toList();

    print('=== INTERESTS DEBUG ===');
    print('All interests: ${user.interests}');
    print('Valid interests count: ${validInterests.length}');
    print('Valid interests: $validInterests');
    print('=======================');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Ldark.withOpacity(0.1),
                ),
                child: Icon(Icons.interests_rounded, color: Ldark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Interests & Hobbies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Ldark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (validInterests.isEmpty)
            _buildEmptySection(
              icon: Icons.emoji_objects_rounded,
              title: 'No Interests Added',
              subtitle: 'Add your interests to personalize your profile',
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display as chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: validInterests
                      .map((entry) => _buildInterestChip(entry.value.toString()))
                      .toList(),
                ),
                const SizedBox(height: 10),
                // Display as list for debugging
                ...validInterests.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    style: TextStyle(
                      color: Ldark,
                      fontSize: 14,
                    ),
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Lyellow, const Color(0xFFFFC400)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Lyellow.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        interest,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Main edit button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Lyellow, const Color(0xFFFFC400)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Lyellow.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showEditOptions,
                borderRadius: BorderRadius.circular(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Settings button
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showSettings,
              borderRadius: BorderRadius.circular(15),
              child: Icon(
                Icons.settings_rounded,
                color: Ldark,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade400,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper functions
  IconData _getPlatformIcon(String platform) {
    final lowerPlatform = platform.toLowerCase();
    if (lowerPlatform.contains('facebook')) return Icons.facebook_rounded;
    if (lowerPlatform.contains('twitter') || lowerPlatform.contains('x')) return Icons.circle_rounded;
    if (lowerPlatform.contains('instagram')) return Icons.camera_alt_rounded;
    if (lowerPlatform.contains('linkedin')) return Icons.business_center_rounded;
    if (lowerPlatform.contains('whatsapp')) return Icons.chat_rounded;
    if (lowerPlatform.contains('snapchat')) return Icons.photo_camera_rounded;
    if (lowerPlatform.contains('youtube')) return Icons.play_arrow_rounded;
    if (lowerPlatform.contains('tiktok')) return Icons.music_note_rounded;
    return Icons.link_rounded;
  }

  String _getPlatformName(String platform) {
    final lowerPlatform = platform.toLowerCase();
    if (lowerPlatform.contains('facebook')) return 'FB';
    if (lowerPlatform.contains('twitter') || lowerPlatform.contains('x')) return 'X';
    if (lowerPlatform.contains('instagram')) return 'IG';
    if (lowerPlatform.contains('linkedin')) return 'IN';
    if (lowerPlatform.contains('whatsapp')) return 'WA';
    if (lowerPlatform.contains('snapchat')) return 'SC';
    if (lowerPlatform.contains('youtube')) return 'YT';
    if (lowerPlatform.contains('tiktok')) return 'TT';
    return platform.length > 8 ? '${platform.substring(0, 8)}..' : platform;
  }

  String _getInterestValue(Map<String, dynamic> interests, String key) {
    final value = interests[key];
    return value != null ? value.toString() : '';
  }

  void _debugUserData(MyUser user) {
    print('=== USER DATA DEBUG ===');
    print('Name: ${user.name}');
    print('Phone: ${user.phoneNumber}');
    print('Image URL: ${user.img}');
    print('Social Media Platforms: ${user.socialMediaPlatforms}');
    print('Interests: ${user.interests}');
    print('Social Media Count: ${user.socialMediaPlatforms.length}');
    print('Interests Count: ${user.interests.length}');
    print('Interests Keys: ${user.interests.keys.toList()}');
    print('Interests Values: ${user.interests.values.toList()}');
    print('========================');
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            // Options
            _buildEditOption('Edit Profile Info', Icons.person_rounded),
            _buildEditOption('Change Photo', Icons.camera_alt_rounded),
            _buildEditOption('Social Media', Icons.link_rounded),
            _buildEditOption('Privacy Settings', Icons.security_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildEditOption(String title, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Lyellow.withOpacity(0.1),
        ),
        child: Icon(icon, color: Ldark),
      ),
      title: Text(title, style: TextStyle(color: Ldark, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
      onTap: () {
        Navigator.pop(context);
        _showComingSoon();
      },
    );
  }

  void _showSettings() {
    _showComingSoon();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚀 Feature Coming Soon!',
          style: TextStyle(color: Ldark, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Lyellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _refreshProfile() {
    setState(() {});
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      await launchUrl(Uri.parse('tel:$phoneNumber'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to make call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open URL: $url'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Loading and error screens
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Ldark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Lyellow),
            const SizedBox(height: 20),
            Text(
              'Loading Profile...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Ldark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'We couldn\'t load your profile. Please check your connection.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Lyellow, const Color(0xFFFFC400)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _refreshProfile,
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      backgroundColor: Ldark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No Profile Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create your profile to get started',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Lyellow, const Color(0xFFFFC400)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigate to profile creation screen
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Text(
                      'Create Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}