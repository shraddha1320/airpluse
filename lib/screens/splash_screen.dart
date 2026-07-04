import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _scanController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scanLine;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _animController.forward();
    Timer(const Duration(seconds: 3), _navigateToNextScreen);
  }
  void _navigateToNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
  @override
  void dispose() {
    _animController.dispose();
    _scanController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Light Theme Map/Heatmap Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE3F2FD),
                    Color(0xFFF1F8F6),
                    Color(0xFFEAF7F3),
                  ],
                ),
              ),
            ),
          ),
          // Soft Satellite Heatmap Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _SatelliteMapHeatmapPainter(scanValue: _scanLine.value),
            ),
          ),
          // 2. Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 60),
                    // Logo & App Name
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Scanner Ring surrounding Logo
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0EA5E9).withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: CustomPaint(
                                  painter: _ScanningRadarPainter(scanValue: _scanLine.value),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF0EA5E9)],
                                ),
                              ),
                              child: const Icon(
                                Icons.satellite_alt_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Title
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'AIRPULSE ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Subtitle Tagline
                        const Text(
                          'MONITOR. DETECT. PROTECT.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0EA5E9),
                            letterSpacing: 4.0,
                          ),
                        ),
                      ],
                    ),
                    // Bottom Loading Status
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 140,
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Scanning Air Quality Layers...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _SatelliteMapHeatmapPainter extends CustomPainter {
  final double scanValue;
  _SatelliteMapHeatmapPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFF0EA5E9).withOpacity(0.12);
    // Draw grid representing map grid lines
    const gridSpacing = 40.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Soft Heatmap blobs (Representing pollution overlays)
    final heatmapPaint1 = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.06) // Emerald safe zone
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    final heatmapPaint2 = Paint()
      ..color = const Color(0xFFEF4444).withOpacity(0.04) // Red danger hotspot
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.25), 120, heatmapPaint1);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), 150, heatmapPaint2);
    // Active AI Scan line sweep
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF10B981).withOpacity(0.0),
          const Color(0xFF10B981).withOpacity(0.2),
          const Color(0xFF10B981).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * scanValue - 40, size.width, 80))
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, size.height * scanValue - 40, size.width, 80), scanPaint);
  }
  @override
  bool shouldRepaint(covariant _SatelliteMapHeatmapPainter oldDelegate) =>
      oldDelegate.scanValue != scanValue;
}
class _ScanningRadarPainter extends CustomPainter {
  final double scanValue;
  _ScanningRadarPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    // Draw scanning concentric circles
    final paint = Paint()
      ..color = const Color(0xFF0EA5E9).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius * 0.5, paint);
    canvas.drawCircle(center, maxRadius * 0.8, paint);
    // Sweeping radar wedge
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: [
          const Color(0xFF10B981).withOpacity(0.3),
          const Color(0xFF0EA5E9).withOpacity(0.0),
        ],
        transform: GradientRotation(scanValue * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, sweepPaint);
  }
  @override
  bool shouldRepaint(covariant _ScanningRadarPainter oldDelegate) =>
      oldDelegate.scanValue != scanValue;
}
