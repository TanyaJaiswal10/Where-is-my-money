import 'package:flutter/material.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../chat/screens/chat_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/side_navigation_rail.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback? onLoggedOut;

  const MainNavigationScreen({
    super.key,
    this.onLoggedOut,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ChatScreen(),
      InsightsScreen(
        onSwitchToChat: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      ProfileScreen(
        onLoggedOut: () {
          if (widget.onLoggedOut != null) {
            widget.onLoggedOut!();
          }
        },
      ),
    ];

    final displayedIndex = _selectedIndex < screens.length ? _selectedIndex : 0;

    return ResponsiveLayout(
      mobile: Scaffold(
        body: IndexedStack(
          index: displayedIndex,
          children: screens,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: displayedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      desktop: Scaffold(
        body: Row(
          children: [
            SideNavigationRail(
              selectedIndex: displayedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: IndexedStack(
                    index: displayedIndex,
                    children: screens,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
