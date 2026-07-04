import 'dart:ui';
import 'package:flutter/material.dart';
import 'airi_assistant.dart';
class ReportIssueScreen extends StatefulWidget {
  final bool isGuest;
  final String citizenName;
  const ReportIssueScreen({
    super.key,
    this.isGuest = false,
    this.citizenName = "Citizen",
  });
  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}
class _ReportIssueScreenState extends State<ReportIssueScreen> with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final PageController _pageController;
  late final Animation<double> _scanLine;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
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
    _pageController = PageController(initialPage: 0);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
  }
  @override
  void dispose() {
    _scanController.dispose();
    _pageController.dispose();
    _descCtrl.dispose();
    _landmarkCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }
  String _getAiriMessage() {
    if (_step == 0) {
      return "What did you notice? Select a pollution type.";
    }
    if (_step == 1) {
      if (_imageSource == null) {
        return "Upload a clear photo.";
      } else {
        return "Smoke detected. 96% confidence.";
      }
    }
    return "Confirm the location.";
  }
  String _getAiriExpression() {
    if (_step == 1 && _imageSource != null) {
      return "happy";
    }
    return "pointing";
  }
  void _next() {
    if (_step == 0) {
      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select category')),
        );
        return;
      }
      if (!_formKey1.currentState!.validate()) {
        return;
      }
    }
    if (_step == 1 && _imageSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload evidence')),
      );
      return;
    }
    if (_step < 2) {
      setState(() {
        _step++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }
  void _submit() async {
    if (!_formKey3.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    await Future.delayed(const Duration(seconds: 1500 ~/ 1000));
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });
    _showSuccessDialog();
  }
  void _showSuccessDialog() {
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
              const Text(
                'Report Submitted',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Airi: "Thank you for helping keep Mumbai clean."',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'Tracking: AP-2026-00482',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  child: const Text('Return'),
                ),
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 0) {
              setState(() {
                _step--;
              });
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Report Issue',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEEF7F4), Color(0xFFF5FBFF), Color(0xFFEAF4FF)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SatelliteMapPainter(
                    scanValue: _scanLine.value,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Text(
                        'Step ${_step + 1} of 3',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9)),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: (_step + 1) / 3,
                        backgroundColor: Colors.black12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: AiriCard(
                    title: "AIRI",
                    message: _getAiriMessage(),
                    expression: _getAiriExpression(),
                  ),
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
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _categories.map((c) {
                return ChoiceChip(
                  label: Text('${c["icon"]} ${c["label"]}'),
                  selected: _category == c["label"],
                  selectedColor: const Color(0xFF10B981).withOpacity(0.15),
                  onSelected: (s) {
                    setState(() {
                      _category = s ? c["label"] : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              maxLength: 300,
              maxLines: 4,
              decoration: _dec('Describe pollution source...'),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _step2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: _imageSource == null
                  ? const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.black38)
                  : Text(
                'Preview: Image from $_imageSource Uploaded',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _imageSource = 'Camera';
                    });
                  },
                  child: const Text('Capture'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _imageSource = 'Gallery';
                    });
                  },
                  child: const Text('Gallery'),
                ),
              ),
            ],
          ),
          if (_imageSource != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Detection: Smoke Detected', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Confidence: 96% | Severity: High', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
  Widget _step3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Center(
                child: Text(
                  '📍 Mumbai GPS Active',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _landmarkCtrl, decoration: _dec('Nearby Landmark (optional)')),
            const SizedBox(height: 12),
            TextFormField(controller: _remarksCtrl, decoration: _dec('Additional Remarks (optional)')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(widget.isGuest ? Icons.visibility_off : Icons.person),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isGuest
                          ? 'Anonymous: Profile hidden.'
                          : 'Reporting as: ${widget.citizenName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF10B981)),
      ),
    );
  }
}
class _SatelliteMapPainter extends CustomPainter {
  final double scanValue;
  _SatelliteMapPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final grid = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (double i = 0; i < h; i += 90) {
      canvas.drawLine(Offset(0, i), Offset(w, i + 20), grid);
    }
    for (double i = 0; i < w; i += 80) {
      canvas.drawLine(Offset(i, 0), Offset(i + 30, h), grid);
    }
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      80,
      Paint()
        ..color = const Color(0xFFEF4444).withOpacity(0.04)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * scanValue - 40, w, 80),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981).withOpacity(0.0),
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, h * scanValue - 40, w, 80))
        ..style = PaintingStyle.fill,
    );
  }
  @override
  bool shouldRepaint(covariant _SatelliteMapPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}
