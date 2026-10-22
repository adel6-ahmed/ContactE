import 'package:flutter/material.dart';

import '../../features/agent/agent_screen.dart';
import '../../screens/group_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/my_network_screen.dart';
import '../../screens/profile_screen.dart';

/// Material 3 bottom navigation with labels. Switching tabs replaces the current screen
/// (no animation) instead of pushing a new route each time, so the back stack and memory
/// do not grow while the user moves between tabs.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, this.selectedItemColor});

  /// Kept for existing callers; the colour now comes from the theme.
  final Color? selectedItemColor;

  static int index = 2;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.public_outlined), selectedIcon: Icon(Icons.public), label: 'شبكتي'),
    NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'مجموعاتي'),
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
    NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'برادي'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'ملفي'),
  ];

  static Widget _screenFor(int i) => switch (i) {
        0 => MyNetworkScreen(),
        1 => const GroupScreen(),
        3 => const AgentScreen(),
        4 => const ProfileScreen(),
        _ => const HomeScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: NavigationBar(
        selectedIndex: index,
        destinations: _destinations,
        onDestinationSelected: (value) {
          if (value == index) return;
          index = value;
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (_, __, ___) => _screenFor(value),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
        },
      ),
    );
  }
}
