import  'airi_assistant.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // To reuse AiriGraphicPainter
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _airiController;
  late final PageController _pageController = PageController();
  late final Animation<double> _scanLine;
  late final Animation<double> _airiFloat;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  int _currentPage = 0;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
    _airiController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _airiFloat = Tween<double>(begin: 0.0, end: 5.0).animate(CurvedAnimation(parent: _airiController, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _scanController.dispose();
    _airiController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  String _getAiriMessage() {
    if (_isSuccess) return "Welcome to AirPulse AI!";
    return _currentPage == 0
        ? "Let's build a cleaner Mumbai together."
        : "Your account helps us maintain trusted reports.";
  }
  void _nextPage() {
    if (_formKey1.currentState!.validate()) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = 1);
    }
  }
  Future<void> _handleRegister() async {
    if (!_formKey2.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isSuccess = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFF),
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEEF7F4), Color(0xFFF5FBFF), Color(0xFFEAF4FF)])))),
          Positioned.fill(child: AnimatedBuilder(animation: _scanLine, builder: (c, w) => CustomPaint(painter: _MumbaiMapPainter(scanValue: _scanLine.value)))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: isTablet ? size.width * 0.15 : 20.0, vertical: 16.0),
                child: _isSuccess ? _buildSuccessView() : _buildMainRegisterView(isTablet),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMainRegisterView(bool isTablet) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AIRPULSE ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text('AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
          ],
        ),
        const SizedBox(height: 12),
        // Inline Airi Guide Card
        _buildInlineAiriCard(),
        const SizedBox(height: 16),
        Column(
          children: [
            Text('Step ${_currentPage + 1} of 2', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9), fontSize: 13)),
            const SizedBox(height: 6),
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 2,
                backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 380,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(22.0),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 15)],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_buildPageOne(), _buildPageTwo(isTablet)],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account? ', style: TextStyle(color: Colors.black.withOpacity(0.6))),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Sign In', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
          ],
        ),
      ],
    );
  }
  Widget _buildInlineAiriCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _airiFloat,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _airiFloat.value),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomPaint(painter: AiriCharacterPainter(expression: 'excited')),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Airi • Onboarding Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Color(0xFF0EA5E9))),
                const SizedBox(height: 2),
                Text(
                  _getAiriMessage(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPageOne() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Your Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text('Join thousands of citizens making Mumbai cleaner.', style: TextStyle(fontSize: 11.5, color: Colors.black.withOpacity(0.5))),
          const SizedBox(height: 16),
          _buildField(_nameController, 'Full Name', 'John Doe', Icons.person_outline),
          const SizedBox(height: 12),
          _buildField(_emailController, 'Email Address', 'name@city.gov', Icons.email_outlined, validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email';
            return null;
          }),
          const SizedBox(height: 12),
          _buildField(_phoneController, 'Mobile Number', 'Phone Number', Icons.phone_outlined, type: TextInputType.phone),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  Widget _buildPageTwo(bool isTablet) {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Secure Your Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildField(_passwordController, 'Password', 'Password', Icons.lock_outline_rounded, obscure: _obscurePass, suffix: IconButton(icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.black54), onPressed: () => setState(() => _obscurePass = !_obscurePass)))),
              const SizedBox(width: 8),
              Expanded(child: _buildField(_confirmPasswordController, 'Confirm Password', 'Re-enter', Icons.lock_outline_rounded, obscure: _obscureConfirmPass, suffix: IconButton(icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.black54), onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass)), validator: (v) => v != _passwordController.text ? 'Not match' : null)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildField(_otpController, 'OTP Code', 'OTP Code', Icons.security)),
              const SizedBox(width: 10),
              TextButton(onPressed: () {}, child: const Text('Send OTP', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create AirPulse Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0F172A), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF4285F4)),
              label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 64),
          const SizedBox(height: 16),
          const Text('Account Created Successfully', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Welcome to AirPulse AI', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon, {bool obscure = false, Widget? suffix, TextInputType? type, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black45, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
      ),
    );
  }
}
class _MumbaiMapPainter extends CustomPainter {
  final double scanValue;
  _MumbaiMapPainter({required this.scanValue});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final roadPaint = Paint()..color = Colors.black.withOpacity(0.02)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    for (double i = 0; i < h; i += 90) canvas.drawLine(Offset(0, i), Offset(w, i + 20), roadPaint);
    for (double i = 0; i < w; i += 80) canvas.drawLine(Offset(i, 0), Offset(i + 30, h), roadPaint);
    canvas.drawCircle(Offset(w * 0.2, h * 0.3), 50, Paint()..color = const Color(0xFF10B981).withOpacity(0.04)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    canvas.drawCircle(Offset(w * 0.8, h * 0.15), 70, Paint()..color = const Color(0xFFF59E0B).withOpacity(0.05)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    canvas.drawCircle(Offset(w * 0.45, h * 0.6), 80, Paint()..color = const Color(0xFFEF4444).withOpacity(0.05)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35));
    final sweep = Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF10B981).withOpacity(0.0), const Color(0xFF10B981).withOpacity(0.1), const Color(0xFF10B981).withOpacity(0.0)]).createShader(Rect.fromLTWH(0, h * scanValue - 40, w, 80))..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, h * scanValue - 40, w, 80), sweep);
  }
  @override
  bool shouldRepaint(covariant _MumbaiMapPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}
