import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'airi_assistant.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _scanController;
  late final AnimationController _loopController;
  late final PageController _pageController = PageController();
  late final Animation<double> _scanLine;
  // Validation keys
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>(); // Used for step 3 final validation
  final _formKeyAddress = GlobalKey<FormState>(); // Helper for step 2 address validation
  // Preserved original controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController(); // Preserved
  // Additional controllers for Address Step
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _pinController = TextEditingController();
  final _addressController = TextEditingController();
  // Registration step & state tracking
  int _currentPage = 0;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  // Additional Step 1 states
  String _selectedGender = 'Male';
  DateTime? _selectedDob;
  // Auto location detection state
  bool _isLocating = false;
  // Checklist acceptance states
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
    _loopController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }
  @override
  void dispose() {
    _scanController.dispose();
    _loopController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();

    _stateController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _pinController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  String _getAiriMessage() {
    if (_isSuccess) return "Welcome to the Clean Air Network!";
    if (_currentPage == 0) return "Let's start with your basic information.";
    if (_currentPage == 1) return "Almost done! Help us verify your account.";
    return "You're ready to join the Clean Air Network.";
  }
  String _getAiriExpression() {
    if (_isSuccess) return "happy";
    if (_currentPage == 0) return "excited";
    if (_currentPage == 1) return "monitoring";
    return "happy";
  }
  // Multi-step Navigation Actions
  void _nextPage() {
    if (_currentPage == 0) {
      if (_formKey1.currentState!.validate()) {
        _pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
        setState(() => _currentPage = 1);
      }
    } else if (_currentPage == 1) {
      if (_formKeyAddress.currentState!.validate()) {
        _pageController.animateToPage(2, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
        setState(() => _currentPage = 2);
      }
    }
  }
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(_currentPage - 1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentPage = _currentPage - 1);
    }
  }
  // Preserved Original Registration Auth Logic
  Future<void> _handleRegister() async {
    if (!_formKey2.currentState!.validate()) return;
    if (!_acceptTerms || !_acceptPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Privacy Policy to continue.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isSuccess = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // Mock Auto Location Detector
  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _stateController.text = "Maharashtra";
        _cityController.text = "Mumbai";
        _areaController.text = "Bandra West";
        _pinController.text = "400050";
        _addressController.text = "Carter Road Promenade";
        _isLocating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS coordinates synchronized successfully.')),
      );
    }
  }
  // Helper for Password Strength
  double _getPasswordStrength() {
    final String p = _passwordController.text;
    if (p.isEmpty) return 0.0;
    double score = 0.0;
    if (p.length >= 8) score += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.25;
    return score;
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      body: Stack(
        children: [
          // 1. Animated Command Center Grid Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _loopController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CommandBackgroundPainter(
                    progress: _loopController.value,
                  ),
                );
              },
            ),
          ),
          // 2. Platform Form Container
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.18 : 20.0,
                  vertical: 24.0,
                ),
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
        // App Logo & Header Section
        _buildHeader(),
        const SizedBox(height: 24),
        // Glass assistant speech card
        _buildAiriSection(),
        const SizedBox(height: 20),
        // Premium Step Progress Indicator
        _buildProgressIndicator(),
        const SizedBox(height: 24),
        // Multi-Step Form Card
        Container(
          constraints: const BoxConstraints(minHeight: 460),
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
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: _currentPage == 1 ? 520 : 440,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStepOnePersonal(),
                      _buildStepTwoAddress(),
                      _buildStepThreeSecurity(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Sign In Redirection Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: Color(0xFFFFC72C),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 60,
            height: 60,
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
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.air_rounded,
                color: Color(0xFFFFC72C),
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Create Your Account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Join thousands of citizens helping build cleaner cities through AI-powered environmental monitoring.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
  Widget _buildAiriSection() {
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
                  "AIRI • ASSISTANT",
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
                    key: ValueKey<int>(_currentPage),
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
    );
  }
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isActive = _currentPage >= index;
        final bool isCurrent = _currentPage == index;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFFFFC72C) : const Color(0xFF1B1D22),
                border: Border.all(
                  color: isCurrent ? const Color(0xFFFFC72C) : Colors.white10,
                  width: 1.5,
                ),
                boxShadow: isCurrent
                    ? [
                  BoxShadow(
                    color: const Color(0xFFFFC72C).withOpacity(0.3),
                    blurRadius: 8,
                  )
                ]
                    : null,
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF111315) : Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            if (index < 2)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 3,
                color: _currentPage > index ? const Color(0xFFFFC72C) : Colors.white10,
              ),
          ],
        );
      }),
    );
  }
  // STEP WIDGETS
  Widget _buildStepOnePersonal() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 1: Personal Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _nameController,
            label: "Full Name",
            hint: "John Doe",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _emailController,
            label: "Email Address",
            hint: "john@airpulse.ai",
            icon: Icons.email_outlined,
            type: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Invalid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _phoneController,
            label: "Phone Number",
            hint: "+91 98765 43210",
            icon: Icons.phone_outlined,
            type: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          // Row for Date of Birth & Gender Selector
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFFFC72C),
                              onPrimary: Color(0xFF111315),
                              surface: Color(0xFF1B1D22),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() => _selectedDob = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111315),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: Colors.white54, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDob == null
                              ? "Date of Birth"
                              : "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}",
                          style: TextStyle(
                            color: _selectedDob == null ? Colors.white24 : Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111315),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xFF1B1D22),
                      value: _selectedGender,
                      items: <String>['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => _selectedGender = newValue);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 140,
              height: 46,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC72C),
                  foregroundColor: const Color(0xFF111315),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Next Step", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStepTwoAddress() {
    return Form(
      key: _formKeyAddress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Step 2: Verification Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              // Auto Detect Location
              GestureDetector(
                onTap: _isLocating ? null : _detectLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      _isLocating
                          ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Color(0xFF38BDF8),
                        ),
                      )
                          : const Icon(Icons.my_location_rounded, color: Color(0xFF38BDF8), size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        "Auto Detect",
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _stateController,
                  label: "State",
                  hint: "Maharashtra",
                  icon: Icons.map_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _cityController,
                  label: "City",
                  hint: "Mumbai",
                  icon: Icons.location_city_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _areaController,
                  label: "Area / Suburb",
                  hint: "Bandra West",
                  icon: Icons.explore_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _pinController,
                  label: "PIN Code",
                  hint: "400050",
                  icon: Icons.pin_drop_outlined,
                  type: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _addressController,
            label: "Residential Address",
            hint: "Apt No, Building name, Street",
            icon: Icons.home_work_outlined,
          ),
          const SizedBox(height: 14),
          // Interactive visual map card placeholder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111315),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B1D22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.satellite_alt_rounded, color: Color(0xFF34D399), size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Satellite Mapping Coverage Active",
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "Mumbai AQI regional metrics fully covered.",
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white70),
                label: const Text("Back", style: TextStyle(color: Colors.white70)),
              ),
              SizedBox(
                width: 140,
                height: 46,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC72C),
                    foregroundColor: const Color(0xFF111315),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Next Step", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStepThreeSecurity() {
    final double strength = _getPasswordStrength();
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 3: Account Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _passwordController,
            label: "Password",
            hint: "••••••••",
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffix: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
          const SizedBox(height: 10),
          // Password Strength Bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    strength <= 0.25
                        ? const Color(0xFFEF4444)
                        : strength <= 0.75
                        ? const Color(0xFFF4B400)
                        : const Color(0xFF34D399),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strength <= 0.25
                    ? "Weak"
                    : strength <= 0.75
                    ? "Fair"
                    : "Strong",
                style: TextStyle(
                  color: strength <= 0.25
                      ? const Color(0xFFEF4444)
                      : strength <= 0.75
                      ? const Color(0xFFF4B400)
                      : const Color(0xFF34D399),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _confirmPasswordController,
            label: "Confirm Password",
            hint: "••••••••",
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirmPass,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Terms & Conditions checkboxes
          _buildCheckboxRow(
            value: _acceptTerms,
            label: "I agree to the Terms & Conditions of AirPulse AI",
            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
          ),
          _buildCheckboxRow(
            value: _acceptPrivacy,
            label: "I agree to the Privacy and Data Encryption Policy",
            onChanged: (v) => setState(() => _acceptPrivacy = v ?? false),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white70),
                label: const Text("Back", style: TextStyle(color: Colors.white70)),
              ),
              SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    foregroundColor: const Color(0xFF111315),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: const Color(0xFF34D399).withOpacity(0.3),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111315)),
                  )
                      : const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildCheckboxRow({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFFFFC72C),
            checkColor: const Color(0xFF111315),
            side: const BorderSide(color: Colors.white30, width: 1.5),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ),
      ],
    );
  }
  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Celebrating AIRI Character
          SizedBox(
            width: 80,
            height: 80,
            child: ClipOval(
              child: CustomPaint(
                painter: AiriCharacterPainter(expression: 'happy'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Glowing Success Checkmark Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF34D399).withOpacity(0.15),
              border: Border.all(color: const Color(0xFF34D399), width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF34D399),
              size: 42,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Account Verified!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to the Clean Air Network. Your regional mapping feeds are now synchronized.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 32),
          // Return to Login Navigation Trigger
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC72C),
                foregroundColor: const Color(0xFF111315),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: const Color(0xFFFFC72C).withOpacity(0.3),
              ),
              child: const Text(
                'Go to Login',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
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
class _CommandBackgroundPainter extends CustomPainter {
  final double progress;
  _CommandBackgroundPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double w = size.width;
    final double h = size.height;
    // 1. Grid lines
    paint.color = Colors.white.withOpacity(0.012);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    const double gridSize = 70.0;
    for (double i = 0; i < w; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
    }
    for (double i = 0; i < h; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(w, i), paint);
    }
    // 2. Center Origin Radar Sweep
    final Offset radarCenter = Offset(w * 0.5, h * 0.4);
    final double radarRadius = math.min(w, h) * 0.5;
    paint.shader = SweepGradient(
      colors: [
        const Color(0xFFFFC72C).withOpacity(0.035),
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
      paint.color = const Color(0xFFFFC72C).withOpacity(0.015 * i);
      canvas.drawCircle(radarCenter, radarRadius * (i / 3.0), paint);
    }
    // 4. Orbiting satellite paths
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFF38BDF8).withOpacity(0.04);
    canvas.drawOval(
      Rect.fromCenter(center: radarCenter, width: radarRadius * 1.5, height: radarRadius * 0.55),
      paint,
    );
    final double satAngle = progress * 2 * math.pi * 0.9;
    final double satX = radarCenter.dx + (radarRadius * 0.75) * math.cos(satAngle);
    final double satY = radarCenter.dy + (radarRadius * 0.275) * math.sin(satAngle);
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(satX, satY), 2.5, paint);
    paint.color = const Color(0xFF38BDF8).withOpacity(0.25);
    canvas.drawCircle(Offset(satX, satY), 6.0, paint);
    // 5. Pulsing pollution hotspots
    final List<Offset> hotspots = [
      Offset(w * 0.3, h * 0.2),
      Offset(w * 0.7, h * 0.6),
    ];
    for (int i = 0; i < hotspots.length; i++) {
      final Offset spot = hotspots[i];
      final double pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 4 + i);

      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFFEF4444).withOpacity(0.08 * pulse);
      canvas.drawCircle(spot, 20.0 * (1 + pulse * 0.3), paint);

      paint.color = const Color(0xFFEF4444).withOpacity(0.3 * pulse);
      canvas.drawCircle(spot, 2.5, paint);
    }
    // 6. Floating micro dust particles
    final rand = math.Random(77);
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 25; i++) {
      final double rx = rand.nextDouble() * w;
      final double ry = rand.nextDouble() * h;
      final double sizeVal = rand.nextDouble() * 1.2 + 0.4;
      final double drift = math.sin(progress * 2 * math.pi + i) * 8;

      paint.color = Colors.white.withOpacity(0.06 + 0.1 * math.sin(progress * 2 * math.pi * (i % 2 + 1)));
      canvas.drawCircle(Offset(rx, (ry + drift) % h), sizeVal, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _CommandBackgroundPainter oldDelegate) => true;
}
