import 'dart:math' as math;
import 'package:flutter/material.dart';
class AiriCard extends StatefulWidget {
  final String message;
  final String title;
  final String expression;
  const AiriCard({
    super.key,
    required this.message,
    required this.title,
    this.expression = 'happy',
  });
  @override
  State<AiriCard> createState() => _AiriCardState();
}
class _AiriCardState extends State<AiriCard> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;
  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated Floating AI Companion
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: child,
              );
            },
            child: SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(
                painter: AiriCharacterPainter(expression: widget.expression),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Speech Bubble Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                    color: Color(0xFF0EA5E9),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
              ],
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
    canvas.drawCircle(
      center,
      r * 0.78,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF0EA5E9)])
            .createShader(Rect.fromCircle(center: center, radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    // Mint green outfit accents (Lower half segment)
    final pathOutfit = Path()
      ..moveTo(center.dx - r * 0.7, center.dy + r * 0.35)
      ..arcTo(Rect.fromCircle(center: center, radius: r * 0.78), 0.5, 2.14, false)
      ..close();
    canvas.drawPath(
      pathOutfit,
      Paint()..color = const Color(0xFF10B981).withOpacity(0.18)..style = PaintingStyle.fill,
    );
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
      final sleepPaint = Paint()
        ..color = const Color(0xFF0EA5E9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx - r * 0.28, center.dy), width: r * 0.24, height: r * 0.12),
        math.pi,
        math.pi,
        false,
        sleepPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx + r * 0.28, center.dy), width: r * 0.24, height: r * 0.12),
        math.pi,
        math.pi,
        false,
        sleepPaint,
      );
    } else {
      // Normal/happy/excited eyes
      canvas.drawCircle(Offset(center.dx - r * 0.26, center.dy - r * 0.05), r * 0.12, eyePaint);
      canvas.drawCircle(Offset(center.dx + r * 0.26, center.dy - r * 0.05), r * 0.12, eyePaint);
      // Highlights
      canvas.drawCircle(Offset(center.dx - r * 0.22, center.dy - r * 0.09), r * 0.04, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(center.dx + r * 0.30, center.dy - r * 0.09), r * 0.04, Paint()..color = Colors.white);
    }
    // Mouth / Smile
    final mouthPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    if (expression == 'sleeping') {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.16), width: r * 0.2, height: r * 0.1),
        0,
        math.pi,
        false,
        mouthPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.12), width: r * 0.3, height: r * 0.15),
        0,
        math.pi,
        false,
        mouthPaint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant AiriCharacterPainter oldDelegate) => oldDelegate.expression != expression;
}
