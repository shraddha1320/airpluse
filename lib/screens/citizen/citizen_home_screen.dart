import 'dart:ui';
import 'package:flutter/material.dart';
import 'airi_assistant.dart';
import 'report_issue_screen.dart';
class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});
  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}
class _CitizenDashboardState extends State<CitizenDashboard> with TickerProviderStateMixin {
  late final AnimationController _radarController;
  late final Animation<double> _radarPulse;
  int _navIndex = 0;
  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _radarPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );
  }
  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }
  void _navigateToReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportIssueScreen(isGuest: false),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Base
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEEF7F4),
                    Color(0xFFF5FBFF),
                    Color(0xFFEAF4FF),
                  ],
                ),
              ),
            ),
          ),
          // Scrollable Home Page Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildAqiHeroCard(isTablet),
                        const SizedBox(height: 16),
                        // Reusable Airi Card
                        const AiriCard(
                          title: "AIRI • Assistant",
                          message: "AQI is expected to rise after 6 PM. Consider wearing a mask.",
                          expression: "happy",
                        ),
                        const SizedBox(height: 20),
                        _buildGovernmentAdvisoryCard(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Community Report Statistics'),
                        _buildCommunityStats(isTablet),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Live Pollution Hotspots'),
                        _buildMapCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('AI Predictions'),
                        _buildAiPredictionsSection(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Recent Pollution Reports'),
                        _buildRecentReportsTimeline(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Floating navigation bar
          _buildFloatingNavBar(),
        ],
      ),
    );
  }
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Evening, Shraddha 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 4),
                Text(
                  'Mumbai, Maharashtra',
                  style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_outlined, color: Color(0xFF0EA5E9), size: 14),
                  SizedBox(width: 4),
                  Text('31°C', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A))),
                ],
              ),
              SizedBox(height: 2),
              Text(
                '🛰 Live Satellite Active',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: Color(0xFF0EA5E9)),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildAqiHeroCard(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AIR QUALITY INDEX',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '148',
                        style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '↑ 4%',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Moderate • Wear Mask',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(
                      value: 0.74,
                      strokeWidth: 8,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                    Text(
                      '74%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: isTablet ? 6 : 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _aqiSubMetric('PM2.5', '54.2'),
              _aqiSubMetric('PM10', '82.0'),
              _aqiSubMetric('NO₂', '24.1'),
              _aqiSubMetric('CO', '0.8'),
              _aqiSubMetric('SO₂', '12.4'),
              _aqiSubMetric('O₃', '34.5'),
            ],
          ),
        ],
      ),
    );
  }
  Widget _aqiSubMetric(String gas, String val) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            gas,
            style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
          ),
          Text(
            val,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  Widget _buildGovernmentAdvisoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 8),
              Text(
                'Government Safety Advisory',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('• Avoid outdoor exercise between 5 PM and 8 PM.', style: TextStyle(fontSize: 12, color: Colors.black87)),
          SizedBox(height: 4),
          Text('• Wear N95 masks if travelling near industrial zones.', style: TextStyle(fontSize: 12, color: Colors.black87)),
          SizedBox(height: 4),
          Text('• Children and elderly should limit prolonged exposure.', style: TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
  Widget _buildCommunityStats(bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 3 : 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: [
        _statCard('📄', '12,846', 'Total Received'),
        _statCard('🟡', '182', 'Under Review'),
        _statCard('✅', '11,947', 'Successfully Resolved'),
      ],
    );
  }
  Widget _statCard(String icon, String val, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  Widget _buildMapCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CustomPaint(
              painter: _MumbaiMapPainterLine(),
            ),
          ),
          AnimatedBuilder(
            animation: _radarPulse,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 140 * _radarPulse.value,
                  height: 140 * _radarPulse.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0EA5E9).withOpacity(1.0 - _radarPulse.value),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Live Pollution Hotspots', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                const Text('🛰 AI Satellite Layer Active', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAiPredictionsSection() {
    final predictions = [
      {'title': 'Tomorrow AQI Forecast', 'icon': Icons.online_prediction, 'trend': 'Stable (140-150)'},
      {'title': 'Rain Expected', 'icon': Icons.umbrella_outlined, 'trend': 'AQI expected to drop'},
      {'title': 'Smoke Detection', 'icon': Icons.fire_extinguisher_outlined, 'trend': 'Monitoring Kurla East'},
      {'title': 'Industrial Emissions', 'icon': Icons.factory_outlined, 'trend': 'Active near Thane'},
    ];
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: predictions.length,
        itemBuilder: (context, index) {
          final p = predictions[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(p['icon'] as IconData, color: const Color(0xFF0EA5E9), size: 22),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(p['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(p['trend'] as String, style: const TextStyle(color: Colors.black45, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildRecentReportsTimeline() {
    final reports = [
      {'id': 'AP-2026-00482', 'status': 'Verified', 'color': const Color(0xFF10B981), 'loc': 'Bandra West', 'cat': 'Smoke Emission', 'time': '2 hrs ago'},
      {'id': 'AP-2026-00478', 'status': 'Under Review', 'color': const Color(0xFFF59E0B), 'loc': 'Kurla East', 'cat': 'Garbage Burning', 'time': 'Yesterday'},
      {'id': 'AP-2026-00451', 'status': 'Resolved', 'color': const Color(0xFF0EA5E9), 'loc': 'Colaba Coast', 'cat': 'Industrial Waste', 'time': '3 days ago'},
    ];
    return Column(
      children: reports.map((r) {
        final id = r['id'] as String;
        final status = r['status'] as String;
        final color = r['color'] as Color;
        final loc = r['loc'] as String;
        final cat = r['cat'] as String;
        final time = r['time'] as String;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('$cat • $loc • $time', style: const TextStyle(color: Colors.black45, fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_filled, 0),
                _navItem(Icons.map_outlined, 1),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
                  onPressed: () {
                    _navigateToReport(context);
                  },
                ),
                _navItem(Icons.notifications_outlined, 3),
                _navItem(Icons.person_outline, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _navItem(IconData icon, int index) {
    final isSelected = _navIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.white60, size: 24),
      onPressed: () {
        setState(() {
          _navIndex = index;
        });
      },
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF0F172A),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
class _MumbaiMapPainterLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final coastPaint = Paint()
      ..color = const Color(0xFF0EA5E9).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final coastPath = Path()
      ..moveTo(0, h * 0.15)
      ..quadraticBezierTo(w * 0.45, h * 0.35, w * 0.28, h * 0.6)
      ..quadraticBezierTo(w * 0.18, h * 0.8, w * 0.05, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(coastPath, coastPaint);
    final road = Paint()
      ..color = Colors.black12
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, h * 0.4), Offset(w, h * 0.5), road);
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.4, h), road);
    // Glowing hotspot representation
    canvas.drawCircle(
      Offset(w * 0.45, h * 0.55),
      8,
      Paint()
        ..color = const Color(0xFFEF4444).withOpacity(0.4)
        ..style = PaintingStyle.fill,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
