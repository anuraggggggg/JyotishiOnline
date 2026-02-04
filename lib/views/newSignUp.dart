import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/views/loginWithEmailScreen.dart';
import 'package:AstrowayCustomer/views/settings/termsAndConditionScreen.dart';


class _SignupWithEmailScreenState extends State<SignupWithEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final FastAPIServices _api = FastAPIServices();

  final _nameController = TextEditingController();
  final _countryCodeController = TextEditingController(text: "+91");
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isTermsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  File? _selectedImage;

  // ---------------- IMAGE PICK ----------------
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // ---------------- SIGNUP ----------------
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTermsAccepted) {
      Get.snackbar("Required", "Please accept Terms & Conditions");
      return;
    }

    final pincode = int.tryParse(_pincodeController.text.trim());
    if (pincode == null) {
      Get.snackbar("Error", "Invalid pincode");
      return;
    }

    final countryCode =
    _countryCodeController.text.replaceAll('+', '').trim();

    setState(() => _isLoading = true);

    final res = await _api.signupWithDetails(
      name: _nameController.text.trim(),
      contactNo: _contactController.text.trim(),
      countryCode: countryCode,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      pincode: pincode,
      addressLine1: _addressController.text.trim(),
      location: _cityController.text.trim(),
      profilePicPath: _selectedImage?.path,
    );

    setState(() => _isLoading = false);

    if (res != null && res["error"] != true) {
      Get.snackbar("Success", "Account created successfully");
      // Get.offAll(() => const LoginWithEmailScreen());
    } else {
      Get.snackbar("Error", res?["message"]?.toString() ?? "Signup failed");
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset("assets/images/newLogo.png", height: 80),
                const SizedBox(height: 20),

                _buildProfilePicker(),
                const SizedBox(height: 20),

                _field(_nameController, "Full Name", Icons.person,
                    validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null),

                // COUNTRY CODE + MOBILE
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: _field(
                        _countryCodeController,
                        "Code",
                        Icons.flag,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Req";
                          final code = v.replaceAll('+', '');
                          if (code.isEmpty || code.length > 3) {
                            return "Invalid";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _field(
                        _contactController,
                        "Mobile Number",
                        Icons.phone,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (v) =>
                        v == null || v.length != 10
                            ? "10 digits required"
                            : null,
                      ),
                    ),
                  ],
                ),

                _field(
                  _emailController,
                  "Email",
                  Icons.email,
                  validator: (v) =>
                  v == null || !GetUtils.isEmail(v)
                      ? "Invalid email"
                      : null,
                ),

                _field(
                  _addressController,
                  "Address",
                  Icons.home,
                  validator: (v) =>
                  v == null || v.isEmpty ? "Required" : null,
                ),

                _field(
                  _cityController,
                  "City",
                  Icons.location_city,
                  validator: (v) =>
                  v == null || v.isEmpty ? "Required" : null,
                ),

                _field(
                  _pincodeController,
                  "Pincode",
                  Icons.pin_drop,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) =>
                  v == null || v.length != 6
                      ? "6 digit pincode"
                      : null,
                ),

                _field(
                  _passwordController,
                  "Password",
                  Icons.lock,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) =>
                  v == null || v.length < 8
                      ? "Min 8 characters"
                      : null,
                ),

                _field(
                  _confirmPasswordController,
                  "Confirm Password",
                  Icons.lock_outline,
                  obscure: _obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                            () => _obscureConfirmPassword =
                        !_obscureConfirmPassword),
                  ),
                  validator: (v) =>
                  v != _passwordController.text
                      ? "Password mismatch"
                      : null,
                ),

                Row(
                  children: [
                    Checkbox(
                      value: _isTermsAccepted,
                      onChanged: (v) =>
                          setState(() => _isTermsAccepted = v ?? false),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: "I agree to "),
                          TextSpan(
                            text: "Terms & Conditions",
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  Get.to(() => TermAndConditionScreen()),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appYellow),
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(color: Colors.black),
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

  // ---------------- HELPERS ----------------
  Widget _buildProfilePicker() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
          _selectedImage != null ? FileImage(_selectedImage!) : null,
          child:
          _selectedImage == null ? const Icon(Icons.person, size: 30) : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: appYellow,
              child: const Icon(Icons.edit, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label,
      IconData icon, {
        String? Function(String?)? validator,
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        Widget? suffix,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}


class SignupWithEmailScreen extends StatefulWidget {
  const SignupWithEmailScreen({super.key});

  @override
  State<SignupWithEmailScreen> createState() => _SignupWithEmailScreenState();
}
