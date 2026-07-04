import 'dart:ui';
import 'package:flutter/material.dart';
class ReportIssueScreen extends StatefulWidget {
  final bool isGuest;
  final String citizenName;
  const ReportIssueScreen({super.key, this.isGuest = false, this.citizenName = "Citizen"});
  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}
class _ReportIssueScreenState extends State<ReportIssueScreen> with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final PageController _pageController = PageController();
  late final Animation<double> _scanLine;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _remarksController = TextEditingController();
  int _step = 0;
  String? _category;
  String? _imageSource;
  bool _isSubmitting = false;
  final List<Map<String, String>> _categories = [
    {"label": "Smoke", "icon": "🔥"},
    {"label": "Garbage Dump", "icon": "🗑"},
    {"label": "Industrial Pollution", "icon": "🏭"},
    {"label": "Construction Dust", "icon": "🚧"},
    {"label": "Waste Burning", "icon": "♻"},
    {"label": "Water Pollution", "icon": "💧"},
    {"label": "Other", "icon": "⚠"},
  ];
  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
  }
  @override
  void dispose() {
    _scanController.dispose();
    _pageController.dispose();
    _descController.dispose();
    _landmarkController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
  void _next() {
    if (_step == 0) {
      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select category')));
        return;
      }
      if (!_formKey1.currentState!.validate()) return;
    }
    if (_step == 1 && _imageSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload evidence')));
      return;
    }
    if (_step < 2) {
      setState(() { _step++; });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }
  void _prev() {
    if (_step > 0) {
      setState(() { _step--; });
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.of(context).pop();
    }
  }
  Future<void> _submit() async {
    if (!_formKey3.currentState!.validate()) return;
    setState(() { _isSubmitting = true; });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() { _isSubmitting = false; });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 64),
              const SizedBox(height: 12),
              const Text('Report Submitted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: const Text('Tracking: AP-2026-00482', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9)))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
                Navigator.pop(c);        // Close dialog
                Navigator.pop(context);  // Go back to previous screen
              }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)), child: const Text('Return'))),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFF),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prev), title: const Text('Report Issue', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEEF7F4), Color(0xFFF5FBFF), Color(0xFFEAF4FF)])))),
          Positioned.fill(child: AnimatedBuilder(animation: _scanLine, builder: (c, w) => CustomPaint(painter: _SatelliteMapPainter(scanValue: _scanLine.value)))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [Text('Step ${_step + 1} of 3', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))), const SizedBox(height: 6), LinearProgressIndicator(value: (_step + 1) / 3, backgroundColor: Colors.black12, valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)))]),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [_step1(), _step2(), _step3()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _step1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report a Pollution Incident', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Help authorities improve air quality by reporting pollution.', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 4, children: _categories.map((c) => ChoiceChip(label: Text('${c["icon"]} ${c["label"]}'), selected: _category == c["label"], selectedColor: const Color(0xFF10B981).withOpacity(0.15), onSelected: (s) => setState(() => _category = s ? c["label"] : null))).toList()),
            const SizedBox(height: 20),
            TextFormField(controller: _descController, maxLength: 300, maxLines: 4, decoration: _dec('Describe pollution source...'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white), child: const Text('Continue'))),
          ],
        ),
      ),
    );
  }
  Widget _step2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Evidence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 160, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
            child: _imageSource == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, size: 44, color: const Color(0xFF0EA5E9).withOpacity(0.6)), const Text('Upload evidence image', style: TextStyle(color: Colors.black45, fontSize: 12))])
                : Stack(fit: StackFit.expand, children: [Center(child: Text('Preview: $_imageSource Source Selected')), Positioned(right: 8, top: 8, child: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => setState(() => _imageSource = null)))]),
          ),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: OutlinedButton(onPressed: () => setState(() => _imageSource = 'Camera'), child: const Text('Capture'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => setState(() => _imageSource = 'Gallery'), child: const Text('Gallery')))]),
          if (_imageSource != null) ...[
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AI Detection: Smoke Detected', style: TextStyle(fontWeight: FontWeight.bold)), Text('Confidence: 96% | Severity: High', style: TextStyle(fontSize: 12))])),
          ],
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white), child: const Text('Continue'))),
        ],
      ),
    );
  }
  Widget _step3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)), child: const Center(child: Text('📍 Mumbai GPS Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)))),
            const SizedBox(height: 12),
            TextFormField(controller: _landmarkController, decoration: _dec('Nearby Landmark (optional)')),
            const SizedBox(height: 12),
            TextFormField(controller: _remarksController, decoration: _dec('Additional Remarks (optional)')),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(widget.isGuest ? Icons.visibility_off : Icons.person), const SizedBox(width: 8), Expanded(child: Text(widget.isGuest ? 'Anonymous Report: Identity hidden.' : 'Reporting as: ${widget.citizenName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))])),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _isSubmitting ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white), child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Report'))),
          ],
        ),
      ),
    );
  }
  InputDecoration _dec(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF1F5F9), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))));
}
class _SatelliteMapPainter extends CustomPainter {
  final double scanValue;
  _SatelliteMapPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final grid = Paint()..color = Colors.black.withOpacity(0.02)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    for (double i = 0; i < h; i += 90) {
      canvas.drawLine(Offset(0, i), Offset(w, i + 20), grid);
    }
    for (double i = 0; i < w; i += 80) {
      canvas.drawLine(Offset(i, 0), Offset(i + 30, h), grid);
    }
    final red = Paint()..color = const Color(0xFFEF4444).withOpacity(0.04)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 80, red);
    final sweep = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFF10B981).withOpacity(0.0), const Color(0xFF10B981).withOpacity(0.1), const Color(0xFF10B981).withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, h * scanValue - 40, w, 80))
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, h * scanValue - 40, w, 80), sweep);
  }
  @override
  bool shouldRepaint(covariant _SatelliteMapPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}
