import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'citizen_dashboard.dart';
import 'register_screen.dart';
import 'report_issue_screen.dart';
import 'package:airpluse/screens/authority/admin_dashboard.dart';
import 'package:airpluse/screens/worker/worker_dashboard.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Loop controller for floating logo and pulse glow
  late final AnimationController _loopController;
  // Form controls & State variables
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'Citizen';
  // Live validation states
  bool _isEmailValid = false;
  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasAtSymbol = false;
  bool _isLoginHovered = false;
  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }
  void _validateEmail() {
    final email = _emailController.text;
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (isValid != _isEmailValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }
  void _validatePassword() {
    final val = _passwordController.text;
    setState(() {
      _hasLength = val.length >= 8 && val.length <= 16;
      _hasUppercase = val.contains(RegExp(r'[A-Z]'));
      _hasNumber = val.contains(RegExp(r'[0-9]'));
      _hasAtSymbol = val.contains('@');
    });
  }
  @override
  void dispose() {
    _loopController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  // Preserved Original Authentication Logic & Navigation
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasLength || !_hasUppercase || !_hasNumber || !_hasAtSymbol) return;
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
      targetDashboard = const WorkerDashboard();
    } else {
      targetDashboard = const AdminDashboard();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => targetDashboard),
    );
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double heroHeight = screenHeight * 0.42; // Hero height increased to 42%
    final double logoSize = heroHeight * 0.32 > 80 ? 80 : heroHeight * 0.32;
    final bool isPasswordValid = _hasLength && _hasUppercase && _hasNumber && _hasAtSymbol;
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // 1. TOP HERO SECTION: Skyline image, black gradient, bottom-aligned logo
            SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  // Zooming skyline background
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1.0, end: 1.05),
                      duration: const Duration(seconds: 4),
                      curve: Curves.easeOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/a5e6b846978f0e3dae0f5a74426e680e.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: const Color(0xFF1B1D22));
                        },
                      ),
                    ),
                  ),
                  // Black vertical gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.65),
                            const Color(0xFF111315),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Logo sits lower inside the hero image (bottom-aligned)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Floating Logo with yellow glow (Same as Splash screen)
                          AnimatedBuilder(
                            animation: _loopController,
                            builder: (context, child) {
                              final double float = math.sin(_loopController.value * math.pi) * 5;
                              final double glowRadius = 14 + 8 * math.sin(_loopController.value * math.pi);
                              return Transform.translate(
                                offset: Offset(0, float - 2),
                                child: Container(
                                  width: logoSize,
                                  height: logoSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFC72C).withOpacity(0.3),
                                        blurRadius: glowRadius,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.flash_on_rounded,
                                      color: Color(0xFF111315),
                                      size: 38,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "AirPulse AI",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Together, We Breathe Cleaner Air",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 2. MAIN WORKSPACE CONTENT: Role selection, Login form card, registration details
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            8,
          ),
              child: Column(
                children: [
                  // Role Access selector
                  _buildRoleSelectorStrip(),
                  const SizedBox(height: 20),
                  // Login card container
                  _buildLoginCard(isPasswordValid),
                  const SizedBox(height: 20),
                  // Register links (Show register only when Citizen is selected)
                  if (_selectedRole == 'Citizen') ...[
                    _buildRegisterFooter(),
                    const SizedBox(height: 10),
                  ],
                  // Advisory Notice Card
                  _buildAdvisoryNoticeCard(),
                  const SizedBox(height: 24),
                  // Why AirPulse stats cards
                  _buildWhyAirPulseSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRoleSelectorStrip() {
    final List<String> roles = ['Citizen', 'Worker', 'Authority'];

    IconData getRoleIcon(String r) {
      if (r == 'Citizen') return Icons.person_outline_rounded;
      if (r == 'Worker') return Icons.engineering_outlined;
      return Icons.shield_outlined;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PORTAL ACCESS ROLE",
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: roles.map((role) {
            final bool isSelected = _selectedRole == role;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = role;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFC72C) : const Color(0xFF1B1D22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFC72C) : Colors.white.withOpacity(0.04),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        getRoleIcon(role),
                        color: isSelected ? const Color(0xFF111315) : const Color(0xFFFFC72C),
                        size: 20,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF111315) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  Widget _buildLoginCard(bool isPasswordValid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22).withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  controller: _emailController,
                  label: "Email Address",
                  hint: "name@city.gov",
                  icon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email address';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "••••••••",
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white54,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (!_hasLength || !_hasUppercase || !_hasNumber || !_hasAtSymbol) {
                      return 'Password must satisfy all complexity rules.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Password Checklist Indicators
                _buildPasswordChecklistPanel(),
                const SizedBox(height: 14),
                // OTP verification fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildField(
                        controller: _otpController,
                        label: "One-Time OTP",
                        hint: "6-Digits",
                        icon: Icons.shield_outlined,
                        type: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (v) => null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isEmailValid
                              ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP sent to email.')),
                            );
                          }
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isEmailValid ? const Color(0xFFFFC72C) : Colors.white10,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            "Send OTP",
                            style: TextStyle(
                              color: _isEmailValid ? const Color(0xFFFFC72C) : Colors.white24,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Large login button with scale animation on tap
                MouseRegion(
                  onEnter: (_) => setState(() => _isLoginHovered = true),
                  onExit: (_) => setState(() => _isLoginHovered = false),
                  child: AnimatedScale(
                    scale: _isLoginHovered ? 1.01 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            _handleEmailLogin();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC72C),
                          foregroundColor: const Color(0xFF111315),
                          disabledBackgroundColor: Colors.white10,
                          disabledForegroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          shadowColor: const Color(0xFFFFC72C).withOpacity(0.35),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111315)),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Login to AirPulse", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPasswordChecklistPanel() {
    final String text = _passwordController.text;
    final bool isPasswordValid = _hasLength && _hasUppercase && _hasNumber && _hasAtSymbol;

    if (text.isEmpty || isPasswordValid) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _checklistIndicator(_hasLength, "8–16 Characters"),
          _checklistIndicator(_hasUppercase, "One Uppercase"),
          _checklistIndicator(_hasNumber, "One Number"),
          _checklistIndicator(_hasAtSymbol, "One @ Symbol"),
        ],
      ),
    );
  }
  Widget _checklistIndicator(bool satisfied, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            satisfied ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: satisfied ? const Color(0xFF34D399) : const Color(0xFFEF4444),
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: satisfied ? Colors.white70 : Colors.white24,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRegisterFooter() {
    return Column(
      children: [
        Row(
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
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
            );
          },
          icon: const Icon(Icons.report_problem_outlined, color: Color(0xFFFFC72C), size: 16),
          label: const Text(
            "Report Anonymously",
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
  Widget _buildAdvisoryNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFFFC72C), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Direct registration is available only for Citizens.",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                SizedBox(height: 2),
                Text(
                  "Worker and Authority accounts are created by the administrator.",
                  style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildWhyAirPulseSection() {
    return Row(
      children: [
        Expanded(
          child: _featureCard(
            title: "AI Verification",
            desc: "98% satellite verification accuracy index.",
            icon: Icons.verified_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _featureCard(
            title: "ML Heatmaps",
            desc: "Predictive atmospheric pollution modeling.",
            icon: Icons.map_rounded,
          ),
        ),
      ],
    );
  }
  Widget _featureCard({required String title, required String desc, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFC72C), size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Colors.white30, fontSize: 10, height: 1.3)),
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
    TextInputType? type,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white54, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF111315),
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
}
