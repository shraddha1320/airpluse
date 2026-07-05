import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _reportUpdates = true;
  bool _hotspotAlerts = true;
  bool _emailDigest = false;
  bool _smsAlerts = false;

  @override
  Widget build(BuildContext context) {
    return BaseScreenScaffold(
      title: "Notification Settings",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel("PUSH NOTIFICATIONS"),
          GlassSectionCard(
            child: Column(
              children: [
                _toggle(
                  "Enable Push Notifications",
                  "Master switch for all push alerts",
                  _pushEnabled,
                      (v) => setState(() => _pushEnabled = v),
                ),
                const Divider(color: Colors.white10, height: 24),
                _toggle(
                  "Report Status Updates",
                  "Get notified when your report status changes",
                  _reportUpdates,
                      (v) => setState(() => _reportUpdates = v),
                ),
                const Divider(color: Colors.white10, height: 24),
                _toggle(
                  "Pollution Hotspot Alerts",
                  "Alerts when a hotspot is predicted nearby",
                  _hotspotAlerts,
                      (v) => setState(() => _hotspotAlerts = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel("OTHER CHANNELS"),
          GlassSectionCard(
            child: Column(
              children: [
                _toggle(
                  "Weekly Email Digest",
                  "Summary of impact score and activity",
                  _emailDigest,
                      (v) => setState(() => _emailDigest = v),
                ),
                const Divider(color: Colors.white10, height: 24),
                _toggle(
                  "SMS Alerts",
                  "Critical alerts sent via SMS",
                  _smsAlerts,
                      (v) => setState(() => _smsAlerts = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _toggle(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Row(
      children: [
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
}