import 'package:flutter/material.dart';
import 'package:sad/screens/login/login_screen.dart';
import 'package:sad/services/auth_service.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:sad/shared/widgets/action_button.dart';
import 'package:sad/shared/widgets/animated_action_button.dart';
import 'package:sad/shared/widgets/animated_text_field.dart';

class SignupScreen extends StatelessWidget {
  final String name;
  final String phoneNumber;

  const SignupScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return _SignupScreenContent(
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}

class _SignupScreenContent extends StatefulWidget {
  final String name;
  final String phoneNumber;

  const _SignupScreenContent({
    required this.name,
    required this.phoneNumber,
  });

  @override
  State<_SignupScreenContent> createState() => _SignupScreenContentState();
}

class _SignupScreenContentState extends State<_SignupScreenContent> 
    with SingleTickerProviderStateMixin {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late GlobalKey<FormState> formKey;
  late FocusNode passwordNode;
  late FocusNode confirmPasswordNode;
  bool isHidden = true;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    formKey = GlobalKey<FormState>();
    passwordNode = FocusNode();
    confirmPasswordNode = FocusNode();
    
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
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void toggleVisibility() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Ldark,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header with Back Button
                      _buildHeaderSection(),
                      
                      // Form Section
                      _buildFormSection(),
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

  Widget _buildHeaderSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Ldark, const Color(0xFF1a1f1e)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Background Circle
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
                    Lyellow.withOpacity(0.3),
                    Lyellow.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            left: 20,
            top: 20,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Icon(Icons.arrow_back, size: 24, color: Lyellow),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Content
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
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      'assets/CA.png',
                      fit: BoxFit.contain,
                      color: Ldark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Lyellow,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your account credentials',
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
                    
                    // Information Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Ldark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Lyellow.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Ldark.withOpacity(0.7), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Info',
                                  style: TextStyle(
                                    color: Ldark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${widget.name} • ${widget.phoneNumber}',
                                  style: TextStyle(
                                    color: Ldark.withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Email Field
                    _buildAnimatedInputField(
                      controller: emailController,
                      label: 'Email Address',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email can't be empty";
                        }
                        if (!value.contains('@')) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passwordNode);
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    _buildAnimatedInputField(
                      controller: passwordController,
                      label: 'Password',
                      icon: Icons.lock_rounded,
                      isPassword: true,
                      isHidden: isHidden,
                      focusNode: passwordNode,
                      onToggleVisibility: toggleVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password can't be empty";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(confirmPasswordNode);
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Confirm Password Field
                    _buildAnimatedInputField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      isHidden: isHidden,
                      focusNode: confirmPasswordNode,
                      onToggleVisibility: toggleVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        }
                        if (value != passwordController.text) {
                          return "Passwords don't match";
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Sign Up Button
                    AnimatedActionButton(
                      title: 'Create Account',
                      onPressed: _createAccount,
                      isLoading: isLoading,
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Divider
                    _buildDivider(),
                    const SizedBox(height: 25),
                    
                    // Social Sign Up Buttons
                    _buildSocialSignUpButtons(),
                    const SizedBox(height: 25),
                    
                    // Login Link
                    _buildLoginLink(),
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
    bool isPassword = false,
    bool isHidden = true,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    Function(String)? onFieldSubmitted,
    VoidCallback? onToggleVisibility,
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
            isPassword: isPassword,
            isHidden: isHidden,
            focusNode: focusNode,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            onToggleVisibility: onToggleVisibility,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.grey[400]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: title2.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildSocialSignUpButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.g_mobiledata, size: 24, color: Ldark),
            label: Text('Google', style: title2.copyWith(color: Ldark)),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.facebook, size: 24, color: Ldark),
            label: Text('Facebook', style: title2.copyWith(color: Ldark)),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: title2.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: Text(
            'Sign In',
            style: title2Bold.copyWith(
              color: Lyellow,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _createAccount() async {
    if (formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });
      
      await Auth().createUserByEmail(
        email: emailController.text,
        password: passwordController.text,
        context: context,
        name: widget.name,
        phoneNumber: widget.phoneNumber,
      );
      
      setState(() {
        isLoading = false;
      });
    }
  }
}