import 'dart:async';
import 'dart:math' as math;
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
  // Navigation active tab
  int _navIndex = 0;
  // Animation controller for continuous radar sweeps, gradients, and micro-interactions
  late final AnimationController _pulseController;
  late final AnimationController _countController;
  // Counter values for animation
  int _totalReports = 0;
  int _pendingReports = 0;
  int _resolvedReports = 0;
  // Toggle state for map style
  bool _isSatelliteMode = true;
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    // Animate stats counting up smoothly
    _countController.forward();
    _countController.addListener(() {
      setState(() {
        _totalReports = (_countController.value * 12846).toInt();
        _pendingReports = (_countController.value * 182).toInt();
        _resolvedReports = (_countController.value * 11947).toInt();
      });
    });
  }
  @override
  void dispose() {
    _pulseController.dispose();
    _countController.dispose();
    super.dispose();
  }
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
  void _navigateToFullMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DedicatedMapScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      body: Stack(
        children: [
          // 1. Futuristic Background Grid Map
          Positioned.fill(
            child: CustomPaint(
              painter: _AmbientHomeGridPainter(progress: _pulseController.value),
            ),
          ),
          // 2. Main Tab Contents
          SafeArea(
            child: IndexedStack(
              index: _navIndex == 0 ? 0 : (_navIndex == 1 ? 1 : (_navIndex == 3 ? 3 : 4)),
              children: [
                // Citizen Landing Home Tab (Index 0)
                _buildHomeTab(size, isTablet),
                // Placeholder views for other navigation channels
                const _PlaceholderReportListScreen(),
                const SizedBox(), // Spacer for center button
                const DedicatedMapScreen(),
                const _PlaceholderProfileScreen(),
              ],
            ),
          ),
          // 3. Floating Bottom Navigation Bar (Circular centre Report trigger)
          _buildFloatingBottomNavBar(),
        ],
      ),
    );
  }
  // BUILDER METHODS FOR HOME TAB
  Widget _buildHomeTab(Size size, bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHomeHeader(),
          const SizedBox(height: 24),
          // Community Overview Premium Statistic cards
          _buildCommunityOverview(isTablet),
          const SizedBox(height: 24),
          // Live Hotspot Map Preview Card
          _buildLiveHotspotMapCard(),
          const SizedBox(height: 24),
          // AI Insights AIRI recommendations
          _buildAiInsightsSection(),
          const SizedBox(height: 24),
          // Government Advisory Card
          _buildGovernmentAdvisorySection(),
          const SizedBox(height: 100), // padding to clear bottom navigation
        ],
      ),
    );
  }
  Widget _buildHomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Evening, Shraddha 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Mumbai, Maharashtra',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white30),
                ),
                const SizedBox(width: 8),
                const Text(
                  '2 mins ago',
                  style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        // Live satellite status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1D22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Row(
            children: [
              Icon(Icons.satellite_alt_rounded, color: Color(0xFF38BDF8), size: 14),
              SizedBox(width: 6),
              Text(
                'LIVE SATELLITE',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildCommunityOverview(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "COMMUNITY OVERVIEW",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGlassStatCard(
                icon: "📄",
                value: "$_totalReports",
                label: "Total Reports",
                highlightColor: const Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildGlassStatCard(
                icon: "🟡",
                value: "$_pendingReports",
                label: "Pending Reports",
                highlightColor: const Color(0xFFFFC72C),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildGlassStatCard(
                icon: "✅",
                value: "$_resolvedReports",
                label: "Resolved Reports",
                highlightColor: const Color(0xFF34D399),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildGlassStatCard({
    required String icon,
    required String value,
    required String label,
    required Color highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLiveHotspotMapCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "LIVE HOTSPOT MAP PREVIEW",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1D22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Satellite Map Custom Painter
                CustomPaint(
                  painter: _SatelliteMapMeshPainter(
                    progress: _pulseController.value,
                    isSatellite: _isSatelliteMode,
                  ),
                ),
                // Heatmap pulses overlay
                _buildMapPulseCircle(0.35, 0.45, const Color(0xFFEF4444)),
                _buildMapPulseCircle(0.72, 0.3, const Color(0xFFF4B400)),
                _buildMapPulseCircle(0.55, 0.75, const Color(0xFFEF4444)),
                // Legend and Map Mode toggle controls
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _isSatelliteMode = !_isSatelliteMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111315).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSatelliteMode ? Icons.map_outlined : Icons.satellite_alt_rounded,
                            color: const Color(0xFF38BDF8),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isSatelliteMode ? 'Vector Map' : 'Satellite Mode',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Overlay controls & AQI Gradient Legend
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🛰 Satellite Map Feed Active',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // AQI Legend representation
                          Row(
                            children: [
                              _legendDot(const Color(0xFF34D399), "Good"),
                              _legendSpacer(),
                              _legendDot(const Color(0xFFFFC72C), "Mod"),
                              _legendSpacer(),
                              _legendDot(const Color(0xFFF4B400), "Poor"),
                              _legendSpacer(),
                              _legendDot(const Color(0xFFEF4444), "Severe"),
                            ],
                          ),
                        ],
                      ),
                      // Dedicated map screen navigate button
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _navigateToFullMap(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC72C),
                            foregroundColor: const Color(0xFF111315),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          child: const Row(
                            children: [
                              Text('Open Full Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _legendDot(Color color, String name) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(name, style: const TextStyle(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.bold)),
      ],
    );
  }
  Widget _legendSpacer() => const SizedBox(width: 8);
  Widget _buildMapPulseCircle(double topPercent, double leftPercent, Color color) {
    return Positioned(
      top: 220 * topPercent,
      left: MediaQuery.of(context).size.width * 0.7 * leftPercent, // Approximate horizontal offsets
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final double wave = 6 + 10 * math.sin(_pulseController.value * 2 * math.pi * 2.5);
          return Container(
            width: wave * 2,
            height: wave * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(1.0 - (_pulseController.value % 1.0)), width: 1),
            ),
          );
        },
      ),
    );
  }
  Widget _buildAiInsightsSection() {
    final List<String> insights = [
      "Smoke levels increasing in Kurla. Wear masks.",
      "AQI is expected to rise after 6 PM today.",
      "Expected regional rains may improve air quality tomorrow."
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "AI INSIGHTS & FORECASTS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        // Reusable AIRI Speach Card widget
        AiriCard(
          title: "AIRI • SCIENTIFIC ADVISE",
          message: insights[math.Random().nextInt(insights.length)],
          expression: "happy",
        ),
      ],
    );
  }
  Widget _buildGovernmentAdvisorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "GOVERNMENT SAFETY ADVISORY",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1D22).withOpacity(0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Active Advisory Guidelines',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("•  ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: Text(
                      'Avoid strenuous outdoor exercise between 5 PM and 8 PM due to particulate settlement.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("•  ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: Text(
                      'Wear N95 protective respirators / masks in active industrial corridors.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  // BOTTOM NAVIGATION BAR
  Widget _buildFloatingBottomNavBar() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1D22).withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(0, 5)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_filled, "Home", 0),
                _buildNavItem(Icons.assignment_outlined, "My Reports", 1),

                // Raised centre Report Button
                _buildCentreReportButton(),

                _buildNavItem(Icons.map_outlined, "Map", 3),
                _buildNavItem(Icons.person_outline, "Profile", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          // Direct navigation override for dedicated Map Screen
          _navigateToFullMap(context);
        } else {
          setState(() {
            _navIndex = index;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFFC72C) : Colors.white30,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFFFC72C) : Colors.white30,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCentreReportButton() {
    return GestureDetector(
      onTap: () => _navigateToReport(context),
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFC72C),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC72C).withOpacity(0.35),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFF111315), width: 3),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Color(0xFF111315),
            size: 28,
          ),
        ),
      ),
    );
  }
}
// CUSTOM PAINTERS
class _AmbientHomeGridPainter extends CustomPainter {
  final double progress;
  _AmbientHomeGridPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.012)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final double w = size.width;
    final double h = size.height;
    const double gridSize = 65.0;
    for (double i = 0; i < w; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
    }
    for (double i = 0; i < h; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(w, i), paint);
    }
    // Ambient floating particles
    final rand = math.Random(133);
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final double rx = rand.nextDouble() * w;
      final double ry = rand.nextDouble() * h;
      final double sizeVal = rand.nextDouble() * 1.5 + 0.5;
      final double drift = math.sin(progress * 2 * math.pi + i) * 6;
      paint.color = Colors.white.withOpacity(0.04 + 0.08 * math.sin(progress * 2 * math.pi * (i % 2 + 1)));
      canvas.drawCircle(Offset(rx, (ry + drift) % h), sizeVal, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _AmbientHomeGridPainter oldDelegate) => true;
}
class _SatelliteMapMeshPainter extends CustomPainter {
  final double progress;
  final bool isSatellite;
  _SatelliteMapMeshPainter({required this.progress, required this.isSatellite});
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final paint = Paint();
    if (isSatellite) {
      // Draw simulated geographic landmass shapes (Google Earth style)
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF15191C);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
      // Faint shoreline / vegetation polygons
      paint.color = const Color(0xFF1E2429);
      final pathShore = Path()
        ..moveTo(w * 0.15, 0)
        ..quadraticBezierTo(w * 0.35, h * 0.4, w * 0.2, h * 0.8)
        ..quadraticBezierTo(w * 0.1, h * 0.95, 0, h)
        ..lineTo(w, h)
        ..lineTo(w, 0)
        ..close();
      canvas.drawPath(pathShore, paint);
      // Satellite grid lines
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.white.withOpacity(0.03);
      paint.strokeWidth = 0.5;
      for (double i = 0; i < w; i += 30) {
        canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
      }
      for (double i = 0; i < h; i += 30) {
        canvas.drawLine(Offset(0, i), Offset(w, i), paint);
      }
    } else {
      // Normal vector map style
      paint.color = const Color(0xFF181C20);
      paint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
      // Roads
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.white.withOpacity(0.04);
      paint.strokeWidth = 1.0;
      canvas.drawLine(Offset(0, h * 0.35), Offset(w, h * 0.45), paint);
      canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.6), paint);
      canvas.drawLine(Offset(w * 0.4, 0), Offset(w * 0.5, h), paint);
    }
    // Radar scan concentric sweeping line
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFFFFC72C).withOpacity(0.12 * (1 - (progress % 1.0)));
    paint.strokeWidth = 1.5;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), progress * math.max(w, h) * 0.6, paint);
  }
  @override
  bool shouldRepaint(covariant _SatelliteMapMeshPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isSatellite != isSatellite;
}
// DEDICATED MAP SCREEN PLACEHOLDER
class DedicatedMapScreen extends StatelessWidget {
  const DedicatedMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      appBar: AppBar(
        title: const Text('Live Satellite Mapping Network', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8).withOpacity(0.12),
                ),
                child: const Icon(Icons.satellite_alt_rounded, size: 64, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Live Heatmaps System',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Real-time atmospheric pollutants levels are mapped continuously from low-orbit Sentinel satellites.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC72C),
                    foregroundColor: const Color(0xFF111315),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// INLINE NAVIGATION TAB PLACEHOLDERS
class _PlaceholderReportListScreen extends StatelessWidget {
  const _PlaceholderReportListScreen();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'My Reports History Tab',
        style: TextStyle(color: Colors.white60, fontSize: 14),
      ),
    );
  }
}
class _PlaceholderProfileScreen extends StatelessWidget {
  const _PlaceholderProfileScreen();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'User Settings & Profile Tab',
        style: TextStyle(color: Colors.white60, fontSize: 14),
      ),
    );
  }
}
