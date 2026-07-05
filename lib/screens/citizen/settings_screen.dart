import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _locationAccess = true;
  bool _autoSyncReports = true;
  String _language = "English";

  @override
  Widget build(BuildContext context) {
    return BaseScreenScaffold(
      title: "Settings",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel("APP PREFERENCES"),
          GlassSectionCard(
            child: Column(
              children: [
                _switchRow(
                  Icons.dark_mode_outlined,
                  "Dark Theme",
                  "Premium black & yellow interface",
                  _darkMode,
                      (v) => setState(() => _darkMode = v),
                ),
                const Divider(color: Colors.white10, height: 24),
                _switchRow(
                  Icons.my_location_outlined,
                  "Location Access",
                  "Required for GPS-tagged reports",
                  _locationAccess,
                      (v) => setState(() => _locationAccess = v),
                ),
                const Divider(color: Colors.white10, height: 24),
                _switchRow(
                  Icons.sync_outlined,
                  "Auto-Sync Reports",
                  "Sync reports when back online",
                  _autoSyncReports,
                      (v) => setState(() => _autoSyncReports = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionLabel("GENERAL"),
          GlassSectionCard(
            child: Column(
              children: [
                _navRow(
                  Icons.language_outlined,
                  "Language",
                  trailingText: _language,
                  onTap: () => _showLanguagePicker(context),
                ),
                const Divider(color: Colors.white10, height: 24),
                _navRow(
                  Icons.info_outline,
                  "About AirPulse AI",
                  trailingText: "v1.0.0",
                  onTap: () {},
                ),
                const Divider(color: Colors.white10, height: 24),
                _navRow(
                  Icons.description_outlined,
                  "Terms & Conditions",
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

  Widget _switchRow(
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
        String? trailingText,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: Colors.white38, fontSize: 11.5),
            ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white12,
            size: 12,
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1D22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final options = ["English", "Hindi", "Marathi"];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map(
                    (lang) => ListTile(
                  title: Text(
                    lang,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: _language == lang
                      ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFFC72C),
                  )
                      : null,
                  onTap: () {
                    setState(() => _language = lang);
                    Navigator.pop(context);
                  },
                ),
              )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}