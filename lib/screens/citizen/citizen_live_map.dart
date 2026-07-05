import 'dart:math' as math;
import 'package:flutter/material.dart';
class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});
  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}
class _LiveMapScreenState extends State<LiveMapScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _cardEntrance;
  String _selectedFilter = 'AI Pollution';
  double _zoom = 1.0;
  Offset _mapOffset = Offset.zero;
  final List<String> _filters = [
    'AI Pollution',
    'Smoke',
    'Garbage',
    'Industrial',
    'Construction',
    'Vehicle'
  ];
  @override
  void initState() {
    super.initState();
    _cardEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }
  @override
  void dispose() {
    _cardEntrance.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // 1. Full-screen Interactive map layout
        Positioned.fill(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _mapOffset += details.delta;
              });
            },
            child: CustomPaint(
              painter: _LiveMapPainter(
                zoom: _zoom,
                offset: _mapOffset,
                filter: _selectedFilter,
              ),
            ),
          ),
        ),
        // 2. Top search bar & filter chips
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
              CurvedAnimation(parent: _cardEntrance, curve: Curves.easeOutCubic),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D22).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white54, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Search areas, hotspots...",
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: Color(0xFFFFC72C), size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Category chips scroll
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final f = _filters[index];
                      final bool isSel = _selectedFilter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFC72C) : const Color(0xFF1B1D22).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? const Color(0xFFFFC72C) : Colors.white.withOpacity(0.04)),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isSel ? const Color(0xFF111315) : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // 3. Right side Legend panel
        Positioned(
          right: 16,
          top: 110,
          child: Column(
            children: [
              _buildLegendPanel(),
              const SizedBox(height: 12),
              _buildZoomButtons(),
            ],
          ),
        ),
        // 4. Bottom ML 24h Prediction card
        Positioned(
          bottom: 84, // Sit above the floating navigation bar
          left: 16,
          right: 16,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
              CurvedAnimation(parent: _cardEntrance, curve: Curves.easeOutCubic),
            ),
            child: _buildPredictionPanel(),
          ),
        ),
      ],
    );
  }
  Widget _buildLegendPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _legendColorDot(const Color(0xFFEF4444), "Critical"),
          const SizedBox(height: 6),
          _legendColorDot(const Color(0xFFFFC72C), "Moderate"),
          const SizedBox(height: 6),
          _legendColorDot(const Color(0xFF34D399), "Healthy"),
        ],
      ),
    );
  }
  Widget _legendColorDot(Color col, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.bold)),
      ],
    );
  }
  Widget _buildZoomButtons() {
    return Column(
      children: [
        _mapToolButton(Icons.add, () => setState(() => _zoom = math.min(_zoom + 0.1, 2.5))),
        const SizedBox(height: 6),
        _mapToolButton(Icons.remove, () => setState(() => _zoom = math.max(_zoom - 0.1, 0.6))),
      ],
    );
  }
  Widget _mapToolButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D22).withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }
  Widget _buildPredictionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('AI 24H PREDICTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                ],
              ),
              const Text('Live Updates', style: TextStyle(color: Color(0xFFFFC72C), fontSize: 9.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Expected AQI trend is decreasing down by 14% over next 8 hours in Carter Road.",
            style: TextStyle(color: Colors.white54, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          // Micro trend graph mock lines
          Container(
            height: 28,
            width: double.infinity,
            alignment: Alignment.center,
            child: CustomPaint(
              size: const Size(double.infinity, 28),
              painter: _MicroTrendPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Last updated: Just now", style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 9, fontWeight: FontWeight.bold)),
              const Text("Accuracy: 96.4%", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
// CUSTOM MAP AND GRAPH PAINTERS
class _LiveMapPainter extends CustomPainter {
  final double zoom;
  final Offset offset;
  final String filter;
  _LiveMapPainter({
    required this.zoom,
    required this.offset,
    required this.filter,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2) + offset;
    final paint = Paint();
    // 1. Draw Map base grid
    paint.color = Colors.white.withOpacity(0.015);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    final double gridSpace = 60.0 * zoom;
    for (double i = center.dx % gridSpace; i < w; i += gridSpace) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
    }
    for (double i = center.dy % gridSpace; i < h; i += gridSpace) {
      canvas.drawLine(Offset(0, i), Offset(w, i), paint);
    }
    // 2. Draw mock road lines
    paint.color = Colors.white.withOpacity(0.04);
    paint.strokeWidth = 3.0 * zoom;
    canvas.drawLine(Offset(0, center.dy), Offset(w, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, h), paint);
    // 3. Draw ML Heatmap and Hotspots (dependent on filter)
    paint.style = PaintingStyle.fill;
    final List<Map<String, dynamic>> heatPoints = [
      {"pos": center + Offset(-80 * zoom, -120 * zoom), "col": const Color(0xFFEF4444).withOpacity(0.22), "rad": 60.0 * zoom},
      {"pos": center + Offset(100 * zoom, 40 * zoom), "col": const Color(0xFFFFC72C).withOpacity(0.18), "rad": 80.0 * zoom},
      {"pos": center + Offset(-40 * zoom, 180 * zoom), "col": const Color(0xFF34D399).withOpacity(0.14), "rad": 70.0 * zoom},
    ];
    for (var pt in heatPoints) {
      paint.color = pt["col"];
      canvas.drawCircle(pt["pos"], pt["rad"], paint);
    }
    // 4. Hotspot indicator dots
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFEF4444);
    canvas.drawCircle(center + Offset(-80 * zoom, -120 * zoom), 6 * zoom, paint);
    paint.color = const Color(0xFFFFC72C);
    canvas.drawCircle(center + Offset(100 * zoom, 40 * zoom), 6 * zoom, paint);
  }
  @override
  bool shouldRepaint(covariant _LiveMapPainter oldDelegate) =>
      oldDelegate.zoom != zoom || oldDelegate.offset != offset || oldDelegate.filter != filter;
}
class _MicroTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC72C)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.3, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.2);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
