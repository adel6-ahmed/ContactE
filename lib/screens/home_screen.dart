import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sad/screens/search_results.dart';
import 'package:sad/shared/methods/navigation.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:sad/shared/widgets/action_button.dart';
import 'package:sad/shared/widgets/button_nav_bar.dart';
import 'package:sad/shared/widgets/animated_text_field.dart';
import '../features/agent/agent_screen.dart';
import '../features/card/my_card_screen.dart';
import 'SuggestionScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneNumberController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
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
    _phoneNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Opens Bradi, the social-media agent (the old in-app OpenAI chatbot is gone: the AI now
  /// runs on the agent backend, so no API key ships inside the app).
  void _toggleChatbot() {
    BottomNavBar.index = 3;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const AgentScreen(),
      transitionDuration: Duration.zero,
    ));
  }

  void _openCard() => GoTo(context: context, screen: const MyCardScreen());

  void _searchContact() {
    if (_phoneNumberController.text.trim().isNotEmpty) {
      GoTo(
        context: context,
        screen: SearchResultScreen(phoneNumber: _phoneNumberController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          'ContactE',
          style: TextStyle(
            color: Lyellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ldark,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // الخلفية المتحركة
          _buildAnimatedBackground(),
          
          // المحتوى الرئيسي
          _buildMainContent(),

          // زر برادي العائم
          _buildFloatingChatbotButton(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
      extendBody: true,
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
            // جسيمات متحركة في الخلفية
            Positioned(
              top: 100,
              right: 30,
              child: Opacity(
                opacity: 0.1,
                child: Lottie.asset(
                  'assets/adel6.json',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 30,
              child: Opacity(
                opacity: 0.08,
                child: Lottie.asset(
                  'assets/adel6.json',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            
            // دوائر متدرجة ديكورية
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Lyellow.withOpacity(0.1),
                      Lyellow.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Lyellow.withOpacity(0.08),
                      Lyellow.withOpacity(0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
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
                    const SizedBox(height: 40),
                    
                    // Hero Section
                    _buildHeroSection(),
                    
                    const SizedBox(height: 60),
                    
                    // Search Section
                    _buildSearchSection(),

                    const SizedBox(height: 32),

                    // Quick actions
                    _buildQuickActions(),

                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final actions = [
      (Icons.qr_code_2_rounded, 'بطاقتي الرقمية', 'شارك جهة اتصالك برمز QR', _openCard),
      (Icons.auto_awesome, 'برادي', 'أدر حساباتك على السوشيال', _toggleChatbot),
      if (uid != null)
        (Icons.person_add_alt_1_rounded, 'اقتراحات', 'أشخاص قد تعرفهم',
            () => GoTo(context: context, screen: SuggestionScreen(userId: uid))),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('إجراءات سريعة', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final (icon, title, subtitle, onTap) in actions) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  backgroundColor: Lyellow.withValues(alpha: 0.15),
                  child: Icon(icon, color: Lyellow),
                ),
                title: Text(title, style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text(subtitle),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: onTap,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ]),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // الشعار الرئيسي
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Lyellow.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
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
              padding: const EdgeInsets.all(25.0),
              child: Image.asset(
                'assets/ContactE.png',
                fit: BoxFit.contain,
                color: Ldark,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // النص الترحيبي
          Column(
            children: [
              Text(
                'Welcome to ContactE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your ultimate connection tool\nFind and connect with people easily',
                style: title2.copyWith(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Lyellow.withOpacity(0.15),
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
          // عنوان القسم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                color: Ldark,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Find Contacts',
                style: h2Bold.copyWith(
                  color: Ldark,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Search by phone number to find contacts',
            style: title2.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // حقل البحث
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_iphone_rounded,
                      color: Ldark.withOpacity(0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone Number',
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
                controller: _phoneNumberController,
                label: 'Enter phone number...',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a phone number";
                  }
                  if (value.length < 10) {
                    return "Please enter a valid phone number";
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _searchContact(),
              ),
            ],
          ),
          
          const SizedBox(height: 25),
          
          // زر البحث
          ActionButton(
            title: 'Search Contact',
            action: _searchContact,
          ),
          
          const SizedBox(height: 15),
          
          // نص مساعد
          Text(
            'Enter a valid phone number to search',
            style: caption.copyWith(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChatbotButton() {
    return Positioned(
      bottom: 90,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Lyellow,
          boxShadow: [
            BoxShadow(
              color: Lyellow.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Lyellow,
              const Color(0xFFFFC400),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleChatbot,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(15),
              child: Stack(
                children: [
                  // أيقونة الإبريق
                  Center(
                    child: Image.asset(
                      'assets/teapot.png',
                      width: 35,
                      height: 35,
                      fit: BoxFit.contain,
                      color: Ldark,
                    ),
                  ),
                  
                  // مؤشر النشاط
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
