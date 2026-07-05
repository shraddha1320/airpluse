import 'dart:async';
import 'package:flutter/material.dart';
import 'citizen_home_screen.dart';
import 'citizen_live_map.dart';
import 'citizen_profile.dart';
import 'report_issue_screen.dart';
class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});
  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}
class _CitizenDashboardState extends State<CitizenDashboard> {
  // Navigation active tab index (mapped to home, map, profile inside IndexedStack)
  int _activeStackIndex = 0;
  void _navigateToReport(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const ReportIssueScreen(isGuest: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      body: Stack(
        children: [
          // 1. Core Tab Page Stack (preserving state)
          Positioned.fill(
            child: SafeArea(
              child: IndexedStack(
                index: _activeStackIndex,
                children: [
                  HomeScreen(
                    onOpenMap: () {
                      setState(() {
                        _activeStackIndex = 1; // Switches to map tab
                      });
                    },
                  ),
                  const LiveMapScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ),
          // 2. Floating bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFloatingBottomNavBar(context),
          ),
        ],
      ),
    );
  }
  Widget _buildFloatingBottomNavBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 18.0),
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home Tab Item
          _buildNavItem(
            icon: Icons.home_filled,
            isActive: _activeStackIndex == 0,
            onTap: () => setState(() => _activeStackIndex = 0),
          ),
          // 2. Live Map Tab Item
          _buildNavItem(
            icon: Icons.map_outlined,
            isActive: _activeStackIndex == 1,
            onTap: () => setState(() => _activeStackIndex = 1),
          ),
          // 3. Central Standout Report Action (navigates to Report screen)
          GestureDetector(
            onTap: () => _navigateToReport(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC72C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFFC72C),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.photo_camera,
                color: Color(0xFF111315),
                size: 20,
              ),
            ),
          ),
          // 4. Profile Tab Item
          _buildNavItem(
            icon: Icons.person_outline,
            isActive: _activeStackIndex == 2,
            onTap: () => setState(() => _activeStackIndex = 2),
          ),
        ],
      ),
    );
  }
  Widget _buildNavItem({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.02) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFFFFC72C) : Colors.white30,
          size: 24,
        ),
      ),
    );
  }
}
