import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricLock = false;
  bool _dataEncryption = true;
  bool _shareLocationHistory = false;

  @override
  Widget build(BuildContext context) {
    return BaseScreenScaffold(
      title: "Privacy & Security",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel("SECURITY"),
          GlassSectionCard(
            child: Column(
              children: [
                _navRow(
                  Icons.password_outlined,
                  "Change Password",
                  onTap: () {},
                ),
                const Divider(color: Colors.white10, height: 24),
                _toggleRow(
                  Icons.fingerprint_outlined,
                  "Biometric Lock",
                  "Use fingerprint / face unlock to open the app",
                  _biometricLock,
                      (v) => setState(() => _biometricLock = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel("DATA & PRIVACY"),
          GlassSectionCard(
            child: Column(
              children: [
                _toggleRow(
                  Icons.enhanced_encryption_outlined,
                  "End-to-End Data Encryption",
                  "Encrypt report data before it leaves your device",
                  _dataEncryption,
                      (v) => setState(() => _dataEncryption = v),
                ),
                const Divider(color: Colors.white10, height: 24),
                _toggleRow(
                  Icons.share_location_outlined,
                  "Share Location History",
                  "Allow authorities to view your report location trail",
                  _shareLocationHistory,
                      (v) => setState(() => _shareLocationHistory = v),
                ),
                const Divider(color: Colors.white10, height: 24),
                _navRow(
                  Icons.privacy_tip_outlined,
                  "Privacy Policy",
                  onTap: () {},
                ),
                const Divider(color: Colors.white10, height: 24),
                _navRow(
                  Icons.delete_outline,
                  "Delete My Data",
                  color: const Color(0xFFEF4444),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _toggleRow(
      IconData icon,
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 10.5),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFFC72C),
          activeTrackColor: const Color(0xFFFFC72C).withOpacity(0.25),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }

  Widget _navRow(
      IconData icon,
      String title, {
        Color? color,
        required VoidCallback onTap,
      }) {
    final themeColor = color ?? Colors.white70;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: themeColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: themeColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
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