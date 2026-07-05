import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<_NotificationItem> _items = [
    _NotificationItem(
      icon: Icons.verified_outlined,
      color: const Color(0xFF34D399),
      title: "Report Verified",
      subtitle: "Your complaint near Andheri East was verified by an admin.",
      time: "2h ago",
    ),
    _NotificationItem(
      icon: Icons.engineering_outlined,
      color: const Color(0xFFFFC72C),
      title: "Worker Assigned",
      subtitle: "A field worker has been assigned to your pollution report.",
      time: "5h ago",
    ),
    _NotificationItem(
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFEF4444),
      title: "Hotspot Alert",
      subtitle: "A new pollution hotspot was predicted near your saved area.",
      time: "1d ago",
    ),
    _NotificationItem(
      icon: Icons.task_alt_outlined,
      color: const Color(0xFF38BDF8),
      title: "Complaint Resolved",
      subtitle: "Your reported issue has been marked resolved. Rate the fix.",
      time: "2d ago",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreenScaffold(
      title: "Notifications",
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text(
            "Clear all",
            style: TextStyle(
              color: Color(0xFFFFC72C),
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel("RECENT"),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _items[index];
              return GlassSectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                item.time,
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}