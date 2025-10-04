import 'package:flutter/material.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class FriendScreen extends StatefulWidget {
  final MyUser friend;

  const FriendScreen({super.key, required this.friend});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isAddedToNetwork = false;

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
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleNetworkStatus() {
    setState(() {
      _isAddedToNetwork = !_isAddedToNetwork;
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAddedToNetwork 
            ? 'Added to Network Successfully! ✅'
            : 'Removed from Network',
          style: TextStyle(color: Ldark),
        ),
        backgroundColor: Lyellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _makePhoneCall() async {
    try {
      await launchUrl(Uri.parse('tel:${widget.friend.phoneNumber}'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to make call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showGroupsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGroupsBottomSheet(),
    );
  }

  Widget _buildGroupsBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Ldark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            child: Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.group_rounded, color: Lyellow, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Add to Group',
                  style: h3Bold.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Choose a group to add ${widget.friend.name}',
              style: title2.copyWith(color: Colors.white70),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Groups List
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildGroupItem('Work', Icons.work_rounded),
                _buildGroupItem('University', Icons.school_rounded),
                _buildGroupItem('Gym', Icons.fitness_center_rounded),
                _buildGroupItem('Family', Icons.family_restroom_rounded),
                _buildGroupItem('Friends', Icons.people_rounded),
                _buildGroupItem('Business', Icons.business_rounded),
                _buildGroupItem('Travel', Icons.flight_rounded),
                _buildGroupItem('Sports', Icons.sports_soccer_rounded),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGroupItem(String name, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Lyellow.withOpacity(0.2),
          ),
          child: Icon(icon, color: Lyellow, size: 22),
        ),
        title: Text(name, style: title1.copyWith(color: Colors.white)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Icon(Icons.add_rounded, color: Lyellow, size: 18),
        ),
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to $name group ✅'),
              backgroundColor: Lyellow,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          'Contact Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(Icons.arrow_back_rounded, color: Lyellow, size: 24),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Share functionality
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(Icons.share_rounded, color: Lyellow, size: 22),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Profile Header Section
                      _buildProfileHeader(),
                      
                      const SizedBox(height: 30),
                      
                      // Action Buttons Section
                      _buildActionButtons(),
                      
                      const SizedBox(height: 30),
                      
                      // Contact Information Section
                      _buildContactInfo(),
                      
                      const SizedBox(height: 30),
                      
                      // Social Media Section
                      _buildSocialMediaSection(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Lyellow.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white,
            const Color(0xFFfafafa),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar with Decoration
          Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Lyellow.withOpacity(0.2),
                      Lyellow.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 0.5, 1.0],
                  ),
                ),
              ),
              
              // Profile Image
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Lyellow,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Lyellow.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.friend.img,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Lyellow,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Ldark,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Name and Additional Info
          Column(
            children: [
              Text(
                widget.friend.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Ldark,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Phone Number
              Text(
                widget.friend.phoneNumber,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Interests from user data (if available)
          if (widget.friend.interests.isNotEmpty)
            _buildInterestsChips(),
        ],
      ),
    );
  }

  Widget _buildInterestsChips() {
    final interests = widget.friend.interests;
    final validInterests = interests.entries
        .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
        .take(3) // Limit to 3 interests
        .toList();

    if (validInterests.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: validInterests.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Lyellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Lyellow.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 12, color: Ldark),
              const SizedBox(width: 4),
              Text(
                entry.value.toString(),
                style: TextStyle(
                  color: Ldark,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Add to Network Button
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 55,
              decoration: BoxDecoration(
                color: _isAddedToNetwork ? Colors.green : Lyellow,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: (_isAddedToNetwork ? Colors.green : Lyellow).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleNetworkStatus,
                  borderRadius: BorderRadius.circular(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAddedToNetwork ? Icons.check_rounded : Icons.person_add_rounded,
                        color: Ldark,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAddedToNetwork ? 'Added to Network' : 'Add to Network',
                        style: TextStyle(
                          color: Ldark,
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
          
          // Call Button
          Container(
            height: 55,
            width: 55,
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
                onTap: _makePhoneCall,
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      color: Ldark,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Groups Button
          Container(
            height: 55,
            width: 55,
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
                onTap: _showGroupsBottomSheet,
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_add_rounded,
                      color: Ldark,
                      size: 24,
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

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.contact_phone_rounded, color: Ldark, size: 22),
              const SizedBox(width: 8),
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
          
          const SizedBox(height: 20),
          
          // Phone Number
          _buildInfoItem(
            icon: Icons.phone_iphone_rounded,
            title: 'Phone Number',
            value: widget.friend.phoneNumber,
            onTap: _makePhoneCall,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Lyellow.withOpacity(0.2),
                ),
                child: Icon(icon, color: Ldark, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Ldark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    if (widget.friend.socialMediaPlatforms.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.link_off_rounded, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'No Social Media Links',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect social media profiles to share with your network',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.public_rounded, color: Ldark, size: 22),
              const SizedBox(width: 8),
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
          
          const SizedBox(height: 20),
          
          // Social Media Grid
          GridView.builder(
            itemCount: widget.friend.socialMediaPlatforms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              final platform = widget.friend.socialMediaPlatforms.keys.toList()[index];
              final url = widget.friend.socialMediaPlatforms.values.toList()[index].toString();
              
              return _buildSocialMediaCard(platform, url);
            },
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard(String platform, String url) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Platform Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Lyellow.withOpacity(0.2),
                ),
                child: Icon(
                  _getPlatformIcon(platform),
                  color: Ldark,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getPlatformName(platform),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    if (lowerPlatform.contains('facebook')) return 'Facebook';
    if (lowerPlatform.contains('twitter') || lowerPlatform.contains('x')) return 'Twitter';
    if (lowerPlatform.contains('instagram')) return 'Instagram';
    if (lowerPlatform.contains('linkedin')) return 'LinkedIn';
    if (lowerPlatform.contains('whatsapp')) return 'WhatsApp';
    if (lowerPlatform.contains('snapchat')) return 'Snapchat';
    if (lowerPlatform.contains('youtube')) return 'YouTube';
    if (lowerPlatform.contains('tiktok')) return 'TikTok';
    return platform;
  }
}