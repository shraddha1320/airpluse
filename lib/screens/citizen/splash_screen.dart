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
  // Loop controller for continuous animations (Earth rotation, particles, orbital paths)
  late final AnimationController _loopController;

  // Timeline controller for the 5-second sequenced animation flow
  late final AnimationController _timelineController;
  // Specific timeline animations using Intervals
  late final Animation<double> _earthVisibility;
  late final Animation<double> _logoVisibility;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlide;
  late final Animation<double> _titleWord1Visibility;
  late final Animation<double> _titleWord2Visibility;
  late final Animation<double> _subtitleVisibility;
  late final Animation<double> _scanBeamPosition;
  late final Animation<double> _scanBeamVisibility;
  late final Animation<double> _airiVisibility;
  late final Animation<double> _airiSlide;
  late final Animation<double> _bubbleVisibility;

  // Loading checklist completion states
  final List<String> _checklistItems = [
    "Collecting satellite data",
    "Initializing AI",
    "Connecting sensors",
    "Loading live pollution map",
    "Ready"
  ];

  int _activeChecklistCount = 0;
  Timer? _checklistTimer;
  // Audio cues placeholder structure
  void _triggerSound(String soundType) {
    // Sound Design Hook: Structure timing for future audio integrations
    // e.g., AudioPlayer.play('sounds/$soundType.mp3');
    debugPrint('Audio cue triggered: $soundType');
  }
  @override
  void initState() {
    super.initState();
    // 1. Continuous Loop Controller (e.g. Earth rotating, breathing gradients, drifting dust)
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    // 2. Timeline Controller (Fixed 5-second splash progression)
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    // Timeline configuration (values correspond to 0.0 - 1.0 mapping of 5.0 seconds)

    // 0.5s: Earth appears (Interval: 0.5 / 5.0 = 0.10)
    _earthVisibility = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.10, 0.22, curve: Curves.easeOut),
      ),
    );
    // 1.0s: Logo animation (Interval: 1.0 / 5.0 = 0.20)
    _logoVisibility = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.20, 0.32, curve: Curves.easeIn),
      ),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.20, 0.35, curve: Curves.easeOutBack),
      ),
    );
    _logoSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.20, 0.35, curve: Curves.easeOut),
      ),
    );
    // 1.5s: App Title (Interval: 1.5 / 5.0 = 0.30)
    _titleWord1Visibility = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.30, 0.38, curve: Curves.easeOut),
      ),
    );
    _titleWord2Visibility = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.34, 0.42, curve: Curves.easeOut),
      ),
    );
    _subtitleVisibility = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.40, 0.50, curve: Curves.easeIn),
      ),
    );
    // 2.0s: Scanning beam moves vertically (Interval: 2.0 / 5.0 = 0.40)
    _scanBeamPosition = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.40, 0.65, curve: Curves.easeInOut),
      ),
    );
    _scanBeamVisibility = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.40, 0.65),
      ),
    );
    // 2.5s: AIRI appearance (Interval: 2.5 / 5.0 = 0.50)
    _airiVisibility = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.50, 0.62, curve: Curves.easeOut),
      ),
    );
    _airiSlide = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.50, 0.66, curve: Curves.easeOutBack),
      ),
    );
    _bubbleVisibility = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.58, 0.70, curve: Curves.easeOut),
      ),
    );
    // Schedule audio cues aligned with the screen flow
    _scheduleSoundCues();
    // Start Timeline progress
    _timelineController.forward().then((_) {
      // 5.0s: Automatically navigate to LoginScreen
      _navigateToLogin();
    });
    // 3.0s: Loading checklist ticks one-by-one (Interval: 3.0 / 5.0 = 0.60)
    _startChecklistSequence();
  }
  void _scheduleSoundCues() {
    // 0.5s - Earth reveal swoosh
    Future.delayed(const Duration(milliseconds: 500), () => _triggerSound('earth_reveal'));
    // 1.0s - Premium logo reveal chime / harmonic ping
    Future.delayed(const Duration(milliseconds: 1000), () => _triggerSound('logo_reveal_harmonic'));
    // 2.0s - Futuristic sonar scanning sweeping sound
    Future.delayed(const Duration(milliseconds: 2000), () => _triggerSound('sonar_sweep'));
    // 2.5s - AIRI welcome notification sound
    Future.delayed(const Duration(milliseconds: 2500), () => _triggerSound('airi_notification'));
  }
  void _startChecklistSequence() {
    // Sequence timing: item transitions occurring between 3.0s and 4.5s
    // 5 items to show over 1.5 seconds means a new item every 300ms
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      setState(() => _activeChecklistCount = 1);
      _triggerSound('checklist_tick');

      _checklistTimer = Timer.periodic(const Duration(milliseconds: 320), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _activeChecklistCount++;
          _triggerSound('checklist_tick');
          if (_activeChecklistCount >= _checklistItems.length) {
            timer.cancel();
          }
        });
      });
    });
  }
  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }
  @override
  void dispose() {
    _loopController.dispose();
    _timelineController.dispose();
    _checklistTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTabletOrDesktop = size.width > 600;
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      body: Stack(
        children: [
          // 1. Ambient Background Layer (Particles, Dust, Stars, Breathing Gradients)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _loopController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AmbientBackgroundPainter(
                    progress: _loopController.value,
                  ),
                );
              },
            ),
          ),
          // 2. Main Responsive Content Layout
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top Section: Animated Logo, Title and Tagline
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildLogoAndTitle(),
                              const SizedBox(height: 12),
                              _buildTypewriterSubtitle(),
                            ],
                          ),
                          // Middle Section: Glowing Holographic 3D Earth Animation
                          _buildEarthSection(isTabletOrDesktop),
                          // Bottom Section: AIRI Assistant & Premium Checklist Loading Sequence
                          Column(
                            children: [
                              _buildAiriAssistant(),
                              const SizedBox(height: 32),
                              _buildLoadingChecklist(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  // BUILDER METHODS
  Widget _buildLogoAndTitle() {
    return AnimatedBuilder(
      animation: _timelineController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _logoSlide.value),
          child: Opacity(
            opacity: _logoVisibility.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Animated Logo
                Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1B1D22),
                      border: Border.all(
                        color: const Color(0xFFFFC72C).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC72C).withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.air_rounded,
                        color: Color(0xFFFFC72C),
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Sequential Title Fade-in
                Row(
                  children: [
                    Opacity(
                      opacity: _titleWord1Visibility.value,
                      child: const Text(
                        "AirPulse",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Opacity(
                      opacity: _titleWord2Visibility.value,
                      child: const Text(
                        "AI",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFC72C),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildTypewriterSubtitle() {
    return AnimatedBuilder(
      animation: _timelineController,
      builder: (context, child) {
        return Opacity(
          opacity: _subtitleVisibility.value,
          child: const Text(
            "Breathe Better. Live Better.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              letterSpacing: 2.0,
            ),
          ),
        );
      },
    );
  }
  Widget _buildEarthSection(bool isTabletOrDesktop) {
    final double earthSize = isTabletOrDesktop ? 260 : 200;
    return AnimatedBuilder(
      animation: Listenable.merge([_loopController, _timelineController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _earthVisibility.value,
          child: Opacity(
            opacity: _earthVisibility.value,
            child: SizedBox(
              width: earthSize + 80,
              height: earthSize + 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 3D holographic Earth & Orbiting satellites
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _EarthPainter(
                        rotation: _loopController.value * 2 * math.pi,
                        scanBeamPos: _scanBeamPosition.value,
                        scanBeamOpacity: _scanBeamVisibility.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildAiriAssistant() {
    return AnimatedBuilder(
      animation: _timelineController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _airiSlide.value),
          child: Opacity(
            opacity: _airiVisibility.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Floating AIRI Avatar
                AnimatedBuilder(
                  animation: _loopController,
                  builder: (c, w) {
                    final double floatOffset = math.sin(_loopController.value * 2 * math.pi * 3) * 6;
                    return Transform.translate(
                      offset: Offset(0, floatOffset),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1B1D22),
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withOpacity(0.15),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const ClipOval(
                          child: CustomPaint(
                            painter: AiriSplashPainter(expression: 'monitoring'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Speech Bubble
                Flexible(
                  child: Opacity(
                    opacity: _bubbleVisibility.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B1D22),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.zero,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Welcome back! Monitoring Earth's air quality...",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildLoadingChecklist() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_checklistItems.length, (index) {
          final isShown = _activeChecklistCount > index;
          final isReady = _checklistItems[index] == "Ready";

          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Container(
              height: isShown ? 28.0 : 0.0,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: isShown ? 1.0 : 0.0,
                child: Row(
                  children: [
                    isReady
                        ? const Icon(
                      Icons.offline_bolt_rounded,
                      size: 16,
                      color: Color(0xFF34D399),
                    )
                        : const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF34D399),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _checklistItems[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isReady ? FontWeight.bold : FontWeight.w500,
                        color: isReady ? const Color(0xFF34D399) : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
// CUSTOM PAINTERS
class _AmbientBackgroundPainter extends CustomPainter {
  final double progress;
  _AmbientBackgroundPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // 1. Soft breathing gradients in the background corners
    final centerGlowRect = Rect.fromLTWH(-50, -50, size.width + 100, size.height + 100);
    final double breathingOpacity = 0.05 + 0.03 * math.sin(progress * 2 * math.pi * 2);

    paint.shader = RadialGradient(
      center: Alignment.topLeft,
      colors: [
        const Color(0xFF38BDF8).withOpacity(breathingOpacity),
        Colors.transparent,
      ],
    ).createShader(centerGlowRect);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    paint.shader = RadialGradient(
      center: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFC72C).withOpacity(breathingOpacity * 0.7),
        Colors.transparent,
      ],
    ).createShader(centerGlowRect);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    // 2. Faint radar scanning rings expanding from center
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height) * 0.6;
    for (int i = 0; i < 3; i++) {
      final double ringProgress = (progress + (i / 3.0)) % 1.0;
      final double ringRadius = ringProgress * maxRadius;
      final double ringOpacity = (1.0 - ringProgress) * 0.08;
      paint.shader = null;
      paint.color = const Color(0xFF38BDF8).withOpacity(ringOpacity);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;
      canvas.drawCircle(center, ringRadius, paint);
    }
    // 3. Static and drifting tiny stars/particles
    final rand = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final double x = rand.nextDouble() * size.width;
      final double y = rand.nextDouble() * size.height;
      final double starSize = rand.nextDouble() * 1.5 + 0.5;
      // Parallax / Slow motion drifting
      final double driftSpeed = (rand.nextDouble() * 10 + 5) * (i % 2 == 0 ? 1 : -1);
      final double dx = x + math.sin(progress * 2 * math.pi + i) * driftSpeed;
      final double dy = y + (progress * 15 * (rand.nextDouble() + 0.5)) % size.height;
      // Pulse brightness
      final double starOpacity = 0.2 + 0.6 * math.sin(progress * 2 * math.pi * (rand.nextDouble() * 2 + 1));
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white.withOpacity(starOpacity);
      canvas.drawCircle(Offset(dx % size.width, dy), starSize, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _AmbientBackgroundPainter oldDelegate) => true;
}
class _EarthPainter extends CustomPainter {
  final double rotation;
  final double scanBeamPos;
  final double scanBeamOpacity;
  _EarthPainter({
    required this.rotation,
    required this.scanBeamPos,
    required this.scanBeamOpacity,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final paint = Paint();
    // 1. Atmosphere / Outer Glow
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF38BDF8).withOpacity(0.3),
        const Color(0xFF38BDF8).withOpacity(0.08),
        Colors.transparent,
      ],
      stops: const [0.6, 0.8, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));
    canvas.drawCircle(center, radius * 1.3, paint);
    // 2. Base Sphere Fill
    final sphereRect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        const Color(0xFF1B1D22),
        const Color(0xFF111315),
      ],
    ).createShader(sphereRect);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
    // Clip all features/dots to the Earth's sphere boundary
    canvas.save();
    canvas.clipPath(Path()..addOval(sphereRect));
    // 3. Grid lines (3D spherical effect)
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    // Latitudes (Horizontal lines)
    for (int i = -3; i <= 3; i++) {
      final double latRad = (i * 20) * math.pi / 180;
      final double latHeight = radius * math.sin(latRad);
      final double latWidth = radius * math.cos(latRad);

      paint.color = const Color(0xFF38BDF8).withOpacity(0.08);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + latHeight),
          width: latWidth * 2,
          height: latWidth * 0.2,
        ),
        paint,
      );
    }
    // Longitudes (Rotating Vertical Lines)
    for (int i = 0; i < 6; i++) {
      final double angle = rotation + (i * math.pi / 6);
      final double widthFactor = math.sin(angle);

      paint.color = const Color(0xFF38BDF8).withOpacity(0.08);
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * widthFactor.abs(),
          height: radius * 2,
        ),
        paint,
      );
    }
    // 4. Stylized holographic continental landmass dots (3D Rotation Projection)
    final rand = math.Random(101);
    final int gridPointsCount = 280;
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < gridPointsCount; i++) {
      // Semi-random spherical mapping representing geographic layout
      final double phi = (rand.nextDouble() * 160 - 80) * math.pi / 180; // Latitude
      final double lambda = (rand.nextDouble() * 360 - 180) * math.pi / 180; // Longitude
      // Add rotation to longitude
      final double rotatedLambda = lambda + rotation * 0.3;
      // 3D Cartesian coordinates
      final double z = radius * math.cos(phi) * math.cos(rotatedLambda);
      // Only paint dots on the facing side of the sphere
      if (z > 0) {
        final double x = center.dx + radius * math.cos(phi) * math.sin(rotatedLambda);
        final double y = center.dy + radius * math.sin(phi);
        // Define hotspots (specific coordinates glowing differently)
        final bool isHotspot = (i % 25 == 0);
        final double dotSize = isHotspot ? 2.5 : 1.2;
        // Is the scan beam touching this dot?
        final double beamY = center.dy - radius + (radius * 2 * scanBeamPos);
        final double distToBeam = (y - beamY).abs();
        final bool beamIntersects = distToBeam < 15;
        if (isHotspot) {
          final double pulse = 0.5 + 0.5 * math.sin(rotation * 5 + i);
          paint.color = beamIntersects
              ? const Color(0xFFFFC72C)
              : const Color(0xFF34D399).withOpacity(0.4 + 0.6 * pulse);
          canvas.drawCircle(Offset(x, y), dotSize, paint);
          // Draw radar pulse rings around hotspots
          if (pulse > 0.6) {
            paint.style = PaintingStyle.stroke;
            paint.strokeWidth = 0.5;
            paint.color = const Color(0xFF34D399).withOpacity(1.0 - pulse);
            canvas.drawCircle(Offset(x, y), dotSize * (1.0 + pulse * 4), paint);
            paint.style = PaintingStyle.fill;
          }
        } else {
          paint.color = beamIntersects
              ? const Color(0xFFFFC72C).withOpacity(0.9)
              : const Color(0xFF38BDF8).withOpacity(0.4);
          canvas.drawCircle(Offset(x, y), dotSize, paint);
        }
      }
    }
    // Restore context to remove clipping boundary
    canvas.restore();
    // 5. Orbiting Satellites
    final double satelliteAngle = rotation * 0.8;
    final double orbitRx = radius * 1.5;
    final double orbitRy = radius * 0.45;
    // Draw Orbit Path Lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.7;
    paint.color = const Color(0xFF38BDF8).withOpacity(0.12);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: orbitRx * 2, height: orbitRy * 2),
      paint,
    );
    // Draw Orbiting Satellites (using trigonometric coordinates)
    for (int s = 0; s < 2; s++) {
      final double angleOffset = s * math.pi;
      final double currentAngle = satelliteAngle + angleOffset;

      final double satX = center.dx + orbitRx * math.cos(currentAngle);
      final double satY = center.dy + orbitRy * math.sin(currentAngle);
      // Simple depth representation: draw orbit line or cover based on position
      final bool isBehind = math.sin(currentAngle) < 0;
      if (!isBehind) {
        // Satellite core
        paint.style = PaintingStyle.fill;
        paint.color = const Color(0xFFFFC72C);
        canvas.drawCircle(Offset(satX, satY), 3.5, paint);
        // Satellite wings / solar panels
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;
        paint.color = const Color(0xFF38BDF8);
        canvas.drawLine(Offset(satX - 6, satY), Offset(satX + 6, satY), paint);
        // Signal halo
        paint.color = const Color(0xFFFFC72C).withOpacity(0.25);
        canvas.drawCircle(Offset(satX, satY), 8.0, paint);
      }
    }
    // 6. Vertical AI Scan Beam Line
    if (scanBeamOpacity > 0.0) {
      final double beamY = center.dy - radius + (radius * 2 * scanBeamPos);
      final double beamWidth = math.sqrt(math.max(0.0, radius * radius - math.pow(beamY - center.dy, 2))) * 2;

      if (beamWidth > 0) {
        paint.style = PaintingStyle.fill;
        paint.shader = LinearGradient(
          colors: [
            const Color(0xFFFFC72C).withOpacity(0.0),
            const Color(0xFFFFC72C).withOpacity(0.8 * scanBeamOpacity),
            const Color(0xFFFFC72C).withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromLTWH(center.dx - beamWidth / 2, beamY - 4, beamWidth, 8),
        );
        canvas.drawRect(
          Rect.fromLTWH(center.dx - beamWidth / 2, beamY - 4, beamWidth, 8),
          paint,
        );
      }
    }
  }
  @override
  bool shouldRepaint(covariant _EarthPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.scanBeamPos != scanBeamPos ||
        oldDelegate.scanBeamOpacity != scanBeamOpacity;
  }
}
class AiriSplashPainter extends CustomPainter {
  final String expression;
  const AiriSplashPainter({required this.expression});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    // Outer Glow / Atmosphere boundary
    canvas.drawCircle(
      center,
      r * 0.95,
      Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.12)
        ..style = PaintingStyle.fill,
    );
    // Body (Capsule/Sphere)
    canvas.drawCircle(
      center,
      r * 0.78,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    // Stroke Border
    canvas.drawCircle(
      center,
      r * 0.78,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF34D399)],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    // Outfit details (lower sector segment)
    final pathOutfit = Path()
      ..moveTo(center.dx - r * 0.7, center.dy + r * 0.35)
      ..arcTo(Rect.fromCircle(center: center, radius: r * 0.78), 0.5, 2.14, false)
      ..close();
    canvas.drawPath(
      pathOutfit,
      Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
    // Antenna on top
    final antennaPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    final antennaPath = Path()
      ..moveTo(center.dx, center.dy - r * 0.78)
      ..quadraticBezierTo(center.dx + r * 0.25, center.dy - r * 1.1, center.dx, center.dy - r * 1.25)
      ..quadraticBezierTo(center.dx - r * 0.25, center.dy - r * 1.1, center.dx, center.dy - r * 0.78);
    canvas.drawPath(antennaPath, antennaPaint);
    // Glowing dot on top of antenna
    canvas.drawCircle(
      Offset(center.dx, center.dy - r * 1.25),
      2.5,
      Paint()..color = const Color(0xFF34D399)..style = PaintingStyle.fill,
    );
    // Happy AI Eyes (Curved lines representing scanning/analyzing expression)
    final eyePaint = Paint()
      ..color = const Color(0xFF111315)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx - r * 0.26, center.dy - r * 0.05),
        width: r * 0.22,
        height: r * 0.12,
      ),
      math.pi,
      math.pi,
      false,
      eyePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx + r * 0.26, center.dy - r * 0.05),
        width: r * 0.22,
        height: r * 0.12,
      ),
      math.pi,
      math.pi,
      false,
      eyePaint,
    );
    // Smiling mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF111315)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r * 0.15),
        width: r * 0.16,
        height: r * 0.08,
      ),
      0,
      math.pi,
      false,
      mouthPaint,
    );
  }
  @override
  bool shouldRepaint(covariant AiriSplashPainter oldDelegate) =>
      oldDelegate.expression != expression;
}
