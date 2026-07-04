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
  late final AnimationController _airiController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scanLine;
  late final Animation<double> _airiFloat;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scanController, curve: Curves.easeInOut));
    _airiController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _airiFloat = Tween<double>(begin: 0.0, end: 8.0).animate(CurvedAnimation(parent: _airiController, curve: Curves.easeInOut));
    _animController.forward();
    Timer(const Duration(seconds: 3), _navigateToNext);
  }
  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
  @override
  void dispose() {
    _animController.dispose();
    _scanController.dispose();
    _airiController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEEF7F4), Color(0xFFF5FBFF)])))),
          Positioned.fill(child: CustomPaint(painter: _SatelliteMapPainter(scanValue: _scanLine.value))),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 50),
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.12), blurRadius: 25)]),
                              child: ClipOval(child: CustomPaint(painter: _RadarPainter(scanValue: _scanLine.value))),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF0EA5E9)])),
                              child: const Icon(Icons.satellite_alt_rounded, color: Colors.white, size: 38),
                            ),
                            Positioned(
                              right: -15,
                              top: -10,
                              child: AnimatedBuilder(
                                animation: _airiFloat,
                                builder: (c, w) => Transform.translate(
                                  offset: Offset(0, _airiFloat.value),
                                  child: const SizedBox(width: 46, height: 46, child: CustomPaint(painter: AiriCharacterPainter(expression: 'sleeping'))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('AIRPULSE ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            Text('AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text('MONITOR. DETECT. PROTECT.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9), letterSpacing: 3.0)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                            child: const Text('Airi: "Initializing AirPulse AI..."', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: 130,
                            child: LinearProgressIndicator(minHeight: 4, backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.2), valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981))),
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
class AiriCharacterPainter extends CustomPainter {
  final String expression;
  const AiriCharacterPainter({required this.expression});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    // Body (Capsule/Sphere)
    canvas.drawCircle(center, r * 0.78, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(center, r * 0.78, Paint()..shader = const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF0EA5E9)]).createShader(Rect.fromCircle(center: center, radius: r))..style = PaintingStyle.stroke..strokeWidth = 1.8);
    // Mint green outfit accents (Lower half segment)
    final pathOutfit = Path()
      ..moveTo(center.dx - r * 0.7, center.dy + r * 0.35)
      ..arcTo(Rect.fromCircle(center: center, radius: r * 0.78), 0.5, 2.14, false)
      ..close();
    canvas.drawPath(pathOutfit, Paint()..color = const Color(0xFF10B981).withOpacity(0.18)..style = PaintingStyle.fill);
    // Glowing green leaf antenna on top
    final leafPaint = Paint()..color = const Color(0xFF10B981)..style = PaintingStyle.fill;
    final leafPath = Path()
      ..moveTo(center.dx, center.dy - r * 0.78)
      ..quadraticBezierTo(center.dx + r * 0.35, center.dy - r * 1.15, center.dx, center.dy - r * 1.3)
      ..quadraticBezierTo(center.dx - r * 0.35, center.dy - r * 1.15, center.dx, center.dy - r * 0.78);
    canvas.drawPath(leafPath, leafPaint);
    // Eyes & Face expression drawing
    final eyePaint = Paint()..color = const Color(0xFF0EA5E9)..style = PaintingStyle.fill;
    if (expression == 'sleeping') {
      final sleepPaint = Paint()..color = const Color(0xFF0EA5E9)..style = PaintingStyle.stroke..strokeWidth = 1.8..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx - r * 0.28, center.dy), width: r * 0.24, height: r * 0.12), math.pi, math.pi, false, sleepPaint);
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx + r * 0.28, center.dy), width: r * 0.24, height: r * 0.12), math.pi, math.pi, false, sleepPaint);
    } else {
      canvas.drawCircle(Offset(center.dx - r * 0.26, center.dy - r * 0.05), r * 0.12, eyePaint);
      canvas.drawCircle(Offset(center.dx + r * 0.26, center.dy - r * 0.05), r * 0.12, eyePaint);
      canvas.drawCircle(Offset(center.dx - r * 0.22, center.dy - r * 0.09), r * 0.04, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(center.dx + r * 0.30, center.dy - r * 0.09), r * 0.04, Paint()..color = Colors.white);
    }
    // Mouth / Smile
    final mouthPaint = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 1.2..strokeCap = StrokeCap.round;
    if (expression == 'sleeping') {
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.16), width: r * 0.2, height: r * 0.1), 0, math.pi, false, mouthPaint);
    } else {
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.12), width: r * 0.3, height: r * 0.15), 0, math.pi, false, mouthPaint);
    }
  }
  @override
  bool shouldRepaint(covariant AiriCharacterPainter oldDelegate) => oldDelegate.expression != expression;
}
class _SatelliteMapPainter extends CustomPainter {
  final double scanValue;
  _SatelliteMapPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final grid = Paint()..color = Colors.black.withOpacity(0.02)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    for (double i = 0; i < h; i += 90) canvas.drawLine(Offset(0, i), Offset(w, i + 20), grid);
    for (double i = 0; i < w; i += 80) canvas.drawLine(Offset(i, 0), Offset(i + 30, h), grid);
  }
  @override
  bool shouldRepaint(covariant _SatelliteMapPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}
class _RadarPainter extends CustomPainter {
  final double scanValue;
  _RadarPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(center, r, Paint()..shader = SweepGradient(colors: [const Color(0xFF10B981).withOpacity(0.2), const Color(0xFF0EA5E9).withOpacity(0.0)], transform: GradientRotation(scanValue * math.pi * 2)).createShader(Rect.fromCircle(center: center, radius: r))..style = PaintingStyle.fill);
  }
  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}
