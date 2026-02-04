import 'dart:convert';

import 'package:AstrowayCustomer/views/newSignUp/verifySignupOtp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../theme/appTheme.dart';
import '../settings/termsAndConditionScreen.dart';
import '../../fastApi/fastApiServices.dart';

class SignupWithOtpScreen extends StatefulWidget {
  const SignupWithOtpScreen({super.key});

  @override
  State<SignupWithOtpScreen> createState() => _SignupWithOtpScreenState();
}

class _SignupWithOtpScreenState extends State<SignupWithOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final FastAPIServices _api = FastAPIServices();

  final _nameController = TextEditingController();
  final _countryCodeController = TextEditingController(text: "+91");
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isTermsAccepted = false;

  // ---------------- SEND OTP ----------------
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTermsAccepted) {
      Get.snackbar("Required", "Please accept Terms & Conditions");
      return;
    }

    final countryCode = _countryCodeController.text.replaceAll('+', '').trim();

    setState(() => _isLoading = true);

    try {
      final success = await _api.sendCustomerOtp(
        contactNo: _contactController.text.trim(),
        countryCode: countryCode,
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success) {
        Get.to(() => VerifyOtpScreen(
          contactNo: _contactController.text.trim(),
        ));
      }
    } catch (e) {
      // Extract just the message from JSON string if it's in JSON format
      String errorMessage = e.toString();

      // Check if it's a JSON string
      if (errorMessage.contains('{"detail":')) {
        try {
          // Try to parse it as JSON
          final errorJson = json.decode(errorMessage);
          if (errorJson['detail'] != null) {
            errorMessage = errorJson['detail'].toString();
          }
        } catch (_) {
          // If parsing fails, keep original message
        }
      }

      // Remove any quotes and brackets
      errorMessage = errorMessage.replaceAll('{"detail":"', '');
      errorMessage = errorMessage.replaceAll('"}', '');
      errorMessage = errorMessage.replaceAll('"', '');

      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Image.asset(
                      "assets/images/newLogo.png",
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Welcome heading
                const Center(
                  child: Text(
                    "Welcome to",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Center(
                  child: Text(
                    "Jyotishi Online",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                const Center(
                  child: Text(
                    "Sign up to get started",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                _field(
                  _nameController,
                  "Full Name",
                  Icons.person_outline,
                  validator: (v) =>
                  v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 14),

                // Mobile number row
                Row(
                  children: [
                    // Country code
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _countryCodeController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                          LengthLimitingTextInputFormatter(4),
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "+91",
                          prefixIcon: Icon(
                            Icons.flag,
                            color: Colors.blue[700],
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        _contactController,
                        "Mobile Number",
                        Icons.phone_iphone_outlined,
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
                const SizedBox(height: 14),

                // Email field
                _field(
                  _emailController,
                  "Email Address",
                  Icons.email_outlined,
                  validator: (v) =>
                  v == null || !GetUtils.isEmail(v)
                      ? "Invalid email"
                      : null,
                ),
                const SizedBox(height: 18),

                // Terms & Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: _isTermsAccepted,
                        onChanged: (v) =>
                            setState(() => _isTermsAccepted = v ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        activeColor: appYellow,
                        checkColor: Colors.black,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text.rich(
                          TextSpan(children: [
                            const TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: "Terms & Conditions",
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Get.to(() => TermAndConditionScreen()),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Send OTP button
                _isLoading
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: appYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 2,
                    ),
                  ),
                )
                    : SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appYellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_outlined, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "SEND OTP",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sign in link
                const SizedBox(height: 20),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Add your sign in navigation here
                              // Get.to(() => SignInScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Extra padding at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController controller,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[700],
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appYellow, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}