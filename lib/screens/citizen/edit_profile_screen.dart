import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Shraddha");
  final _phoneController = TextEditingController(text: "9876543210");
  final _cityController = TextEditingController(text: "Mumbai");
  final _stateController = TextEditingController(text: "Maharashtra");
  final _emailController = TextEditingController(text: "shraddha@gmail.com");

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1B1D22),
          content: Text(
            "Profile updated successfully",
            style: TextStyle(color: Color(0xFFFFC72C)),
          ),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenScaffold(
      title: "Edit Profile",
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel("PERSONAL DETAILS"),
            GlassSectionCard(
              child: Column(
                children: [
                  _buildField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                    validator: (v) =>
                    (v == null || v.trim().length < 2) ? "Enter a valid name" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length != 10)
                        ? "Enter a valid 10-digit number"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Email is required";
                      }

                      final emailRegex = RegExp(
                        r'^[\w\.-]+@[\w\.-]+\.\w+$',
                      );

                      if (!emailRegex.hasMatch(v.trim())) {
                        return "Enter a valid email address";
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel("LOCATION"),
            GlassSectionCard(
              child: Column(
                children: [
                  _buildField(
                    controller: _stateController,
                    label: "State",
                    icon: Icons.map_outlined,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "State is required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _cityController,
                    label: "City",
                    icon: Icons.location_city_outlined,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "City is required" : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC72C),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13.5),
      cursorColor: const Color(0xFFFFC72C),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12.5),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        filled: true,
        fillColor: const Color(0xFF111315),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFC72C), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
      ),
    );
  }
}