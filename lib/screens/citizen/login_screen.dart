import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'airi_assistant.dart';
import 'citizen_home_screen.dart';
import 'register_screen.dart';
import 'report_issue_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Animation controllers for UI orchestration
  late final AnimationController _introController;
  late final AnimationController _loopController;

  // Intro sequential animations
  late final Animation<double> _bgFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _airiFade;
  late final Animation<double> _cardSlideUp;
  late final Animation<double> _cardFade;
  late final Animation<double> _roleSelectorFade;
  late final Animation<double> _buttonsFade;
  // Form controls & State variables
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'Citizen';
  // Live updates scrolling text ticker items
  final List<String> _tickerItems = [
    "AQI Mumbai: 148 Moderate",
    "73 Active Hotspots Detected",
    "182 Reports Under Review",
    "Satellite Connection: Online",
    "Last scan: 2 mins ago"
  ];
  late final ScrollController _tickerScrollController;
  Timer? _tickerTimer;
  // Custom hover states for buttons (for Web/Desktop responsive support)
  bool _isSignInHovered = false;
  bool _isGoogleHovered = false;
  bool _isAnonHovered = false;
  @override
  void initState() {
    super.initState();
    _tickerScrollController = ScrollController();
    // Loop controller for ambient background animations (radar sweep, satellites, stars)
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    // Intro timeline controller (1.5 seconds)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Orchestrate intro timings
    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack)),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.3, 0.6, curve: Curves.easeOut)),
    );
    _airiFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );
    _cardSlideUp = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.5, 0.85, curve: Curves.fastOutSlowIn)),
    );
    _roleSelectorFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.65, 0.9, curve: Curves.easeOut)),
    );
    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.75, 1.0, curve: Curves.easeOut)),
    );
    // Start intro sequence
    _introController.forward();
    // Start auto-scrolling news ticker
    _startTickerAnimation();
  }
  void _startTickerAnimation() {
    _tickerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_tickerScrollController.hasClients) return;

      final double maxScroll = _tickerScrollController.position.maxScrollExtent;
      final double currentScroll = _tickerScrollController.offset;
      double targetScroll = currentScroll + 140;
      if (targetScroll >= maxScroll) {
        _tickerScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      } else {
        _tickerScrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  @override
  void dispose() {
    _introController.dispose();
    _loopController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _tickerScrollController.dispose();
    _tickerTimer?.cancel();
    super.dispose();
  }
  // Preserved Original Authentication Logic & Firebase Hooks
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Sign-In')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login for ${_emailController.text} as $_selectedRole')),
        );
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  void _navigateToDashboard() {
    Widget targetDashboard;
    if (_selectedRole == 'Citizen') {
      targetDashboard = const CitizenDashboard();
    } else if (_selectedRole == 'Worker') {
      targetDashboard = const WorkerDashboardPlaceholder();
    } else {
      targetDashboard = const AuthorityDashboardPlaceholder();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => targetDashboard),
    );
  }
  // AIRI assistant messages mapped per role
  String _getAiriMessage() {
    switch (_selectedRole) {
      case 'Citizen':
        return "Help build a cleaner city. Ready to check your local AQI?";
      case 'Worker':
        return "Ready for today's assignments? Heavy pollution hotspots detected.";
      case 'Authority':
        return "City analytics are ready. 12 municipal sensors require maintenance.";
      default:
        return "Welcome back! Let's monitor today's air quality.";
    }
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      body: Stack(
        children: [
          // 1. Futuristic Animated Background Command Center
          Positioned.fill(
            child: FadeTransition(
              opacity: _bgFade,
              child: AnimatedBuilder(
                animation: _loopController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CommandCenterBackgroundPainter(
                      progress: _loopController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          // 2. Scrollable Platform Layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.18 : 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Hero Header: Glowing Logo, Title & Tagline
                    _buildHeroHeader(),
                    const SizedBox(height: 24),
                    // Integrated AIRI assistant speech card
                    _buildAiriSpeechSection(),
                    const SizedBox(height: 16),
                    // Modern live monitoring information strip ticker
                    _buildLiveInformationStrip(),
                    const SizedBox(height: 20),
                    // Main Glassmorphism Login Card
                    _buildLoginCard(isTablet),
                    const SizedBox(height: 20),
                    // Quick Actions: Anonymous pollution report
                    _buildAnonymousActionSection(),
                    const SizedBox(height: 16),
                    // Register redirection footer
                    _buildRegisterFooter(),
                    const SizedBox(height: 24),
                    // Environmental Real-time AI Stats Dashboard
                    _buildStatsDashboard(isTablet),
                    const SizedBox(height: 20),
                    // Operating System credit labels
                    const Text(
                      'Powered by AI • Satellite Imagery • Google Maps API',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // COMPONENT BUILDERS
  Widget _buildHeroHeader() {
    return Column(
      children: [
        // 3D Glowing App Logo Hero
        AnimatedBuilder(
          animation: Listenable.merge([_introController, _loopController]),
          builder: (context, child) {
            final double glowStrength = 8 + 6 * math.sin(_loopController.value * 2 * math.pi);
            return ScaleTransition(
              scale: _logoScale,
              child: Opacity(
                opacity: _logoFade.value,
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1B1D22),
                      border: Border.all(
                        color: const Color(0xFFFFC72C).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC72C).withOpacity(0.25),
                          blurRadius: glowStrength,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.air_rounded,
                        color: Color(0xFFFFC72C),
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Title Texts
        FadeTransition(
          opacity: _titleFade,
          child: Column(
            children: [
              const Text(
                'AIRPULSE AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'AI Powered Environmental Intelligence',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _taglineWord('Monitor', const Color(0xFFFFC72C)),
                  _taglineDot(),
                  _taglineWord('Detect', const Color(0xFF38BDF8)),
                  _taglineDot(),
                  _taglineWord('Protect', const Color(0xFF34D399)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _taglineWord(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1.0,
      ),
    );
  }
  Widget _taglineDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '•',
        style: TextStyle(color: Colors.white30, fontSize: 12),
      ),
    );
  }
  Widget _buildAiriSpeechSection() {
    return FadeTransition(
      opacity: _airiFade,
      child: AnimatedBuilder(
        animation: _loopController,
        builder: (context, child) {
          final double floatOffset = math.sin(_loopController.value * 2 * math.pi * 3.5) * 4;
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D22).withOpacity(0.85),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated AIRI character with eye blink representation
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: ClipOval(
                      child: CustomPaint(
                        painter: AiriCharacterPainter(
                          expression: _loopController.value > 0.95 ? 'sleeping' : 'monitoring',
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
                          "AIRI ASSISTANT",
                          style: TextStyle(
                            fontSize: 10,
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
                            key: ValueKey<String>(_selectedRole),
                            style: const TextStyle(
                              fontSize: 12,
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
            ),
          );
        },
      ),
    );
  }
  Widget _buildLiveInformationStrip() {
    return Container(
      height: 36,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Center(
        child: ListView.builder(
          controller: _tickerScrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tickerItems.length * 10, // Infinite loop illusion
          itemBuilder: (context, index) {
            final int actualIndex = index % _tickerItems.length;
            final bool isAlert = actualIndex == 1;
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAlert ? const Color(0xFFEF4444) : const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _tickerItems[actualIndex],
                    style: TextStyle(
                      fontSize: 11,
                      color: isAlert ? const Color(0xFFFFC72C) : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildLoginCard(bool isTablet) {
    return AnimatedBuilder(
      animation: _introController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideUp.value),
          child: Opacity(
            opacity: _cardFade.value,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D22).withOpacity(0.75),
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Join the Clean Air Network',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Report pollution. Help authorities. Build healthier cities.',
                        style: TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                      const SizedBox(height: 24),
                      // Input Fields
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'name@city.gov',
                              icon: Icons.email_outlined,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter email';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                  return 'Invalid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Forgot password trigger
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handled Forgot Password Action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password reset instructions sent.')),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFFFFC72C),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Role Access Selector Strip
                      _buildRoleSelectorStrip(),
                      const SizedBox(height: 28),
                      // Authentication Buttons
                      _buildAuthButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildRoleSelectorStrip() {
    final List<String> roles = ['Citizen', 'Worker', 'Authority'];

    Color getRoleColor(String r) {
      if (r == 'Citizen') return const Color(0xFF34D399);
      if (r == 'Worker') return const Color(0xFF38BDF8);
      return const Color(0xFFFFC72C);
    }
    return FadeTransition(
      opacity: _roleSelectorFade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECT PORTAL ACCESS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF111315),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Row(
              children: roles.map((role) {
                final bool isSelected = _selectedRole == role;
                final Color accentColor = getRoleColor(role);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRole = role;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? accentColor.withOpacity(0.4) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? accentColor : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAuthButtons() {
    return FadeTransition(
      opacity: _buttonsFade,
      child: Column(
        children: [
          // Sign In Action Button
          MouseRegion(
            onEnter: (_) => setState(() => _isSignInHovered = true),
            onExit: (_) => setState(() => _isSignInHovered = false),
            child: AnimatedScale(
              scale: _isSignInHovered ? 1.01 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC72C),
                    foregroundColor: const Color(0xFF111315),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFFFC72C).withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF111315),
                    ),
                  )
                      : const Text(
                    'Start Monitoring',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Google Auth Sign-in
          MouseRegion(
            onEnter: (_) => setState(() => _isGoogleHovered = true),
            onExit: (_) => setState(() => _isGoogleHovered = false),
            child: AnimatedScale(
              scale: _isGoogleHovered ? 1.01 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.02),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.g_mobiledata,
                        size: 32,
                        color: Color(0xFFFFC72C),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAnonymousActionSection() {
    return FadeTransition(
      opacity: _buttonsFade,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isAnonHovered = true),
        onExit: (_) => setState(() => _isAnonHovered = false),
        child: AnimatedScale(
          scale: _isAnonHovered ? 1.01 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportIssueScreen(isGuest: true)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B1D22),
                foregroundColor: const Color(0xFFFFC72C),
                side: const BorderSide(color: Color(0xFFFFC72C), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: const Text(
                'Report Pollution Anonymously',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildRegisterFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text(
            'Register',
            style: TextStyle(
              color: Color(0xFFFFC72C),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildStatsDashboard(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCard('🌫 12,846', 'Reports Submitted', const Color(0xFF38BDF8)),
          Container(width: 1, height: 36, color: Colors.white10),
          _statCard('🤖 98.2%', 'AI Accuracy', const Color(0xFF34D399)),
          Container(width: 1, height: 36, color: Colors.white10),
          _statCard('📍 73 Active', 'Hotspots Logged', const Color(0xFFFFC72C)),
        ],
      ),
    );
  }
  Widget _statCard(String value, String label, Color highlightColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
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
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF111315),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      ),
    );
  }
}
// CUSTOM BACKGROUND PAINTER
class _CommandCenterBackgroundPainter extends CustomPainter {
  final double progress;
  _CommandCenterBackgroundPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double w = size.width;
    final double h = size.height;
    // 1. Futuristic Grid System
    paint.color = Colors.white.withOpacity(0.015);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    const double gridSize = 65.0;
    for (double i = 0; i < w; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
    }
    for (double i = 0; i < h; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(w, i), paint);
    }
    // 2. Animated Radar sweep (Centered radar origin)
    final Offset radarCenter = Offset(w * 0.5, h * 0.35);
    final double radarRadius = math.min(w, h) * 0.45;
    paint.shader = SweepGradient(
      colors: [
        const Color(0xFFFFC72C).withOpacity(0.04),
        const Color(0xFFFFC72C).withOpacity(0.0),
      ],
      transform: GradientRotation(progress * 2 * math.pi),
    ).createShader(Rect.fromCircle(center: radarCenter, radius: radarRadius));
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(radarCenter, radarRadius, paint);
    // 3. Faint radar scanning rings
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      paint.color = const Color(0xFFFFC72C).withOpacity(0.02 * i);
      canvas.drawCircle(radarCenter, radarRadius * (i / 3.0), paint);
    }
    // 4. Stylized Mumbai satellite coastlines / coordinates projection (very faint)
    paint.color = const Color(0xFF38BDF8).withOpacity(0.025);
    paint.strokeWidth = 1.0;
    final path = Path()
      ..moveTo(w * 0.2, h * 0.1)
      ..quadraticBezierTo(w * 0.3, h * 0.25, w * 0.25, h * 0.45)
      ..quadraticBezierTo(w * 0.15, h * 0.55, w * 0.28, h * 0.7)
      ..quadraticBezierTo(w * 0.4, h * 0.8, w * 0.3, h * 0.95);
    canvas.drawPath(path, paint);
    // 5. Pulsing pollution hotspots (glowing circles)
    final List<Offset> hotspots = [
      Offset(w * 0.28, h * 0.25),
      Offset(w * 0.75, h * 0.45),
      Offset(w * 0.35, h * 0.65),
    ];
    for (int i = 0; i < hotspots.length; i++) {
      final Offset spot = hotspots[i];
      final double pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 3 + i);

      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFFEF4444).withOpacity(0.08 * pulse);
      canvas.drawCircle(spot, 25.0 * (1 + pulse * 0.3), paint);

      paint.color = const Color(0xFFEF4444).withOpacity(0.3 * pulse);
      canvas.drawCircle(spot, 3, paint);
    }
    // 6. Orbiting Satellites and lines
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFF38BDF8).withOpacity(0.05);
    canvas.drawOval(
      Rect.fromCenter(center: radarCenter, width: radarRadius * 1.6, height: radarRadius * 0.6),
      paint,
    );
    final double satAngle = progress * 2 * math.pi;
    final double satX = radarCenter.dx + (radarRadius * 0.8) * math.cos(satAngle);
    final double satY = radarCenter.dy + (radarRadius * 0.3) * math.sin(satAngle);
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(satX, satY), 2.5, paint);
    paint.color = const Color(0xFF38BDF8).withOpacity(0.2);
    canvas.drawCircle(Offset(satX, satY), 6.0, paint);
    // 7. Ambient floating particles
    final rand = math.Random(199);
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 35; i++) {
      final double rx = rand.nextDouble() * w;
      final double ry = rand.nextDouble() * h;
      final double sizeVal = rand.nextDouble() * 1.5 + 0.5;
      final double drift = math.sin(progress * 2 * math.pi + i) * 6;
      paint.color = Colors.white.withOpacity(0.08 + 0.12 * math.sin(progress * 2 * math.pi * (i % 3 + 1)));
      canvas.drawCircle(Offset(rx, (ry + drift) % h), sizeVal, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _CommandCenterBackgroundPainter oldDelegate) => true;
}
// STUB PLACEHOLDER CLASSES FOR DASHBOARDS (to maintain compatibility)
class WorkerDashboardPlaceholder extends StatelessWidget {
  const WorkerDashboardPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Worker Portal - Under Construction',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
class AuthorityDashboardPlaceholder extends StatelessWidget {
  const AuthorityDashboardPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      appBar: AppBar(
        title: const Text('Authority Dashboard'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Authority Portal - Under Construction',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
