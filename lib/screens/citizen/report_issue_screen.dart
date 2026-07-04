import 'dart:async';
import 'dart:math' as math;
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
  // Animation controllers
  late final AnimationController _scanController;
  late final AnimationController _loopController;
  late final AnimationController _aiScanController;
  late final PageController _pageController;
  late final Animation<double> _scanLine;
  // Validation keys
  final _formKey1 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  // Preserved controllers
  final _descCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  // State variables
  int _step = 0;
  String? _category;
  String? _imageSource;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  // AI Scan state variables
  bool _isAiScanning = false;
  double _aiScanProgress = 0.0;
  String _aiScanText = "Initializing scan...";
  Timer? _aiScanTimer;
  // Additional Step 3 States
  String _urgencyLevel = 'Medium';
  late bool _anonymousReporting;
  bool _isSatelliteLayer = true;
  // Categories list
  final List<Map<String, String>> _categories = [
    {"label": "Smoke", "icon": "🔥", "desc": "Airborne smoke plumes or fires"},
    {"label": "Garbage Burning", "icon": "🗑", "desc": "Incineration of urban solid wastes"},
    {"label": "Industrial Emissions", "icon": "🏭", "desc": "Toxic chemical chimney smoke"},
    {"label": "Construction Dust", "icon": "🚧", "desc": "Uncontrolled dust particles from construction"},
    {"label": "Vehicle Pollution", "icon": "🚗", "desc": "Heavy tailpipe vehicle exhaust"},
    {"label": "Chemical Leak", "icon": "☣", "desc": "Liquid or gaseous spill incident"},
    {"label": "Water Pollution", "icon": "💧", "desc": "Toxic effluents in water bodies"},
    {"label": "Noise Pollution", "icon": "🔊", "desc": "Sustained high-level urban noises"},
    {"label": "Illegal Dumping", "icon": "🚜", "desc": "Unauthorized waste trash disposal"},
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _anonymousReporting = widget.isGuest;
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _aiScanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }
  @override
  void dispose() {
    _scanController.dispose();
    _loopController.dispose();
    _aiScanController.dispose();
    _pageController.dispose();
    _descCtrl.dispose();
    _landmarkCtrl.dispose();
    _remarksCtrl.dispose();
    _aiScanTimer?.cancel();
    super.dispose();
  }
  String _getAiriMessage() {
    if (_isSuccess) return "Report uploaded to the satellite mesh grid!";
    if (_isAiScanning) return "Analyzing images for atmospheric contaminants...";

    if (_step == 0) {
      if (_category == null) {
        return "What did you notice? Select a category to begin the report.";
      } else {
        return "I'll specifically analyze ${_category!.toLowerCase()} patterns.";
      }
    }
    if (_step == 1) {
      if (_imageSource == null) {
        return "Please capture or upload a photo of the incident.";
      } else {
        return "Evidence verify complete! This looks severe.";
      }
    }
    return "Confirm the GPS location and add final remarks.";
  }
  String _getAiriExpression() {
    if (_isSuccess) return "happy";
    if (_isAiScanning) return "sleeping"; // Scanning posture
    if (_step == 1 && _imageSource != null) return "happy";
    if (_step == 2) return "monitoring";
    return "excited";
  }
  void _next() {
    if (_step == 0) {
      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a pollution category')),
        );
        return;
      }
      if (!_formKey1.currentState!.validate()) {
        return;
      }
    }
    if (_step == 1 && _imageSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload evidence for AI analysis')),
      );
      return;
    }
    if (_step < 2) {
      setState(() {
        _step++;
      });
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  void _previous() {
    if (_step > 0) {
      setState(() {
        _step--;
      });
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }
  // AI Scanning Simulator Flow
  void _triggerAiScan(String source) {
    setState(() {
      _imageSource = source;
      _isAiScanning = true;
      _aiScanProgress = 0.0;
    });
    _aiScanController.forward(from: 0.0);
    final List<String> scanSteps = [
      "Analyzing pollution markers...",
      "Detecting plume density...",
      "Estimating AQI impact indices...",
      "Cross-checking satellite layers...",
      "Verifying confidence bounds..."
    ];
    int currentStep = 0;
    _aiScanTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _aiScanProgress += 0.25;
        if (currentStep < scanSteps.length) {
          _aiScanText = scanSteps[currentStep];
          currentStep++;
        }
        if (_aiScanProgress >= 1.0) {
          _isAiScanning = false;
          timer.cancel();
        }
      });
    });
  }
  // Preserved original submit flow
  void _submit() async {
    if (!_formKey3.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    // Simulating satellite upload progress
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _isSuccess = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: _previous,
        ),
        title: const Text(
          'AI Incident Reporting',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSatelliteLayer ? Icons.satellite_outlined : Icons.map_outlined,
              color: const Color(0xFF38BDF8),
            ),
            onPressed: () {
              setState(() {
                _isSatelliteLayer = !_isSatelliteLayer;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Live Animated Satellite Grid Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _loopController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _IncidentsBackgroundPainter(
                    progress: _loopController.value,
                    scanBeamPos: _scanLine.value,
                  ),
                );
              },
            ),
          ),
          // 2. Responsive UI Page Flow
          SafeArea(
            child: Center(
              child: _isSuccess
                  ? _buildSuccessScreen(size, isTablet)
                  : Column(
                children: [
                  // Animated progress indicator header
                  _buildStepHeaderIndicator(),
                  // Embedded AIRI assistant feedback
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: _buildAiriCardSection(),
                  ),
                  const SizedBox(height: 12),
                  // Form contents
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1Category(isTablet),
                        _buildStep2Evidence(isTablet),
                        _buildStep3LocationAndSubmit(isTablet),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStepHeaderIndicator() {
    final List<String> steps = ['Detect', 'Verify', 'Submit'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final bool isActive = _step >= index;
              final bool isCurrent = _step == index;
              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFC72C) : const Color(0xFF1B1D22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? const Color(0xFFFFC72C) : Colors.white.withOpacity(0.05),
                        width: 1.5,
                      ),
                      boxShadow: isCurrent
                          ? [BoxShadow(color: const Color(0xFFFFC72C).withOpacity(0.25), blurRadius: 10)]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${index + 1}. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF111315) : Colors.white24,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF111315) : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < 2)
                    Container(
                      width: 24,
                      height: 1.5,
                      color: _step > index ? const Color(0xFFFFC72C) : Colors.white12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              minHeight: 3,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC72C)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAiriCardSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: ClipOval(
              child: CustomPaint(
                painter: AiriCharacterPainter(
                  expression: _getAiriExpression(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AIRI • FIELD INTELLIGENCE",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF38BDF8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getAiriMessage(),
                    key: ValueKey<String>(_getAiriMessage()),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // STEPS CONTENT BUILDERS
  Widget _buildStep1Category(bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Pollution Category",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 12),
            // Responsive Category Cards Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final bool isSelected = _category == cat["label"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _category = cat["label"];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFC72C).withOpacity(0.12)
                          : const Color(0xFF1B1D22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFC72C) : Colors.white.withOpacity(0.06),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFFFFC72C).withOpacity(0.2), blurRadius: 10)]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          cat["icon"]!,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat["label"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFFFFC72C) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Incident Description
            const Text(
              "Describe Incident Circumstances",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLength: 300,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _decInput('Enter details about size, behavior, duration...'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Incident description is required';
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Continue action
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC72C),
                  foregroundColor: const Color(0xFF111315),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Continue verification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildStep2Evidence(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          // Simulated Camera View finder with AI Overlay scan lines
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_imageSource == null) ...[
                    // Empty viewfinder state
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.02),
                          ),
                          child: const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.white30),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Awaiting Evidence Source Capture",
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Support drag & drop files on desktop",
                          style: TextStyle(color: Colors.white24, fontSize: 11),
                        ),
                      ],
                    ),
                  ] else if (_isAiScanning) ...[
                    // Scanning State Animation
                    _buildScanAnimationView(),
                  ] else ...[
                    // Post-Scan Verification Screen
                    _buildScanResultView(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Upload Selection Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _triggerAiScan('Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Capture Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _triggerAiScan('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Upload Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Next navigation trigger
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_imageSource != null && !_isAiScanning) ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC72C),
                foregroundColor: const Color(0xFF111315),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Proceed to Location validation', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildScanAnimationView() {
    return Stack(
      children: [
        // AI Grid mesh mockup
        Positioned.fill(
          child: CustomPaint(
            painter: _AiMeshPainter(progress: _aiScanProgress),
          ),
        ),
        // Scanning Bar Sweep
        AnimatedBuilder(
          animation: _aiScanController,
          builder: (context, child) {
            final double sweepY = _aiScanProgress * 280; // approximate box boundaries
            return Positioned(
              top: sweepY,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Color(0xFFFFC72C), blurRadius: 15, spreadRadius: 4),
                  ],
                ),
              ),
            );
          },
        ),
        // Progress Text Overlay
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _aiScanProgress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC72C)),
              ),
              const SizedBox(height: 12),
              Text(
                _aiScanText,
                style: const TextStyle(
                  color: Color(0xFFFFC72C),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildScanResultView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF34D399), size: 48),
          const SizedBox(height: 12),
          const Text(
            "AI SCENE ANALYSIS COMPLETE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF34D399),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          // Metadata metrics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF111315).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _resultMetricRow("Detected Category", _category ?? "Smoke Plume"),
                _resultMetricRow("Confidence Score", "96.4% Accuracy"),
                _resultMetricRow("Severity Index", "Severe Hazard Level"),
                _resultMetricRow("Estimated AQI Impact", "+42 Units AQI Increase"),
                _resultMetricRow("Suggested AI Response", "Dispatch Regional Drone Scan"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _resultMetricRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
  Widget _buildStep3LocationAndSubmit(bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPS Location Card
            const Text(
              "Geographic Incident Location",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mock Satellite Map lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SatelliteMapPainter(scanValue: _scanLine.value),
                      ),
                    ),
                    // Center GPS pulsing location marker
                    AnimatedBuilder(
                      animation: _loopController,
                      builder: (context, child) {
                        final double pulseSize = 14 + 12 * math.sin(_loopController.value * 2 * math.pi * 3);
                        return Container(
                          width: pulseSize,
                          height: pulseSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEF4444).withOpacity(0.2),
                            border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          ),
                        );
                      },
                    ),
                    // GPS Details overlay badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111315).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "📍 Mumbai GPS Active",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            Text(
                              "18.9750° N, 72.8258° E",
                              style: TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildLocationInputField(
                    controller: _landmarkCtrl,
                    label: "Nearby Landmark",
                    hint: "Gateway of India",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLocationInputField(
                    controller: _remarksCtrl,
                    label: "Additional Remarks",
                    hint: "Visible from highway",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Urgency selector & Anonymous reporting
            _buildAdditionalReportSettings(),
            const SizedBox(height: 20),
            // Incident Review Summary Card (Glassmorphism)
            const Text(
              "AI Incident Summary Review",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            _buildAiIncidentSummaryCard(),
            const SizedBox(height: 24),
            // Submit Incident Button with satellite uploading simulation
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: const Color(0xFF111315),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  shadowColor: const Color(0xFF34D399).withOpacity(0.3),
                  elevation: 4,
                ),
                child: _isSubmitting
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111315)),
                    ),
                    SizedBox(width: 12),
                    Text("Uploading Satellite Packets...", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
                    : const Text(
                  "Transmit Incident Report",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  Widget _buildAdditionalReportSettings() {
    final List<String> urgencies = ['Low', 'Medium', 'High', 'Very High'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Incident Urgency Priority",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1D22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Row(
            children: urgencies.map((u) {
              final bool isSel = _urgencyLevel == u;
              Color urgentColor = const Color(0xFFFFC72C);
              if (u == 'High') urgentColor = const Color(0xFFF4B400);
              if (u == 'Very High') urgentColor = const Color(0xFFEF4444);
              if (u == 'Low') urgentColor = const Color(0xFF34D399);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _urgencyLevel = u),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? urgentColor.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? urgentColor.withOpacity(0.3) : Colors.transparent),
                    ),
                    child: Center(
                      child: Text(
                        u,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? urgentColor : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Report Anonymously",
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Switch(
              value: _anonymousReporting,
              activeColor: const Color(0xFFFFC72C),
              activeTrackColor: const Color(0xFFFFC72C).withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.white10,
              onChanged: (v) {
                setState(() {
                  _anonymousReporting = v;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildAiIncidentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _summaryRow("Report Type", _category ?? "Industrial emission"),
          _summaryRow("Location Zone", "Mumbai Region 18A"),
          _summaryRow("Verifying Source", _anonymousReporting ? "Anonymous Cryptography" : widget.citizenName),
          _summaryRow("Severity Priority", _urgencyLevel),
          _summaryRow("Response Agency", "Muncipal Pollution Control Hub"),
          _summaryRow("Predicted Resolution Priority", "Immediate (Level 2 Actionable)"),
          _summaryRow("Estimated Response Time", "5 Minutes Dispatch Plan"),
        ],
      ),
    );
  }
  Widget _summaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
  Widget _buildSuccessScreen(Size size, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Celebrate checkmark
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF34D399).withOpacity(0.12),
              border: Border.all(color: const Color(0xFF34D399), width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF34D399),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Incident Transmitted',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Satellite telemetry packets received at regional municipal control hub.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111315),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _summaryRow("Tracking ID", "AP-2026-00482"),
                _summaryRow("Status Flag", "Under Verification Review"),
                _summaryRow("Estimated Verification", "Under 5 Minutes"),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC72C),
                      foregroundColor: const Color(0xFF111315),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Return Home', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report details shared with community channels.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Share Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildLocationInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF111315),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFC72C), width: 1.5),
        ),
      ),
    );
  }
  InputDecoration _decInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF111315),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFC72C), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
