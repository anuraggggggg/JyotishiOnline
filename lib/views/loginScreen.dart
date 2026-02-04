import 'dart:convert';
import 'dart:developer' as developer;
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/loginController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/views/verifyPhoneScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'newSignUp/newSignUp.dart';
import 'newSignUp/verifySignupOtp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController loginController;
  late final HomeController homeController;
  final Rx<PhoneNumber> _selectedPhoneNumber = PhoneNumber(isoCode: "IN").obs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loginController = Get.find<LoginController>();
    homeController = Get.find<HomeController>();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    bool isValid = loginController.validedPhone();
    if (!isValid) {
      global.showToast(
        message: loginController.errorText ?? "Invalid phone number",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await FastAPIServices().sendOtp(
        contactNo: loginController.phoneController.text.trim(),
        countryCode: "+91",
      );

      if (response.statusCode == 200) {
        global.showToast(
          message: "OTP sent successfully!",
          textColor: Colors.white,
          bgColor: Colors.green,
        );

        Get.to(() => VerifyPhoneScreen(
          phoneNumber: loginController.phoneController.text.trim(),
          countryCode: '+91',
        ));
      } else {
        String errorMessage = "Something went wrong";

        if (response.body.isNotEmpty) {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded['detail'] != null) {
              errorMessage = decoded['detail'];
            }
          } catch (e) {
            errorMessage = "Unable to process request";
          }
        }

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
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Logo
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8, top: 20),
                    child: Image.asset(
                      "assets/images/newLogo.png",
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Welcome heading
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
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Login with your mobile number",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Phone input section
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mobile Number",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            // This will style the country selector dialog
                            textTheme: Theme.of(context).textTheme.copyWith(
                              bodyLarge: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              bodyMedium: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: InternationalPhoneNumberInput(
                              key: ValueKey(_selectedPhoneNumber.value.isoCode!),
                              textFieldController: loginController.phoneController,
                              inputDecoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter 10-digit mobile number',
                                hintStyle: TextStyle(color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                              ),
                              selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                showFlags: true,
                                setSelectorButtonAsPrefixIcon: true,
                                leadingPadding: 8,
                                trailingSpace: false,
                              ),
                              initialValue: _selectedPhoneNumber.value,
                              formatInput: false,
                              keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
                              onInputChanged: (PhoneNumber number) {
                                loginController.updateCountryCode(number.dialCode);
                                _selectedPhoneNumber.value = number;
                              },
                              selectorTextStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 28),

                // Send OTP Button
                _isLoading
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 2,
                    ),
                  ),
                )
                    : SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appYellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: appYellow.withOpacity(0.3),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "SEND OTP",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with "OR"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_outlined, size: 20),
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

                // Terms text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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

                // Skip login (optional)
                // TextButton(
                //   onPressed: () {
                //     // Add skip login functionality
                //     // Get.offAll(() => HomeScreen());
                //   },
                //   style: TextButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                //   ),
                //   child: Text(
                //     "Continue as Guest",
                //     style: TextStyle(
                //       color: Colors.grey[700],
                //       fontWeight: FontWeight.w600,
                //       fontSize: 14,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}