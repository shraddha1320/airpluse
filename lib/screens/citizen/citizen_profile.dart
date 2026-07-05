import 'package:flutter/material.dart';
import 'airi_assistant.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_setting_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';
import 'page_transition.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Achievements list mock details
  final List<Map<String, String>> _achievements = [
    {"title": "Eco Sentinel", "icon": "🛡", "desc": "First validated report"},
    {"title": "Clean Air Hero", "icon": "🍃", "desc": "Saved 5 trees index"},
    {"title": "Haze Buster", "icon": "☀️", "desc": "Resolved 3 hotspots"},
  ];

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _openSettings() {
    Navigator.of(context).push(createSmoothRoute(const SettingsScreen()));
  }

  void _openEditProfile() {
    Navigator.of(context).push(createSmoothRoute(const EditProfileScreen()));
  }

  void _openNotificationSettings() {
    Navigator.of(
      context,
    ).push(createSmoothRoute(const NotificationSettingsScreen()));
  }

  void _openPrivacySecurity() {
    Navigator.of(
      context,
    ).push(createSmoothRoute(const PrivacySecurityScreen()));
  }

  void _openHelpSupport() {
    Navigator.of(context).push(createSmoothRoute(const HelpSupportScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Duty Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white54,
                ),
                onPressed: _openSettings,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Profile Card details
          _buildUserProfileCard(),
          const SizedBox(height: 24),
          // Environmental Impact scoreboard
          const Text(
            "ENVIRONMENTAL IMPACT",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildImpactMetricsGrid(),
          const SizedBox(height: 24),
          // Achievements horizontal list
          const Text(
            "COMPLETED ACHIEVEMENTS",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildAchievementsList(),
          const SizedBox(height: 24),
          // Option actions list
          const Text(
            "ACCOUNT CONTROLS",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildOptionsActionsList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Circular Avatar (Airi expression happy)
          SizedBox(
            width: 60,
            height: 60,
            child: ClipOval(
              child: CustomPaint(
                painter: AiriCharacterPainter(expression: 'happy'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Details (XP / Level removed)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Shraddha",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "📍 Mumbai, Maharashtra",
                  style: TextStyle(color: Colors.white54, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _impactStatCard("Complaints", "12 Reports", const Color(0xFF38BDF8)),
        _impactStatCard("Verified", "10 Claims", const Color(0xFFFFC72C)),
        _impactStatCard("Impact Score", "840 XP", const Color(0xFF34D399)),
        _impactStatCard("Trees Saved", "3.2 Trees", const Color(0xFF34D399)),
      ],
    );
  }

  Widget _impactStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    return SizedBox(
      height: 74,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final a = _achievements[index];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1D22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Row(
              children: [
                Text(a["icon"]!, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      a["title"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a["desc"]!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionsActionsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _optionRow(
            Icons.edit_outlined,
            "Edit Profile Details",
            _openEditProfile,
          ),
          const Divider(color: Colors.white10, height: 20),
          _optionRow(
            Icons.notifications_active_outlined,
            "Notification Settings",
            _openNotificationSettings,
          ),
          const Divider(color: Colors.white10, height: 20),
          _optionRow(
            Icons.lock_outline,
            "Privacy & Data Encryption",
            _openPrivacySecurity,
          ),
          const Divider(color: Colors.white10, height: 20),
          _optionRow(
            Icons.help_outline,
            "Help Desk Support Center",
            _openHelpSupport,
          ),
          const Divider(color: Colors.white10, height: 20),
          _optionRow(
            Icons.logout,
            "Logout Session",
            _handleLogout,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _optionRow(
      IconData icon,
      String title,
      VoidCallback onTap, {
        Color? color,
      }) {
    final themeColor = color ?? Colors.white70;
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: themeColor, size: 18),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: themeColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white12,
            size: 12,
          ),
        ],
      ),
    );
  }
}