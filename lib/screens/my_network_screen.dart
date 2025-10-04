import 'package:flutter/material.dart';
import 'package:sad/shared/widgets/loader.dart';
import 'package:lottie/lottie.dart';

import '../services/firestore_functions.dart';
import '../shared/theme/colors.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';
import '../shared/widgets/contact_card.dart';

class MyNetworkScreen extends StatefulWidget {
  const MyNetworkScreen({super.key});

  @override
  State<MyNetworkScreen> createState() => _MyNetworkScreenState();
}

class _MyNetworkScreenState extends State<MyNetworkScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshNetwork() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FireBaseServices().getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        } else if (snapshot.hasError) {
          return _buildErrorScreen('Error loading user data');
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder(
            future: FireBaseServices().getNetwork(id: user.uid),
            builder: (context, networkSnapshot) {
              if (networkSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              } else if (networkSnapshot.hasError) {
                return _buildErrorScreen('Error loading network contacts');
              } else if (networkSnapshot.hasData) {
                final myNetworkObj = networkSnapshot.data!;
                final myNetworkList = myNetworkObj.myNetwork;
                
                if (myNetworkList.isEmpty) {
                  return _buildEmptyNetworkScreen();
                }
                
                return _buildNetworkScreen(myNetworkList);
              } else {
                return _buildEmptyNetworkScreen();
              }
            },
          );
        } else {
          return _buildEmptyNetworkScreen();
        }
      },
    );
  }

  Widget _buildNetworkScreen(List<dynamic> networkList) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          'My Network',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
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
            onPressed: _refreshNetwork,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                _isRefreshing ? Icons.refresh_rounded : Icons.refresh_outlined,
                color: Lyellow,
                size: 22,
              ),
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
                child: RefreshIndicator(
                  onRefresh: _refreshNetwork,
                  backgroundColor: Ldark,
                  color: Lyellow,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Network Header with Stats
                        _buildNetworkHeader(networkList.length),
                        
                        const SizedBox(height: 25),
                        
                        // Search Bar
                        _buildSearchBar(),
                        
                        const SizedBox(height: 25),
                        
                        // Contacts List Title
                        _buildSectionTitle('Network Contacts'),
                        
                        const SizedBox(height: 20),
                        
                        // Contacts List
                        Expanded(
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                curve: Curves.easeInOut,
                                child: ContactCard(userId: networkList[index]),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1),
                                  indent: 60,
                                  endIndent: 20,
                                ),
                              );
                            },
                            itemCount: networkList.length,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
      extendBody: true,
    );
  }

  Widget _buildNetworkHeader(int contactCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Lyellow.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFfafafa),
          ],
        ),
      ),
      child: Row(
        children: [
          // Network Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Ldark,
              boxShadow: [
                BoxShadow(
                  color: Ldark.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: Lyellow,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Network Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Network',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Ldark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$contactCount ${contactCount == 1 ? 'Contact' : 'Contacts'}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Ldark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your professional network',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Growth Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Lyellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Lyellow.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Ldark,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: TextStyle(
                    color: Ldark,
                    fontSize: 12,
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

  Widget _buildSearchBar() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.grey.shade500,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: Ldark,
                fontSize: 16,
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lyellow.withOpacity(0.2),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: Ldark,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyNetworkScreen() {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          'My Network',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
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
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNetwork,
        backgroundColor: Ldark,
        color: Lyellow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Illustration
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Lyellow.withOpacity(0.2),
                                    Lyellow.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Lottie.asset(
                                'assets/animations/empty-network.json',
                                width: 200,
                                height: 200,
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Title
                            Text(
                              'No Contacts Yet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Description
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Start building your professional network by adding contacts and connecting with people',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildActionButton(
                                  title: 'Add Contact',
                                  icon: Icons.person_add_rounded,
                                  onPressed: () {
                                    // Navigate to add contact
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildActionButton(
                                  title: 'Invite Friends',
                                  icon: Icons.share_rounded,
                                  onPressed: () {
                                    // Share invite link
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Lyellow,
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Ldark, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Ldark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Ldark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/loading.json',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Network...',
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red.shade300,
              ),
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
                'We couldn\'t load your network. Please check your connection and try again.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _refreshNetwork,
              style: ElevatedButton.styleFrom(
                backgroundColor: Lyellow,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: Icon(Icons.refresh_rounded, color: Ldark),
              label: Text(
                'Try Again',
                style: TextStyle(color: Ldark, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}