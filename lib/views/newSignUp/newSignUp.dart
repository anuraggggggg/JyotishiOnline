import 'dart:convert';
import 'package:AstrowayCustomer/views/newSignUp/verifySignupOtp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../../services/location_services.dart';
import '../../theme/appTheme.dart';
import '../loginScreen.dart';
import '../loginWithEmail.dart';
import '../settings/termsAndConditionScreen.dart';
import '../../fastApi/fastApiServices.dart';

class SignupWithOtpScreen extends StatefulWidget {
  const SignupWithOtpScreen({super.key});

  @override
  State<SignupWithOtpScreen> createState() => _SignupWithOtpScreenState();
}

class _SignupWithOtpScreenState extends State<SignupWithOtpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FastAPIServices _api = FastAPIServices();

  final _nameController = TextEditingController();
  final _countryCodeController = TextEditingController(text: "+91");
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isTermsAccepted = false;

  bool get isIndian => LocationService.isIndianUser;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _countryCodeController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // SEND OTP
  // ------------------------------------------------
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTermsAccepted) {
      _showCustomSnackbar(
        "Terms & Conditions Required",
        "Please accept the Terms & Conditions to continue",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _api.sendCustomerOtp(
        contactNo: isIndian ? _contactController.text.trim() : null,
        countryCode: isIndian
            ? _countryCodeController.text.replaceAll("+", "").trim()
            : null,
        username: _nameController.text.trim(),
        email: !isIndian ? _emailController.text.trim() : null,
      );

      if (success) {
        debugPrint("✅ OTP SENT SUCCESS");

        _showCustomSnackbar(
          "OTP Sent Successfully",
          "Please check your ${isIndian ? 'phone' : 'email'} for the verification code",
        );

        await Future.delayed(const Duration(milliseconds: 500));

        Get.to(() => VerifyOtpScreen(
          contactNo: isIndian ? _contactController.text.trim() : "",
          email: !isIndian ? _emailController.text.trim() : "",
        ), transition: Transition.rightToLeft);
      }
    } catch (e) {
      String msg = e.toString().replaceAll("Exception:", "").trim();

      _showCustomSnackbar(
        "Error",
        msg,
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCustomSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      barBlur: 10,
    );
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            // Logo with hero animation
                            Hero(
                              tag: 'appLogo',
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/images/newLogo.png",
                                  height: 70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isIndian
                                  ? "Sign up using your mobile number"
                                  : "Sign up using your email address",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Form Fields Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // NAME FIELD
                            _buildAnimatedField(
                              index: 0,
                              child: _field(
                                _nameController,
                                "Full Name",
                                Icons.person_outline,
                                validator: (v) =>
                                v == null || v.isEmpty ? "Please enter your full name" : null,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // PHONE (INDIAN ONLY)
                            if (isIndian)
                              _buildAnimatedField(
                                index: 1,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 90,
                                      decoration: _boxDecoration(),
                                      child: TextFormField(
                                        controller: _countryCodeController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9+]')),
                                          LengthLimitingTextInputFormatter(4),
                                        ],
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "+91",
                                          hintStyle: TextStyle(color: Colors.grey.shade400),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _field(
                                        _contactController,
                                        "Mobile Number",
                                        Icons.phone_android,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        validator: (v) {
                                          if (!isIndian) return null;
                                          if (v == null || v.isEmpty) {
                                            return "Please enter mobile number";
                                          }
                                          if (v.length != 10) {
                                            return "Enter valid 10-digit number";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // EMAIL (NON INDIAN ONLY)
                            if (!isIndian) ...[
                              _buildAnimatedField(
                                index: 1,
                                child: _field(
                                  _emailController,
                                  "Email Address",
                                  Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (isIndian) return null;
                                    if (v == null || v.isEmpty) {
                                      return "Please enter email address";
                                    }
                                    if (!GetUtils.isEmail(v)) {
                                      return "Please enter a valid email";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // TERMS & CONDITIONS
                            _buildAnimatedField(
                              index: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _isTermsAccepted,
                                        onChanged: (v) =>
                                            setState(() => _isTermsAccepted = v ?? false),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        activeColor: appYellow,
                                        checkColor: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: "I accept the ",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "Terms & Conditions",
                                              style: const TextStyle(
                                                color: appYellow,
                                                fontWeight: FontWeight.w600,
                                                decoration: TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  Get.to(() => const TermAndConditionScreen());
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // SIGN UP BUTTON
                      _buildAnimatedField(
                        index: 3,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                appYellow,
                                appYellow.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: appYellow.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                                : const Text(
                              "SIGN UP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LOGIN LINK
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: const TextStyle(
                                  color: appYellow,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    isIndian
                                        ? Get.offAll(() => LoginScreen(), transition: Transition.fadeIn)
                                        : Get.offAll(() => LoginWithEmailScreen(), transition: Transition.fadeIn);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // OR DIVIDER
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // SOCIAL LOGIN (Optional - if you have social login)
                      // You can add social login buttons here if needed
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Animated field wrapper
  Widget _buildAnimatedField({required int index, required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ------------------------------------------------
  // COMMON FIELD
  // ------------------------------------------------
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
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: appYellow, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: appYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.grey.shade50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  );
}