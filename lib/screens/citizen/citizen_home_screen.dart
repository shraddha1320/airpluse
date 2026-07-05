import 'notification_screen.dart';
import 'page_transition.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'airi_assistant.dart';
class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenMap;
  const HomeScreen({
    super.key,
    required this.onOpenMap,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  // Mock list of recent reports
  final List<Map<String, dynamic>> _myReports = [
    {
      "id": "AP-2026-00482",
      "type": "Garbage Burning",
      "location": "Bandra West, Carter Road",
      "time": "15 mins ago",
      "status": "Under Review",
      "color": Color(0xFFFFC72C)
    },
    {
      "id": "AP-2026-00451",
      "type": "Industrial Smoke",
      "location": "Thane East, Sector 3",
      "time": "2 days ago",
      "status": "Resolved",
      "color": Color(0xFF34D399)
    },
    {
      "id": "AP-2026-00412",
      "type": "Construction Dust",
      "location": "Kurla West, Link Road",
      "time": "1 week ago",
      "status": "Pending",
      "color": Color(0xFF38BDF8)
    },
  ];
  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }
  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: FadeTransition(
        opacity: _entranceController,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
            CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              _buildGreetingHeader(),
              const SizedBox(height: 20),
              // Status Summary counters
              _buildStatusSummarySection(),
              const SizedBox(height: 24),
              // Hotspot Card
              _buildHotspotMapCard(size),
              const SizedBox(height: 24),
              // AI Health Insights
              _buildAiInsightsCard(),
              const SizedBox(height: 24),
              // My Reports list section
              _buildMyReportsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGreetingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Afternoon",
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Shraddha 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1D22),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                createSmoothRoute(
                  const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFFFFC72C),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildStatusSummarySection() {
    return Row(
      children: [
        Expanded(child: _statCard("Total Reports", "12", const Color(0xFF38BDF8))),
        const SizedBox(width: 10),
        Expanded(child: _statCard("Pending", "3", const Color(0xFFFFC72C))),
        const SizedBox(width: 10),
        Expanded(child: _statCard("Resolved", "9", const Color(0xFF34D399))),
      ],
    );
  }
  Widget _statCard(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
  Widget _buildHotspotMapCard(Size size) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Mock background map lines
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/images/a5e6b846978f0e3dae0f5a74426e680e.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black26),
                ),
              ),
            ),
            // Haze gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Text Details & Trigger Map Button
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Mumbai Hotspots Active",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "4 high-emission zones detected near your area.",
                    style: TextStyle(color: Colors.white54, fontSize: 11.5),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: widget.onOpenMap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC72C),
                        foregroundColor: const Color(0xFF111315),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 14),
                      label: const Text('View Live Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAiInsightsCard() {
    return AiriCard(
      title: "AIRI • ATMOSPHERIC HEALTH INSIGHTS",
      message: "Particulate indexes spiked in nearby Ward-L. Remain indoors between 2 PM to 5 PM if possible. Keep window filters active.",
      expression: "monitoring",
    );
  }
  Widget _buildMyReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "MY REPORTS Log",
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 0.5),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(color: Color(0xFFFFC72C), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _myReports.length,
          itemBuilder: (context, index) {
            final r = _myReports[index];
            final Color statusColor = r["color"];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r["type"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        const SizedBox(height: 2),
                        Text("${r["location"]} • ${r["time"]}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      r["status"],
                      style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
