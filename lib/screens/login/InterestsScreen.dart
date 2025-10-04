import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sad/screens/home_screen.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:sad/shared/widgets/action_button.dart';
import 'package:sad/shared/widgets/animated_text_field.dart';

class InterestsScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;

  const InterestsScreen({super.key, required this.name, required this.phoneNumber});

  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> with SingleTickerProviderStateMixin {
  late TextEditingController countryController;
  late TextEditingController ageController;
  late TextEditingController socialMediaController;
  late TextEditingController occupationController;
  late GlobalKey<FormState> formKey;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    countryController = TextEditingController();
    ageController = TextEditingController();
    socialMediaController = TextEditingController();
    occupationController = TextEditingController();
    formKey = GlobalKey<FormState>();
    
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
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    countryController.dispose();
    ageController.dispose();
    socialMediaController.dispose();
    occupationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void submitInterests() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Update existing user document instead of creating new one
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
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
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (error) {
        print("Failed to add interests: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving interests: $error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    
                    // Form Section
                    _buildFormSection(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Lyellow.withOpacity(0.9),
                    Ldark,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative Circles
                  Positioned(
                    top: 40,
                    left: MediaQuery.of(context).size.width / 2 - 60,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.1, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Lyellow.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_people_rounded,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tell Us About You',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help us personalize your experience',
                          style: title2.copyWith(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
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
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Ldark,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Your Interests',
                          style: h2Bold.copyWith(
                            color: Ldark,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Complete your profile to get better suggestions',
                      style: title2.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Country Field
                    _buildAnimatedInputField(
                      controller: countryController,
                      label: 'Country',
                      icon: Icons.location_on_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your country';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Age Field
                    _buildAnimatedInputField(
                      controller: ageController,
                      label: 'Age',
                      icon: Icons.cake_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Social Media Field
                    _buildAnimatedInputField(
                      controller: socialMediaController,
                      label: 'Favorite Social Media',
                      icon: Icons.thumb_up_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your favorite social media';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Occupation Field
                    _buildAnimatedInputField(
                      controller: occupationController,
                      label: 'Occupation',
                      icon: Icons.work_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your occupation';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Submit Button
                    _buildSubmitButton(),
                    
                    const SizedBox(height: 15),
                    
                    // Helper Text
                    Text(
                      'This helps us suggest relevant connections',
                      style: caption.copyWith(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Ldark.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Ldark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        AnimatedTextField(
          controller: controller,
          label: 'Enter your $label...',
          icon: icon,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
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
            title: 'Complete Profile',
            action: submitInterests,
          );
  }
}