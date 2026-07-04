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
  late final AnimationController _animController;
  late final AnimationController _scanController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scanLine;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  // Role Selection State
  String _selectedRole = 'Citizen';
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
    _animController.forward();
  }
  @override
  void dispose() {
    _animController.dispose();
    _scanController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFF),
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
              animation: _scanLine,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MumbaiMapPainter(scanValue: _scanLine.value),
                );
              },
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? size.width * 0.15 : 20.0, vertical: 16.0),
                    child: Column(
                      children: [
                        // Top Branding
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF0EA5E9)]),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.2),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.satellite_alt_rounded, color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'AIRPULSE AI',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1.0),
                        ),
                        const Text(
                          'Monitor. Detect. Protect.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9), letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 20),
                        // Reusable Airi Card
                        const AiriCard(
                          title: 'Airi • Assistant',
                          message: 'Welcome back! Let\'s monitor Mumbai\'s air quality.',
                          expression: 'happy',
                        ),
                        const SizedBox(height: 16),
                        // Location Card
                        _buildLocationCard(),
                        const SizedBox(height: 16),
                        // Login Form Card
                        Container(
                          padding: EdgeInsets.all(isTablet ? 36.0 : 20.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(22.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Join the Clean Air Network',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Report pollution. Help authorities. Build healthier cities.',
                                style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5)),
                              ),
                              const SizedBox(height: 20),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildField(
                                      _emailController,
                                      'Email Address',
                                      'name@city.gov',
                                      Icons.email_outlined,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Enter email';
                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    _buildField(
                                      _passwordController,
                                      'Password',
                                      'Password',
                                      Icons.lock_outline_rounded,
                                      obscure: _obscurePassword,
                                      suffix: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Colors.black54,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Material 3 SegmentedButton for Role Access Selector
                              const Text(
                                'Select Portal Access:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: SegmentedButton<String>(
                                  segments: const <ButtonSegment<String>>[
                                    ButtonSegment<String>(
                                      value: 'Citizen',
                                      label: Text('Citizen'),
                                      icon: Icon(Icons.person_outline, size: 16),
                                    ),
                                    ButtonSegment<String>(
                                      value: 'Worker',
                                      label: Text('Worker'),
                                      icon: Icon(Icons.engineering_outlined, size: 16),
                                    ),
                                    ButtonSegment<String>(
                                      value: 'Authority',
                                      label: Text('Authority'),
                                      icon: Icon(Icons.gavel_outlined, size: 16),
                                    ),
                                  ],
                                  selected: <String>{_selectedRole},
                                  onSelectionChanged: (Set<String> newSelection) {
                                    setState(() {
                                      _selectedRole = newSelection.first;
                                    });
                                  },
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: const Color(0xFF10B981),
                                    selectedForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Start Monitoring Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleEmailLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                      : const Text('Start Monitoring', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFF4285F4)),
                                  label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Anonymous Trigger
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ReportIssueScreen(isGuest: true)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              foregroundColor: const Color(0xFF0EA5E9),
                              side: const BorderSide(color: Color(0xFF0EA5E9)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.photo_camera_outlined, size: 18),
                            label: const Text('Report Pollution Anonymously', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: TextStyle(color: Colors.black.withOpacity(0.6))),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: const Text('Register', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStats(isTablet),
                        const SizedBox(height: 16),
                        Text(
                          'Powered by AI • Satellite Imagery • Google Maps',
                          style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 16),
                  SizedBox(width: 4),
                  Text('Mumbai, Maharashtra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                ],
              ),
              SizedBox(height: 2),
              Text('Last satellite scan: 2 minutes ago', style: TextStyle(color: Colors.black54, fontSize: 10.5)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                child: const Text('AQI 148 • Moderate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
              ),
              const SizedBox(height: 2),
              const Text('🛰 Live Monitoring', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 9.5)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStats(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('🌫 12,846', 'Reports Submitted'),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          _stat('🤖 98.2%', 'AI Accuracy'),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          _stat('📍 73 Active', 'Hotspots'),
        ],
      ),
    );
  }
  Widget _stat(String v, String l) {
    return Expanded(
      child: Column(
        children: [
          Text(v, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 12)),
          const SizedBox(height: 2),
          Text(l, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  Widget _buildField(
      TextEditingController ctrl,
      String label,
      String hint,
      IconData icon, {
        bool obscure = false,
        Widget? suffix,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black45),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
      ),
    );
  }
}
class _MumbaiMapPainter extends CustomPainter {
  final double scanValue;
  _MumbaiMapPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final roadPaint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (double i = 0; i < h; i += 80) {
      canvas.drawLine(Offset(0, i), Offset(w, i + 20), roadPaint);
    }
    for (double i = 0; i < w; i += 70) {
      canvas.drawLine(Offset(i, 0), Offset(i + 30, h), roadPaint);
    }
    final green = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.05)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(Offset(w * 0.25, h * 0.4), 60, green);
    final sweep = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF10B981).withOpacity(0.0),
          const Color(0xFF10B981).withOpacity(0.1),
          const Color(0xFF10B981).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, h * scanValue - 40, w, 80))
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, h * scanValue - 40, w, 80), sweep);
  }
  @override
  bool shouldRepaint(covariant _MumbaiMapPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}
class WorkerDashboardPlaceholder extends StatelessWidget {
  const WorkerDashboardPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Dashboard')),
      body: const Center(child: Text('Worker Portal - Under Construction')),
    );
  }
}
class AuthorityDashboardPlaceholder extends StatelessWidget {
  const AuthorityDashboardPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authority Dashboard')),
      body: const Center(child: Text('Authority Portal - Under Construction')),
    );
  }
}
