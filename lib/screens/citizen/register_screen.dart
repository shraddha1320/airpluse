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
  final _formKey2 = GlobalKey<FormState>(); // Final step security & submit validation
  final _formKeyAddress = GlobalKey<FormState>(); // Step 2 Address verification
  // Preserved original controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController(); // Preserved
  // Registration step state tracking
  int _currentPage = 0;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  // DOB & Gender State
  DateTime? _selectedDob;
  String _selectedGender = 'Male';
  // Dependent Dropdowns States
  String _selectedState = 'Maharashtra';
  String _selectedCity = 'Mumbai';
  String _selectedArea = 'Bandra West';
  final Map<String, List<String>> _stateToCities = {
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Delhi': ['New Delhi', 'Dwarka', 'Rohini'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi'],
  };
  final Map<String, List<String>> _cityToAreas = {
    'Mumbai': ['Bandra West', 'Andheri East', 'Kurla East'],
    'Pune': ['Kothrud', 'Koregaon Park', 'Hinjawadi'],
    'New Delhi': ['Connaught Place', 'Karol Bagh', 'Saket'],
    'Dwarka': ['Sector 6', 'Sector 10', 'Sector 22'],
    'Rohini': ['Sector 3', 'Sector 7', 'Sector 15'],
    'Bengaluru': ['Indiranagar', 'Koramangala', 'Jayanagar'],
    'Mysuru': ['Gokulam', 'Jayalakshmipuram', 'Vidyaranyapuram'],
    'Hubballi': ['Keshwapur', 'Vidyanagar', 'Gokul Road'],
  };
  // Auto location detection state
  bool _isLocating = false;
  // Checkboxes
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  // Password Checklist Helper
  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasAtSymbol = false;
  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
    _loopController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
    _passwordController.addListener(_validatePasswordRules);
  }
  void _validatePasswordRules() {
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
    _scanController.dispose();
    _loopController.dispose();
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
    if (_isSuccess) return "Welcome to the Clean Air Network!";
    if (_currentPage == 0) return "Let's start with your basic information.";
    if (_currentPage == 1) return "Almost done! Help us verify your location.";
    return "You're ready to join the Clean Air Network.";
  }
  String _getAiriExpression() {
    if (_isSuccess) return "happy";
    if (_currentPage == 0) return "excited";
    if (_currentPage == 1) return "monitoring";
    return "happy";
  }
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
  Future<void> _handleRegister() async {
    if (!_formKey2.currentState!.validate()) return;
    if (!_hasLength || !_hasUppercase || !_hasNumber || !_hasAtSymbol) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please satisfy all password security checklist rules.')),
      );
      return;
    }
    if (!_acceptTerms || !_acceptPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Privacy Policy to continue.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1500 ~/ 1000));
      setState(() => _isSuccess = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _selectedState = 'Maharashtra';
        _selectedCity = 'Mumbai';
        _selectedArea = 'Bandra West';
        _isLocating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS coordinated successfully.')),
      );
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
          // Background grid Painter
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _loopController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RegisterGridBackgroundPainter(progress: _loopController.value),
                );
              },
            ),
          ),
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
        _buildHeader(),
        const SizedBox(height: 20),
        // Information notice card: Citizen Registration Only
        _buildNoticeCard(),
        const SizedBox(height: 16),
        _buildAiriSection(),
        const SizedBox(height: 20),
        _buildProgressIndicator(),
        const SizedBox(height: 24),
        // Registration form card
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
                  height: _currentPage == 0
                      ? 450
                      : _currentPage == 1
                      ? 420
                      : 520,
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
                BoxShadow(color: const Color(0xFFFFC72C).withOpacity(0.2), blurRadius: 12),
              ],
            ),
            child: const Center(
              child: Icon(Icons.air_rounded, color: Color(0xFFFFC72C), size: 32),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Create Your Account",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 6),
        const Text(
          "Join thousands of citizens helping build cleaner cities through AI environmental monitoring.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.white54, height: 1.4),
        ),
      ],
    );
  }
  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Worker and Authority accounts are created by the administrator.",
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), letterSpacing: 0.5),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getAiriMessage(),
                    key: ValueKey<int>(_currentPage),
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
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
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFFFFC72C) : const Color(0xFF1B1D22),
                border: Border.all(
                  color: isCurrent ? const Color(0xFFFFC72C) : Colors.white10,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF111315) : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (index < 2)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 2,
                color: _currentPage > index ? const Color(0xFFFFC72C) : Colors.white10,
              ),
          ],
        );
      }),
    );
  }
  Widget _buildStepOnePersonal() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Step 1: Personal Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _nameController,
            label: "Full Name",
            hint: "John Doe",
            icon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter full name';
              // Letters only, spaces allowed
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return 'Letters only';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _emailController,
            label: "Email Address",
            hint: "john@airpulse.ai",
            icon: Icons.email_outlined,
            type: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter email address';
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
            hint: "10-Digit Mobile",
            icon: Icons.phone_outlined,
            type: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter phone number';
              // Exactly 10 digits
              if (!RegExp(r'^\d{10}$').hasMatch(v)) return 'Exactly 10 digits required';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormField<DateTime>(
                  initialValue: _selectedDob,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select DOB';
                    }
                    final today = DateTime.now();
                    int age = today.year - value.year;
                    if (today.month < value.month || (today.month == value.month && today.day < value.day)) {
                      age--;
                    }
                    if (age < 13) {
                      return 'You must be at least 13 years old to register.';
                    }
                    return null;
                  },
                  builder: (FormFieldState<DateTime> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDob ?? DateTime(DateTime.now().year - 13),
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
                              setState(() {
                                _selectedDob = picked;
                              });
                              state.didChange(picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111315),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: state.hasError ? const Color(0xFFEF4444) : Colors.white10,
                              ),
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
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
                            ),
                          ),
                      ],
                    );
                  },
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
                          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
    final cities = _stateToCities[_selectedState] ?? [];
    final areas = _cityToAreas[_selectedCity] ?? [];
    return Form(
      key: _formKeyAddress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Step 2: Region Coordinates", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF38BDF8)),
                      )
                          : const Icon(Icons.my_location_rounded, color: Color(0xFF38BDF8), size: 14),
                      const SizedBox(width: 6),
                      const Text("Auto GPS", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // State Dropdown
          _buildDropdownField(
            label: "State",
            value: _selectedState,
            items: _stateToCities.keys.toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedState = val;
                  _selectedCity = _stateToCities[val]!.first;
                  _selectedArea = _cityToAreas[_selectedCity]!.first;
                });
              }
            },
          ),
          const SizedBox(height: 14),
          // City Dropdown depends on State
          _buildDropdownField(
            label: "City",
            value: _selectedCity,
            items: cities,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCity = val;
                  _selectedArea = _cityToAreas[val]!.first;
                });
              }
            },
          ),
          const SizedBox(height: 14),
          // Area Dropdown depends on City
          _buildDropdownField(
            label: "Local Area / Ward",
            value: _selectedArea,
            items: areas,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedArea = val;
                });
              }
            },
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
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Step 3: Security & Verification", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
          const SizedBox(height: 12),
          // Live Password Checklist Grid
          _buildPasswordChecklistPanel(),
          const SizedBox(height: 12),
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
              if (v == null || v.isEmpty) return 'Confirm password';
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 12),
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
  Widget _buildPasswordChecklistPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111315),
        borderRadius: BorderRadius.circular(14),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 5,
        children: [
          _checklistIndicator(_hasLength, "8–16 Characters"),
          _checklistIndicator(_hasUppercase, "1 Uppercase"),
          _checklistIndicator(_hasNumber, "1 Number"),
          _checklistIndicator(_hasAtSymbol, "Contains '@'"),
        ],
      ),
    );
  }
  Widget _checklistIndicator(bool satisfied, String text) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.radio_button_off,
          color: satisfied ? const Color(0xFF34D399) : Colors.white24,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: satisfied ? Colors.white70 : Colors.white24, fontSize: 10)),
      ],
    );
  }
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF111315),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9.5, fontWeight: FontWeight.bold)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: const Color(0xFF1B1D22),
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
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
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11))),
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
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipOval(child: CustomPaint(painter: AiriCharacterPainter(expression: 'happy'))),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF34D399).withOpacity(0.15),
              border: Border.all(color: const Color(0xFF34D399), width: 2),
            ),
            child: const Icon(Icons.check_rounded, color: Color(0xFF34D399), size: 42),
          ),
          const SizedBox(height: 24),
          const Text('Account Created!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          const Text(
            'Welcome to the Clean Air Network. Your telemetry feeds are now synchronized.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC72C),
                foregroundColor: const Color(0xFF111315),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFFC72C), width: 1.2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2)),
      ),
    );
  }
}
class _RegisterGridBackgroundPainter extends CustomPainter {
  final double progress;
  _RegisterGridBackgroundPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final double w = size.width;
    final double h = size.height;
    const double gridSize = 70.0;
    for (double i = 0; i < w; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
    }
    for (double i = 0; i < h; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(w, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _RegisterGridBackgroundPainter oldDelegate) => false;
}
