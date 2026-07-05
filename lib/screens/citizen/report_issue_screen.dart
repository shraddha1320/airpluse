import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
class _ReportIssueScreenState extends State<ReportIssueScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  // Animation controllers
  late final AnimationController _scanController;
  late final AnimationController _loopController;
  late final AnimationController _aiScanController;
  late final PageController _pageController;
  late final Animation<double> _scanLine;
  // Validation keys
  final _formKey1 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  // Input Controllers
  final _descCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  // State variables
  int _step = 0;
  String? _category;
  final ImagePicker _imagePicker = ImagePicker();
  File? _capturedImage;
  bool _isImageConfirmed = false;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  // Permission states
  bool _cameraPermissionGranted = false;
  bool _locationPermissionGranted = false;
  // Tracks which permission the user was sent to Settings for, so it can
  // be re-checked automatically when the app resumes.
  String? _pendingSettingsPermission;
  // AI Scan state variables
  bool _isAiScanning = false;
  double _aiScanProgress = 0.0;
  String _aiScanText = "Initializing scan...";
  Timer? _aiScanTimer;
  bool _isSatelliteLayer = true;
  // Dropdown categories options
  final List<String> _categories = [
    'Smoke Pollution',
    'Garbage Burning',
    'Industrial Emissions',
    'Dust Pollution',
    'Construction Pollution',
    'Vehicle Smoke',
    'Illegal Waste Burning',
    'Other'
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0);
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
    WidgetsBinding.instance.removeObserver(this);
    _scanController.dispose();
    _loopController.dispose();
    _aiScanController.dispose();
    _pageController.dispose();
    _descCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    _landmarkCtrl.dispose();
    _aiScanTimer?.cancel();
    super.dispose();
  }
  // Re-check pending permission when the user returns from device Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingSettingsPermission != null) {
      final String pending = _pendingSettingsPermission!;
      _pendingSettingsPermission = null;
      if (pending == 'camera') {
        _recheckCameraPermission();
      } else if (pending == 'location') {
        _recheckLocationPermission();
      }
    }
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
      if (_capturedImage == null) {
        return "Please capture a live photo to confirm atmospheric data.";
      } else if (!_isImageConfirmed) {
        return "Confirm if this image represents the incident accurately.";
      } else {
        return "Evidence verify complete! This looks severe.";
      }
    }
    return "Confirm the GPS location and add final remarks.";
  }
  String _getAiriExpression() {
    if (_isSuccess) return "happy";
    if (_isAiScanning) return "sleeping";
    if (_step == 1 && _capturedImage != null) return "happy";
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
    if (_step == 1 && (_capturedImage == null || !_isImageConfirmed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture and confirm the photo evidence first.')),
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
      // Auto-trigger location permission and fetch location when entering step 3
      if (_step == 2) {
        _requestLocationPermission();
      }
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
  // ------------------------------------------------------------------
  // REAL CAMERA PERMISSION + CAPTURE (image_picker + permission_handler)
  // ------------------------------------------------------------------
  Future<void> _requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _cameraPermissionGranted = true;
      });
      _openCamera();
    } else {
      _showCameraPermissionRequiredDialog();
    }
  }
  Future<void> _recheckCameraPermission() async {
    final PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _cameraPermissionGranted = true;
      });
      _openCamera();
    }
  }
  void _showCameraPermissionRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1D22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC72C)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Camera Permission Required',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Camera permission is required to report pollution incidents.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pendingSettingsPermission = 'camera';
              openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: Color(0xFFFFC72C))),
          ),
        ],
      ),
    );
  }
  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
          _isImageConfirmed = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access the camera. Please try again.')),
        );
      }
    }
  }
  // ------------------------------------------------------------------
  // REAL LOCATION PERMISSION + GPS + REVERSE GEOCODING
  // (geolocator + geocoding)
  // ------------------------------------------------------------------
  Future<void> _requestLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationPermissionRequiredDialog(serviceDisabled: true);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _fetchLocationCoordinates();
    } else {
      _showLocationPermissionRequiredDialog(serviceDisabled: false);
    }
  }
  Future<void> _recheckLocationPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _fetchLocationCoordinates();
    }
  }
  void _showLocationPermissionRequiredDialog({required bool serviceDisabled}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1D22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_off_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Expanded(
              child: Text('Location Permission', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: const Text(
          'Location permission is required to register a complaint.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Denied: Return user back to Home Screen
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pendingSettingsPermission = 'location';
              if (serviceDisabled) {
                Geolocator.openLocationSettings();
              } else {
                Geolocator.openAppSettings();
              }
            },
            child: const Text('Open Settings', style: TextStyle(color: Color(0xFFFFC72C))),
          ),
        ],
      ),
    );
  }
  Future<void> _fetchLocationCoordinates() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        setState(() {
          _stateCtrl.text = place.administrativeArea ?? '';
          _cityCtrl.text = place.locality?.isNotEmpty == true
              ? place.locality!
              : (place.subAdministrativeArea ?? '');
          _areaCtrl.text = place.subLocality?.isNotEmpty == true
              ? place.subLocality!
              : (place.street ?? '');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to fetch current location. Please try again.')),
        );
      }
    }
  }
  // AI Scanning Simulator Flow
  void _triggerAiScan() {
    setState(() {
      _isImageConfirmed = true;
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
    _aiScanTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
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
          _next(); // Proceed automatically after scan
        }
      });
    });
  }
  void _submit() async {
    if (!_formKey3.currentState!.validate()) return;
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
          'Report Pollution Incident',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // 1. Satellite background scan grid lines
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
          // 2. Main Page Layout PageView
          SafeArea(
            child: Center(
              child: _isSuccess
                  ? _buildSuccessScreen(size, isTablet)
                  : Column(
                children: [
                  _buildStepHeaderIndicator(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: _buildAiriCardSection(),
                  ),
                  const SizedBox(height: 12),
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
    final List<String> steps = ['Details', 'Evidence', 'Submit'];
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
              backgroundColor: Colors.white10,
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
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: ClipOval(
              child: CustomPaint(
                painter: AiriCharacterPainter(expression: _getAiriExpression()),
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
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), letterSpacing: 0.5),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getAiriMessage(),
                    key: ValueKey<String>(_getAiriMessage()),
                    style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // STEP WIDGETS BUILDERS
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
              "Complaint Category",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            // Dropdown selection (Replacing multi-grid cards)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select category...', style: TextStyle(color: Colors.white24, fontSize: 13)),
                  dropdownColor: const Color(0xFF1B1D22),
                  value: _category,
                  items: _categories.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _category = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Description",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLength: 500,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _decInput('Describe the issue in detail...'),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Incident description is required';
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Continue action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_category != null && _descCtrl.text.isNotEmpty) ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC72C),
                  foregroundColor: const Color(0xFF111315),
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                  if (_capturedImage == null) ...[
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
                          child: const Icon(Icons.photo_camera, size: 48, color: Colors.white30),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Awaiting Camera Capture",
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ] else if (_capturedImage != null && !_isImageConfirmed) ...[
                    // Image Preview Screen before continuing (real captured image)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _capturedImage!,
                              height: 140,
                              width: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Captured Evidence Preview",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${_capturedImage!.path.split('/').last} (Captured Successfully)",
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _capturedImage = null),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFEF4444)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text("Retake Photo", style: TextStyle(color: Color(0xFFEF4444))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _triggerAiScan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC72C),
                                    foregroundColor: const Color(0xFF111315),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text("Continue"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else if (_isAiScanning) ...[
                    _buildScanAnimationView(),
                  ] else ...[
                    _buildScanResultView(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Upload Selection Buttons (Camera capture only, gallery removed)
          if (_capturedImage == null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _cameraPermissionGranted ? _openCamera : _requestCameraPermission,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFC72C),
                  side: const BorderSide(color: Color(0xFFFFC72C), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.photo_camera, size: 18),
                label: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 16),
          if (_capturedImage != null && _isImageConfirmed && !_isAiScanning)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC72C),
                  foregroundColor: const Color(0xFF111315),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Proceed to Address Verification', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildScanAnimationView() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _AiMeshPainter(progress: _aiScanProgress),
          ),
        ),
        AnimatedBuilder(
          animation: _aiScanController,
          builder: (context, child) {
            final double sweepY = _aiScanProgress * 280;
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
    final bool canSubmit = _category != null &&
        _descCtrl.text.isNotEmpty &&
        _capturedImage != null &&
        _cameraPermissionGranted &&
        _locationPermissionGranted &&
        _stateCtrl.text.isNotEmpty &&
        _cityCtrl.text.isNotEmpty &&
        _areaCtrl.text.isNotEmpty;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPS Location Card Map Preview
            const Text(
              "Geographic Incident Location",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
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
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SatelliteMapPainter(scanValue: _scanLine.value),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _loopController,
                      builder: (context, child) {
                        final double pulseSize = 14 + 10 * math.sin(_loopController.value * 2 * math.pi * 3);
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Editable Address Form Fields
            const Text(
              "Detected Address",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            _buildAddressField(controller: _stateCtrl, label: "State", hint: "Maharashtra"),
            const SizedBox(height: 12),
            _buildAddressField(controller: _cityCtrl, label: "City", hint: "Mumbai"),
            const SizedBox(height: 12),
            _buildAddressField(controller: _areaCtrl, label: "Area / Locality", hint: "Bandra West"),
            const SizedBox(height: 12),
            _buildAddressField(controller: _landmarkCtrl, label: "Landmark (Optional)", hint: "Near Carter Road", required: false),
            const SizedBox(height: 28),
            // Submit Incident Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (canSubmit && !_isSubmitting) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: const Color(0xFF111315),
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white24,
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
                    Text("Submitting Complaint...", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
                    : const Text(
                  "Submit Complaint",
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
  Widget _buildAddressField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      validator: required
          ? (v) {
        if (v == null || v.isEmpty) return '$label is required';
        return null;
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1B1D22),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFC72C), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
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
            'Complaint Registered Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your complaint has been forwarded to the nearest municipal authority.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.45),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Redirecting to complaint tracking screen...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC72C),
                      foregroundColor: const Color(0xFF111315),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Track Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
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
    if (progress > 0.4) {
      paint.color = const Color(0xFFEF4444).withOpacity(0.35);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.45), width: 140, height: 100),
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