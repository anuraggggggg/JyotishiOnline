// views/loginScreen.dart
// ignore_for_file: deprecated_member_use

import 'dart:developer' as developer;

import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/loginController.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController loginController;
  late final HomeController homeController;
  final Rx<PhoneNumber> _selectedPhoneNumber = PhoneNumber(isoCode: "IN").obs;

  @override
  void initState() {
    super.initState();
    loginController = Get.find<LoginController>();
    homeController = Get.find<HomeController>();
  }

  // --- IMPORTANT: Add this to dispose the TextEditingController properly when the screen is removed ---
  @override
  void dispose() {
    loginController.phoneController.dispose();
    super.dispose();
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
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Theme(
                                    data: ThemeData(
                                      dialogTheme: DialogTheme(
                                        contentTextStyle: const TextStyle(
                                            color: Colors.white),
                                        backgroundColor: Colors.grey[800],
                                        surfaceTintColor: Colors.grey[800],
                                      ),
                                    ),
                                    child: InternationalPhoneNumberInput(
                                      // REMOVE THIS LINE:
                                      // key: ValueKey(_selectedPhoneNumber.value.isoCode!),
                                      textFieldController:
                                          loginController.phoneController,
                                      inputDecoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Phone number',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontFamily: "verdana_regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      onInputValidated: (bool value) {
                                        developer.log(
                                            'Phone number validity: $value');
                                      },
                                      selectorConfig: SelectorConfig(
                                        leadingPadding: 2,
                                        selectorType:
                                            PhoneInputSelectorType.BOTTOM_SHEET,
                                        showFlags: true,
                                      ),
                                      ignoreBlank: false,
                                      autoValidateMode:
                                          AutovalidateMode.disabled,
                                      selectorTextStyle:
                                          const TextStyle(color: Colors.black),
                                      searchBoxDecoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2.w)),
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                        ),
                                        hintText: "Search",
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      initialValue: _selectedPhoneNumber
                                          .value, // Keep this, it's fine
                                      formatInput: false,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: false,
                                      ),
                                      inputBorder: InputBorder.none,
                                      onSaved: (PhoneNumber number) {
                                        loginController
                                            .updateCountryCode(number.dialCode);
                                        _selectedPhoneNumber.value =
                                            number; // Update local reactive variable
                                      },
                                      onFieldSubmitted: (value) {
                                        FocusScope.of(context).unfocus();
                                      },
                                      onInputChanged: (PhoneNumber number) {
                                        loginController
                                            .updateCountryCode(number.dialCode);
                                        _selectedPhoneNumber.value =
                                            number; // Update local reactive variable
                                      },
                                      onSubmit: () {
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // WhatsApp button - always visible
                              GestureDetector(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  bool isValid = loginController.validedPhone();
                                  if (isValid) {
                                    await loginController.sendOtpViaWhatsApp(
                                      phoneNumber:
                                          loginController.phoneController.text,
                                    );
                                  } else {
                                    global.showToast(
                                      message: loginController.errorText!,
                                      textColor: global.textColor,
                                      bgColor: global.toastBackGoundColor,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    color: appYellow,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Send OTP on WhatsApp',
                                      style: TextStyle(color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ).tr(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),

                              // SMS button - visible only for foreign users
                              // NOTE: The original condition `loginController.countryCode.value == "+91"`
                              // makes it visible for India. If you meant *foreign* users,
                              // the condition should be `loginController.countryCode.value != "+91"`.
                              // I'm keeping your original logic for now.
                              if (loginController.countryCode.value ==
                                  "+91") ...[
                                GestureDetector(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    bool isValid =
                                        loginController.validedPhone();
                                    if (isValid) {
                                      await loginController.sendOtpToPhone();
                                    } else {
                                      global.showToast(
                                        message: loginController.errorText!,
                                        textColor: global.textColor,
                                        bgColor: global.toastBackGoundColor,
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 45,
                                    width: double.infinity,
                                    margin: EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      color: appYellow,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Send OTP on SMS',
                                        style: TextStyle(color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ).tr(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                              SizedBox(height: 20),
                              Text(
                                "By Creating account, you are accepting terms & conditions",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ).tr(),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 5.0;
  @override
  Path getClip(Size size) {
    Path path_1 = Path();
    path_1.moveTo(size.width * -0.0034000, size.height * -0.0005200);
    path_1.lineTo(size.width * 1.0044000, size.height * 0.0041400);
    path_1.quadraticBezierTo(size.width * 1.0017750, size.height * 0.6117900,
        size.width * 1.0009000, size.height * 0.8143400);
    path_1.cubicTo(
        size.width * 0.7438000,
        size.height * 1.0302400,
        size.width * 0.3289375,
        size.height * 1.0551400,
        size.width * 0.0006000,
        size.height * 0.8136600);
    path_1.quadraticBezierTo(size.width * -0.0010250, size.height * 0.6101200,
        size.width * -0.0034000, size.height * -0.0005200);
    path_1.close();

    return path_1;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LeftTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white;
    Path path = Path();
    path.moveTo(size.width, size.height / 2);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RightTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white;
    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
