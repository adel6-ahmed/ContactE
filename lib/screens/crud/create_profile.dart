import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sad/screens/login/signup_screen.dart';
import 'package:sad/shared/methods/navigation.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:sad/shared/widgets/action_button.dart';
import 'package:sad/shared/widgets/animated_text_field.dart';

class CreateProfileScreen extends StatelessWidget {
  final String userId;
  const CreateProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _CreateProfileContent(userId: userId);
  }
}

class _CreateProfileContent extends StatefulWidget {
  final String userId;
  const _CreateProfileContent({required this.userId});

  @override
  State<_CreateProfileContent> createState() => _CreateProfileContentState();
}

class _CreateProfileContentState extends State<_CreateProfileContent> 
    with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late GlobalKey<FormState> formKey;
  late FocusNode phoneNumberNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneNumberController = TextEditingController();
    formKey = GlobalKey<FormState>();
    phoneNumberNode = FocusNode();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    nameController.dispose();
    phoneNumberController.dispose();
    phoneNumberNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Ldark,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeaderSection(),
                      _buildFormSection(),
                      // مساحة إضافية في الأسفل لمنع القص
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Ldark,
              const Color(0xFF1a1f1e),
              const Color(0xFF0f1211),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 100,
              right: 50,
              child: Opacity(
                opacity: 0.1,
                child: Lottie.asset(
                  'assets/animations/particles.json',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 30,
              child: Opacity(
                opacity: 0.05,
                child: Lottie.asset(
                  'assets/animations/waves.json',
                  width: 150,
                  height: 150,
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
              height: 280, // تقليل الارتفاع قليلاً
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Ldark.withOpacity(0.9),
                    const Color(0xFF1a1f1e).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 60,
                    left: MediaQuery.of(context).size.width / 2 - 80,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Lyellow.withOpacity(0.3),
                            Lyellow.withOpacity(0.1),
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
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Lyellow.withOpacity(0.5),
                                  blurRadius: 25,
                                  spreadRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Lyellow.withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Image.asset(
                                'assets/ContactE.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                                color: Ldark,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 1000),
                          opacity: _animationController.value > 0.5 ? 1.0 : 0.0,
                          child: Text(
                            'Create Your Profile',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
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
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24), // تقليل ال padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
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
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Ldark,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Basic Information',
                            style: h2Bold.copyWith(
                              color: Ldark,
                              fontSize: 22, // تصغير الخط قليلاً
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Tell us about yourself to get started',
                        style: title2.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 30), // تقليل المسافة
                      
                      _buildAnimatedInputField(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your name";
                          }
                          if (value.length < 2) {
                            return "Name must be at least 2 characters";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(phoneNumberNode);
                        },
                      ),
                      
                      const SizedBox(height: 20), // تقليل المسافة
                      
                      _buildAnimatedInputField(
                        controller: phoneNumberController,
                        label: 'Phone Number',
                        icon: Icons.phone_iphone_rounded,
                        keyboardType: TextInputType.phone,
                        focusNode: phoneNumberNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          }
                          if (value.length < 10) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 30), // تقليل المسافة
                      
                      _buildContinueButton(),
                      
                      const SizedBox(height: 20),
                      
                      _buildProgressIndicator(),
                    ],
                  ),
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
    FocusNode? focusNode,
    String? Function(String?)? validator,
    Function(String)? onFieldSubmitted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Column(
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
            label: '',
            icon: icon,
            keyboardType: keyboardType,
            focusNode: focusNode,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ActionButton(
      title: 'Continue to Sign Up',
      action: _continueToSignUp,
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Lyellow,
            boxShadow: [
              BoxShadow(
                color: Lyellow.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        Container(
          width: 30,
          height: 2,
          color: Colors.grey[300],
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[400],
          ),
        ),
        Container(
          width: 30,
          height: 2,
          color: Colors.grey[300],
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  void _continueToSignUp() {
    if (formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      _animationController.forward().then((_) {
        _animationController.reverse().then((_) {
          GoTo(
            context: context,
            screen: SignupScreen(
              name: nameController.text,
              phoneNumber: phoneNumberController.text,
            ),
          );
        });
      });
    }
  }
}