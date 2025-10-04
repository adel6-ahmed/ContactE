import 'package:flutter/material.dart';
import 'package:sad/services/models.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:lottie/lottie.dart';
import 'package:sad/shared/widgets/contact_card.dart';

class SingleGroupScreen extends StatefulWidget {
  final Group myGroup;

  const SingleGroupScreen({super.key, required this.myGroup});

  @override
  State<SingleGroupScreen> createState() => _SingleGroupScreenState();
}

class _SingleGroupScreenState extends State<SingleGroupScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isEditing = false;

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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _showAddMembers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAddMembersSheet(),
    );
  }

  Widget _buildAddMembersSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                Icon(Icons.person_add_rounded, color: Lyellow, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Add Members',
                  style: h3Bold.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select contacts to add to ${widget.myGroup.name}',
              style: title2.copyWith(color: Colors.white70),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search contacts...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Members List (Placeholder)
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildAddMemberItem('John Doe', 'john.doe@email.com'),
                _buildAddMemberItem('Jane Smith', 'jane.smith@email.com'),
                _buildAddMemberItem('Mike Johnson', 'mike.j@email.com'),
                _buildAddMemberItem('Sarah Wilson', 'sarah.w@email.com'),
                _buildAddMemberItem('Alex Brown', 'alex.b@email.com'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 55,
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
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Members added to ${widget.myGroup.name} ✅'),
                        backgroundColor: Lyellow,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Text(
                      'Add Selected Members',
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
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddMemberItem(String name, String email) {
    bool isSelected = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? Lyellow : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Lyellow.withOpacity(0.2),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(name, style: title1.copyWith(color: Colors.white)),
            subtitle: Text(email, style: caption.copyWith(color: Colors.white70)),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Lyellow : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Lyellow : Colors.white.withOpacity(0.3),
                ),
              ),
              child: isSelected 
                  ? Icon(Icons.check_rounded, size: 16, color: Ldark)
                  : null,
            ),
            onTap: () {
              setState(() {
                isSelected = !isSelected;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ldark,
      appBar: AppBar(
        title: Text(
          widget.myGroup.name,
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
            onPressed: _toggleEditMode,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                _isEditing ? Icons.done_rounded : Icons.edit_rounded,
                color: Lyellow,
                size: 22,
              ),
            ),
          ),
          IconButton(
            onPressed: _showAddMembers,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(Icons.person_add_rounded, color: Lyellow, size: 22),
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
                child: Column(
                  children: [
                    // Group Header Section
                    _buildGroupHeader(),
                    
                    // Members List Section
                    Expanded(
                      child: _buildMembersList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _isEditing 
          ? FloatingActionButton(
              onPressed: _showAddMembers,
              backgroundColor: Lyellow,
              foregroundColor: Ldark,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_add_rounded, size: 28),
            )
          : null,
    );
  }

  Widget _buildGroupHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
          // Group Image
          Stack(
            alignment: Alignment.center,
            children: [
              // Background Decoration
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
              
              // Group Image
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Lyellow, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Lyellow.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    widget.myGroup.img,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(22),
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
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.group_rounded,
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
          
          // Group Name and Info
          Column(
            children: [
              Text(
                widget.myGroup.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Ldark,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.myGroup.members.length} ${widget.myGroup.members.length == 1 ? 'Member' : 'Members'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Group Actions
          if (_isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionChip(Icons.edit_rounded, 'Rename', () {}),
                const SizedBox(width: 12),
                _buildActionChip(Icons.delete_rounded, 'Delete', () {}),
                const SizedBox(width: 12),
                _buildActionChip(Icons.share_rounded, 'Share', () {}),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Lyellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Lyellow.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Ldark),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Ldark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    if (widget.myGroup.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/empty-group.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'No Members Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add members to start building your group',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
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
                  onTap: _showAddMembers,
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Text(
                      'Add First Member',
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.people_alt_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Group Members',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Lyellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.myGroup.members.length.toString(),
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
          
          // Members List
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeInOut,
                  child: ContactCard(
                    userId: widget.myGroup.members[index],
                  ),
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
              itemCount: widget.myGroup.members.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
            ),
          ),
        ],
      ),
    );
  }
}