// CUSTOM BACKGROUND PAINTERS
class _IncidentsBackgroundPainter extends CustomPainter {
  final double progress;
  final double scanBeamPos;
  _IncidentsBackgroundPainter({
    required this.progress,
    required this.scanBeamPos,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double w = size.width;
    final double h = size.height;
    // 1. Grid
    paint.color = Colors.white.withOpacity(0.015);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    const double gridSize = 75.0;
    for (double i = 0; i < w; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
    }
    for (double i = 0; i < h; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(w, i), paint);
    }
    // 2. Faint satellite sweep
    final Offset center = Offset(w * 0.5, h * 0.45);
    final double radius = math.min(w, h) * 0.5;
    paint.color = const Color(0xFF38BDF8).withOpacity(0.03);
    canvas.drawCircle(center, radius, paint);
    // 3. Heatmap pulses (mock data points)
    final List<Offset> pulses = [
      Offset(w * 0.2, h * 0.3),
      Offset(w * 0.8, h * 0.2),
      Offset(w * 0.75, h * 0.7),
    ];
    for (int i = 0; i < pulses.length; i++) {
      final double wave = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 3 + i);
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFFEF4444).withOpacity(0.06 * wave);
      canvas.drawCircle(pulses[i], 30 * (1 + wave * 0.4), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _IncidentsBackgroundPainter oldDelegate) => true;
}
class _AiMeshPainter extends CustomPainter {
  final double progress;
  _AiMeshPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC72C).withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // Draw Corner Targeting brackets
    const double padding = 30.0;
    final double rW = size.width - padding * 2;
    final double rH = size.height - padding * 2;
    // TL Corner
    canvas.drawLine(const Offset(padding, padding), const Offset(padding + 20, padding), paint);
    canvas.drawLine(const Offset(padding, padding), const Offset(padding, padding + 20), paint);
    // TR Corner
    canvas.drawLine(Offset(padding + rW, padding), Offset(padding + rW - 20, padding), paint);
    canvas.drawLine(Offset(padding + rW, padding), Offset(padding + rW, padding + 20), paint);
    // BL Corner
    canvas.drawLine(Offset(padding, padding + rH), Offset(padding + 20, padding + rH), paint);
    canvas.drawLine(Offset(padding, padding + rH), Offset(padding, padding + rH - 20), paint);
    // BR Corner
    canvas.drawLine(Offset(padding + rW, padding + rH), Offset(padding + rW - 20, padding + rH), paint);
    canvas.drawLine(Offset(padding + rW, padding + rH), Offset(padding + rW, padding + rH - 20), paint);
    // Draw bounding boxes around simulated center objects
    if (progress > 0.4) {
      paint.color = const Color(0xFFEF4444).withOpacity(0.35);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.45), width: 140, height: 100),
        paint,
      );
      // Label indicator
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFFEF4444).withOpacity(0.7);
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.5 - 70, size.height * 0.45 - 65, 95, 15),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant _AiMeshPainter oldDelegate) => oldDelegate.progress != progress;
}
class _SatelliteMapPainter extends CustomPainter {
  final double scanValue;
  _SatelliteMapPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < h; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(w, i), grid);
    }
    for (double i = 0; i < w; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), grid);
    }
  }
  @override
  bool shouldRepaint(covariant _SatelliteMapPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}
