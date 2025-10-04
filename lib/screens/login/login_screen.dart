import 'package:flutter/material.dart';
import 'package:sad/screens/crud/create_profile_screen.dart';
import 'package:sad/services/auth_service.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:sad/shared/widgets/animated_action_button.dart';
import 'package:sad/shared/widgets/animated_text_field.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _LoginScreenContent(onLoginSuccess: onLoginSuccess),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const _LoginScreenContent({this.onLoginSuccess});

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> 
    with SingleTickerProviderStateMixin {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late GlobalKey<FormState> formKey;
  late FocusNode passwordNode;
  bool isHidden = true;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    formKey = GlobalKey<FormState>();
    passwordNode = FocusNode();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordNode.dispose();
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Ldark,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // Header Section
                  _buildHeaderSection(),
                  
                  // Login Form Section
                  _buildLoginFormSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Ldark, const Color(0xFF1a1f1e)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // استخدام أيقونة بديلة إذا لم تكن الصورة متوفرة
                Icon(
                  Icons.contacts,
                  size: 120,
                  color: Lyellow,
                ),
                const SizedBox(height: 16),
                Text(
                  'ContactE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Lyellow,
                  ),
                ),
                Text(
                  'Your Ultimate Connection Tool',
                  style: title2.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
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
            const SizedBox(height: 10),
            Text(
              'Welcome Back',
              style: h2Bold.copyWith(color: Ldark),
            ),
            const SizedBox(height: 5),
            Text(
              'Sign in to continue',
              style: title2.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            
            // Email Field
            AnimatedTextField(
              controller: emailController,
              label: 'Email Address',
              icon: Icons.email,
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
            AnimatedTextField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock,
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
            ),
            const SizedBox(height: 15),
            
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to forgot password screen
                },
                child: Text(
                  'Forgot Password?',
                  style: title2.copyWith(color: Lyellow),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Login Button
            AnimatedActionButton(
              title: 'Login',
              onPressed: _login,
              isLoading: isLoading,
            ),
            const SizedBox(height: 25),
            
            // Divider
            _buildDivider(),
            const SizedBox(height: 25),
            
            // Social Login Buttons (بدون صور)
            _buildSocialLoginButtons(),
            const SizedBox(height: 25),
            
            // Sign Up Link
            _buildSignUpLink(),
          ],
        ),
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
            style: title2.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, size: 24),
            label: Text('Google', style: title2.copyWith(color: Ldark)),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.facebook, size: 24),
            label: Text('Facebook', style: title2.copyWith(color: Ldark)),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: title2.copyWith(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateProfileScreen(userId: 'new_user'),
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: title2Bold.copyWith(color: Lyellow),
          ),
        ),
      ],
    );
  }

  void _login() async {
    if (formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });
      
      await Auth().userLogin(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );
      
      setState(() {
        isLoading = false;
      });
      
      widget.onLoginSuccess?.call();
    }
  }
}