import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static final List<Map<String, String>> _faqs = [
    {
      "q": "How is my pollution report verified?",
      "a": "Reports are cross-checked using the live camera image, GPS location, and our ML hotspot model before being assigned to a worker.",
    },
    {
      "q": "Why does the app require camera and GPS access?",
      "a": "Camera and GPS are used to authenticate reports and auto-fill accurate addresses, preventing fake or duplicate submissions.",
    },
    {
      "q": "How long does resolution usually take?",
      "a": "Most verified reports are assigned to a worker within 24-48 hours depending on severity and hotspot priority.",
    },
    {
      "q": "How is my Impact Score calculated?",
      "a": "Your score grows with verified reports, resolved complaints, and community engagement on the platform.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreenScaffold(
      title: "Help & Support",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel("CONTACT US"),
          GlassSectionCard(
            child: Column(
              children: [
                _contactRow(
                  Icons.call_outlined,
                  "Helpline",
                  "1800-123-4567",
                  onTap: () {},
                ),
                const Divider(color: Colors.white10, height: 24),
                _contactRow(
                  Icons.email_outlined,
                  "Email Support",
                  "support@airpulse.gov.in",
                  onTap: () {},
                ),
                const Divider(color: Colors.white10, height: 24),
                _contactRow(
                  Icons.chat_bubble_outline,
                  "Live Chat",
                  "Chat with our support team",
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel("FREQUENTLY ASKED QUESTIONS"),
          ..._faqs.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FaqTile(question: item["q"]!, answer: item["a"]!),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _contactRow(
      IconData icon,
      String title,
      String subtitle, {
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC72C).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFFFC72C), size: 18),
          ),
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

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassSectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _expanded,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 14),
          iconColor: const Color(0xFFFFC72C),
          collapsedIconColor: Colors.white38,
          title: Text(
            widget.question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}