import 'dart:convert';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'VerifyEmailOtpScreen.dart';
import 'newSignUp/newSignUp.dart';

class LoginWithEmailScreen extends StatefulWidget {
  const LoginWithEmailScreen({Key? key}) : super(key: key);

  @override
  State<LoginWithEmailScreen> createState() =>
      _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState
    extends State<LoginWithEmailScreen> {

  final TextEditingController emailController =
  TextEditingController();

  bool _isLoading = false;

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    if (email.isEmpty) {
      global.showToast(
        message: "Email is required",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response =
      await FastAPIServices().customerLoginOtp(
        contactNo: "",
        countryCode: "",
        email: email,
        sendSms: false,
        sendEmail: true,
      );

      if (response.statusCode == 200) {
        global.showToast(
          message: "OTP sent to your email!",
          textColor: Colors.white,
          bgColor: Colors.green,
        );

        Get.to(() => VerifyEmailOtpScreen(
          phoneNumber: "",
          countryCode: "",
          email: email,
        ));
      } else {
        final decoded = jsonDecode(response.body);
        final errorMessage =
            decoded["detail"]?.toString() ??
                "Something went wrong";

        global.showToast(
          message: errorMessage,
          textColor: Colors.white,
          bgColor: Colors.red,
        );
      }
    } catch (e) {
      global.showToast(
        message: "Something went wrong",
        textColor: Colors.white,
        bgColor: Colors.red,
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
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [

              // Logo
              Image.asset(
                "assets/images/newLogo.png",
                height: 80,
              ),

              const Center(
                child: Text(
                  "Welcome back to",
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
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Login with Email",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 30),

              // Email Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Send OTP Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "SEND OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Get.to(() => const SignupWithOtpScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    side: BorderSide(
                      color: Colors.blue[700]!,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined,
                          size: 20),
                      SizedBox(width: 8),
                      Text(
                        "CREATE NEW ACCOUNT",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Terms
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "By continuing, you agree to our Terms of Service and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
