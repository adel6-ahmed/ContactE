import 'package:flutter/material.dart';
import 'package:sad/services/firestore_functions.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:lottie/lottie.dart';
import 'package:sad/shared/widgets/button_nav_bar.dart';

class SuggestionScreen extends StatefulWidget {
  final String userId;

  const SuggestionScreen({super.key, required this.userId});

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isLoading = false;
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
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshSuggestions() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isRefreshing = false;
    });
  }

  void _addToNetwork(MyUser friend) {
    // تنفيذ إضافة الصديق للشبكة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${friend.name} to your network! ✅',
          style: TextStyle(color: Ldark, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Lyellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          'Friend Suggestions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
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
            onPressed: _refreshSuggestions,
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
      body: FutureBuilder<List<MyUser>>(
        future: FireBaseServices().getSuggestedFriends(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          } else if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            final suggestedFriends = snapshot.data!;
            return _buildSuggestionsList(suggestedFriends);
          }
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
      extendBody: true,
    );
  }

  Widget _buildSuggestionsList(List<MyUser> friends) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: RefreshIndicator(
              onRefresh: _refreshSuggestions,
              backgroundColor: Ldark,
              color: Lyellow,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderCard(friends.length),
                    
                    const SizedBox(height: 25),
                    
                    // Suggestions Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Icon(Icons.people_alt_rounded, 
                            color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Suggested Friends',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Lyellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              friends.length.toString(),
                              style: TextStyle(
                                color: Ldark,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Suggestions List
                    Expanded(
                      child: ListView.separated(
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            curve: Curves.easeInOut,
                            child: _buildSuggestionCard(friends[index], index),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
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
        );
      },
    );
  }

  Widget _buildHeaderCard(int count) {
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
          // Icon
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
              Icons.auto_awesome_rounded,
              color: Lyellow,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Suggestions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Ldark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count people you might know',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your interests and network',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(MyUser friend, int index) {
    final commonInterests = _getCommonInterestsCount(friend);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to contact screen
            // GoTo(context: context, screen: ContactScreen(contact: friend));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with Rank Badge
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Lyellow.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          friend.img,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.grey, Colors.grey],
                                ),
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
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Lyellow, Color(0xFFFFC400)],
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Rank Badge
                    if (index < 3)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getRankColor(index),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: TextStyle(
                          color: Ldark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        friend.phoneNumber,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Common Interests
                      if (commonInterests > 0)
                        Row(
                          children: [
                            Icon(Icons.star_rounded, 
                              color: Lyellow, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$commonInterests common interests',
                              style: TextStyle(
                                color: Lyellow,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      
                      // Interests Preview
                      if (friend.interests.isNotEmpty)
                        const SizedBox(height: 4),
                        _buildInterestsPreview(friend),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Add Button
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Lyellow,
                    boxShadow: [
                      BoxShadow(
                        color: Lyellow.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _addToNetwork(friend),
                      borderRadius: BorderRadius.circular(20),
                      child: Icon(
                        Icons.person_add_rounded,
                        color: Ldark,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsPreview(MyUser friend) {
    final interests = friend.interests.entries
        .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
        .take(2)
        .toList();

    if (interests.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: interests.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Lyellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Lyellow.withOpacity(0.2)),
          ),
          child: Text(
            entry.value.toString(),
            style: TextStyle(
              color: Ldark,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  int _getCommonInterestsCount(MyUser friend) {
    // هذه دالة افتراضية - يمكن استبدالها بالمنطق الحقيقي
    return friend.interests.length > 3 ? 3 : friend.interests.length;
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0: return Colors.amber;
      case 1: return Colors.grey;
      case 2: return Colors.orange;
      default: return Colors.transparent;
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
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
            'Finding Suggestions...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your interests and network',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
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
            'Unable to Load Suggestions',
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
              'We encountered an issue while loading friend suggestions. Please check your connection and try again.',
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
                onTap: () => setState(() {}),
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: Ldark,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty-suggestions.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            'No Suggestions Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'We\'ll suggest friends based on your interests and network activity. Check back later for new suggestions!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                onTap: _refreshSuggestions,
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Text(
                    'Refresh Suggestions',
                    style: TextStyle(
                      color: Ldark,
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
    );
  }
}