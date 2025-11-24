// views/loginScreen.dart
// ignore_for_file: deprecated_member_use

import 'dart:developer' as developer;

import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/loginController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/views/loginWithEmailScreen.dart';
import 'package:AstrowayCustomer/views/verifyPhoneScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'newSignUp.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController loginController;
  late final HomeController homeController;

  final Rx<PhoneNumber> _selectedPhoneNumber = PhoneNumber(isoCode: "IN").obs;

  // Terms Checkbox
  final RxBool acceptTerms = false.obs;

  @override
  void initState() {
    super.initState();
    loginController = Get.find<LoginController>();
    homeController = Get.find<HomeController>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // LOGO
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/newLogo.png",
                        height: MediaQuery.of(context).size.height * 0.20,
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Mobile Number",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: buttonColor1,
                          ),
                        ).tr(),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),

                // PHONE INPUT
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Theme(
                              data: ThemeData(
                                dialogTheme: DialogTheme(
                                  contentTextStyle: const TextStyle(color: Colors.white),
                                  backgroundColor: Colors.grey[800],
                                  surfaceTintColor: Colors.grey[800],
                                ),
                              ),
                              child: InternationalPhoneNumberInput(
                                key: ValueKey(_selectedPhoneNumber.value.isoCode!),
                                textFieldController: loginController.phoneController,
                                inputDecoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Phone number',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                selectorConfig: SelectorConfig(
                                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                  showFlags: true,
                                ),
                                initialValue: _selectedPhoneNumber.value,
                                formatInput: false,
                                keyboardType: TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: false,
                                ),
                                onInputChanged: (PhoneNumber number) {
                                  loginController.updateCountryCode(number.dialCode);
                                  _selectedPhoneNumber.value = number;
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // SEND OTP BUTTON
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();

                            // T&C check
                            if (!acceptTerms.value) {
                              global.showToast(
                                message: "Please accept Terms & Conditions",
                                textColor: Colors.white,
                                bgColor: Colors.red,
                              );
                              return;
                            }

                            bool isValid = loginController.validedPhone();
                            if (!isValid) {
                              global.showToast(
                                message: loginController.errorText ??
                                    "Invalid phone number",
                                textColor: Colors.white,
                                bgColor: Colors.red,
                              );
                              return;
                            }

                            try {
                              final response = await FastAPIServices().sendOtp(
                                contactNo:
                                loginController.phoneController.text.trim(),
                                countryCode: "+91",
                                sendWhatsapp: true,
                                sendSms: true,
                              );

                              if (response.statusCode == 200) {
                                global.showToast(
                                  message: "OTP sent successfully!",
                                  textColor: Colors.white,
                                  bgColor: Colors.green,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VerifyPhoneScreen(
                                      phoneNumber:
                                      loginController.phoneController.text.trim(),
                                      countryCode: '+91',
                                    ),
                                  ),
                                );
                              } else {
                                global.showToast(
                                  message:
                                  response.body.isNotEmpty ? response.body : "Failed",
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
                            }
                          },
                          child: Container(
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: appYellow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Send OTP',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // SIGN UP TEXT
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const SignupWithEmailScreen());
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                children: [
                                  TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // LOGIN WITH EMAIL
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginWithEmailScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                children: [
                                  TextSpan(text: "Login with Email & Password "),
                                  TextSpan(
                                    text: "Click Here",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 25),

                        // TERMS & CONDITIONS CHECKBOX
                        // Obx(() {
                        //   return Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       Checkbox(
                        //         value: acceptTerms.value,
                        //         activeColor: appYellow,
                        //         onChanged: (value) {
                        //           acceptTerms.value = value ?? false;
                        //         },
                        //       ),
                        //       // Expanded(
                        //       //   child: RichText(
                        //       //     text: TextSpan(
                        //       //       style: TextStyle(
                        //       //         color: Colors.black,
                        //       //         fontSize: 14,
                        //       //       ),
                        //       //       children: [
                        //       //         const TextSpan(
                        //       //             text:
                        //       //             "By creating account, you accept the "),
                        //       //         TextSpan(
                        //       //           text: "Terms & Conditions",
                        //       //           style: const TextStyle(
                        //       //             color: Colors.blue,
                        //       //             fontWeight: FontWeight.bold,
                        //       //             decoration: TextDecoration.underline,
                        //       //           ),
                        //       //           recognizer: TapGestureRecognizer()
                        //       //             ..onTap = () {
                        //       //               print("Open Terms & Conditions screen");
                        //       //             },
                        //       //         ),
                        //       //       ],
                        //       //     ),
                        //       //   ),
                        //       // ),
                        //     ],
                        //   );
                        // }),

                        SizedBox(height: 20),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
