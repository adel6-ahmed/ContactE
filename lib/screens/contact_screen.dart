import 'package:flutter/material.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class ContactScreen extends StatefulWidget {
  final MyUser contact;

  const ContactScreen({super.key, required this.contact});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> 
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
    
    // Show confirmation snackbar
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
      await launchUrl(Uri.parse('tel:${widget.contact.phoneNumber}'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to make call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareContact() {
    // Share contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share feature coming soon!'),
        backgroundColor: Lyellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper method to get additional info from interests if available
  String? get _country {
    return widget.contact.interests?['country'];
  }

  String? get _age {
    return widget.contact.interests?['age'];
  }

  String? get _occupation {
    return widget.contact.interests?['occupation'];
  }

  String? get _socialMedia {
    return widget.contact.interests?['social_media'];
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
        backgroundColor: Ldark,
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
            onPressed: _shareContact,
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
                    widget.contact.img,
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
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Ldark,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Occupation from interests
              if (_occupation != null && _occupation!.isNotEmpty)
                Text(
                  _occupation!,
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
          
          // Location and Age from interests (if available)
          if (_country != null || _age != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_country != null) ...[
                  Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _country!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_age != null) 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                ],
                if (_age != null) ...[
                  Icon(Icons.cake_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${_age!} years',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
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
                        _isAddedToNetwork ? Icons.check_rounded : Icons.add_rounded,
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
            value: widget.contact.phoneNumber,
            onTap: _makePhoneCall,
          ),
          
          // Additional contact information can be added here in the future
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
    // Check if we have social media in interests or in the main socialMediaPlatforms
    final hasSocialMedia = widget.contact.socialMediaPlatforms.isNotEmpty || 
                          (_socialMedia != null && _socialMedia!.isNotEmpty);

    if (!hasSocialMedia) {
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
              'Connect your social media profiles to share with your network',
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

    // Create a combined list of social media platforms
    final socialMediaList = <Map<String, String>>[];
    
    // Add from main socialMediaPlatforms
    widget.contact.socialMediaPlatforms.forEach((platform, url) {
      socialMediaList.add({'platform': platform, 'url': url});
    });
    
    // Add from interests if available
    if (_socialMedia != null && _socialMedia!.isNotEmpty) {
      socialMediaList.add({'platform': 'Social Media', 'url': _socialMedia!});
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
            itemCount: socialMediaList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              final platform = socialMediaList[index]['platform']!;
              final url = socialMediaList[index]['url']!;
              
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