import 'package:flutter/material.dart';
import 'package:sad/shared/widgets/GroupItem.dart';
import 'package:sad/shared/widgets/loader.dart';
import 'package:lottie/lottie.dart';

import '../services/firestore_functions.dart';
import '../shared/theme/colors.dart';
import '../shared/widgets/back_button.dart';
import '../shared/widgets/button_nav_bar.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> 
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

  Future<void> _refreshGroups() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isRefreshing = false;
    });
  }

  void _createNewGroup() {
    // Navigate to create group screen
    showDialog(
      context: context,
      builder: (context) => _buildCreateGroupDialog(),
    );
  }

  Widget _buildCreateGroupDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Lyellow.withOpacity(0.2),
              ),
              child: Icon(Icons.group_add_rounded, size: 40, color: Ldark),
            ),
            const SizedBox(height: 20),
            Text(
              'Create New Group',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Ldark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This feature is coming soon!',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Implement create group logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Lyellow,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Lyellow.withOpacity(0.5),
                    ),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: Ldark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FireBaseServices().getGroups(id: '2j8M93CHwcvgL4KfAFaq'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        }
        
        if (snapshot.hasData) {
          var groups = snapshot.data;
          
          if (groups!.isEmpty) {
            return _buildEmptyState();
          }
          
          return _buildGroupsGrid(groups);
        } else {
          return _buildEmptyState();
        }
      },
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
              'Loading Groups...',
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
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshGroups,
        backgroundColor: Ldark,
        color: Lyellow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
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
                      'We couldn\'t load your groups. Please check your connection and try again.',
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
                    onPressed: _refreshGroups,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Lyellow,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: Icon(Icons.refresh_rounded, color: Ldark),
                    label: Text(
                      'Try Again',
                      style: TextStyle(
                        color: Ldark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshGroups,
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
                              width: 200,
                              height: 200,
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
                                'assets/animations/empty-groups.json',
                                width: 180,
                                height: 180,
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Title
                            Text(
                              'No Groups Yet',
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
                                'Create your first group to organize your contacts and collaborate efficiently',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Create Group Button
                            ElevatedButton.icon(
                              onPressed: _createNewGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Lyellow,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 8,
                                shadowColor: Lyellow.withOpacity(0.4),
                              ),
                              icon: Icon(Icons.add_rounded, color: Ldark, size: 20),
                              label: Text(
                                'Create Your First Group',
                                style: TextStyle(
                                  color: Ldark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildGroupsGrid(List groups) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: _buildAppBar(),
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
                  onRefresh: _refreshGroups,
                  backgroundColor: Ldark,
                  color: Lyellow,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header Stats
                        _buildHeaderStats(groups.length),
                        const SizedBox(height: 20),
                        
                        // Groups Grid
                        Expanded(
                          child: GridView.builder(
                            itemCount: groups.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return GroupItem(myGroup: groups[index]);
                            },
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
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: const BottomNavBar(),
      extendBody: true,
    );
  }

  Widget _buildHeaderStats(int groupCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
          // Groups Count
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lyellow.withOpacity(0.2),
            ),
            child: Icon(Icons.group_rounded, color: Ldark, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Groups',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$groupCount ${groupCount == 1 ? 'Group' : 'Groups'}',
                  style: TextStyle(
                    color: Ldark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Ldark.withOpacity(0.05),
            ),
            child: Icon(Icons.more_vert_rounded, color: Ldark, size: 20),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'My Groups',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
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
          onPressed: _refreshGroups,
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
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _createNewGroup,
      backgroundColor: Lyellow,
      foregroundColor: Ldark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Lyellow,
              const Color(0xFFFFC400),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Lyellow.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}