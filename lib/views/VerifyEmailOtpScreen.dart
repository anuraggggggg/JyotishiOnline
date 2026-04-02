import 'dart:convert';
import 'dart:io';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:AstrowayCustomer/controllers/loginController.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import '../theme/appTheme.dart';
import 'bottomNavigationBarScreen.dart';

class VerifyEmailOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final String email;

  const VerifyEmailOtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.countryCode,
    required this.email,
  }) : super(key: key);

  @override
  State<VerifyEmailOtpScreen> createState() =>
      _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends State<VerifyEmailOtpScreen>
    with CodeAutoFill {

  final LoginController loginController = Get.find<LoginController>();
  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listenForCode();

    loginController.maxSecond = 60;
    loginController.timer();

    SmsAutoFill().getAppSignature.then((signature) {
      debugPrint("📲 App Signature: $signature");
    });
  }

  @override
  void codeUpdated() {
    pinController.text = code ?? '';
    loginController.smsCode = code ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginController.update();
    });
  }

  @override
  void dispose() {
    cancel();
    pinController.dispose();
    loginController.time?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    try {
      global.showOnlyLoaderDialog(context);

      debugPrint("🔐 VERIFY EMAIL OTP START");
      debugPrint("📞 Phone: ${widget.phoneNumber}");
      debugPrint("📧 Email: ${widget.email}");
      debugPrint("🌍 Country: ${widget.countryCode}");
      debugPrint("🔢 OTP: ${loginController.smsCode}");

      final response =
      await FastAPIServices().customerMailVerifyOtp(
        contactNo: widget.phoneNumber.trim(),
        countryCode:
        widget.countryCode.replaceAll("+", ""),
        email: widget.email.trim(),
        otp: loginController.smsCode.trim(),
      );

      global.hideLoader();

      if (response.statusCode == 200) {
        debugPrint("✅ EMAIL LOGIN SUCCESS");

        global.showToast(
          message: "Login successful!",
          textColor: Colors.white,
          bgColor: Colors.green,
        );

        Get.offAll(() =>
            BottomNavigationBarScreen(index: 0));
      } else {
        final decoded = jsonDecode(response.body);
        final errorMessage =
            decoded["detail"]?.toString() ??
                "OTP verification failed";

        global.showToast(
          message: errorMessage,
          textColor: Colors.white,
          bgColor: Colors.red,
        );
      }
    } catch (e, st) {
      global.hideLoader();

      debugPrint("💥 VERIFY EMAIL OTP ERROR: $e");
      debugPrint("📄 STACKTRACE: $st");

      global.showToast(
        message: "Error verifying OTP",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),

            Center(
              child: Image.asset(
                "assets/images/newLogo.png",
                height:
                MediaQuery.of(context).size.height *
                    0.15,
              ),
            ),

            SizedBox(height: 30),

            const Text(
              "Verify Your Email & Number",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "We've sent a 6-digit OTP to:\n\n${widget.email}\n${widget.countryCode} ${widget.phoneNumber}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            SizedBox(height: 40),

            PinFieldAutoFill(
              codeLength: 6,
              controller: pinController,
              onCodeChanged: (code) {
                loginController.smsCode = code ?? '';

                if ((code?.length ?? 0) == 6) {
                  _verifyOtp();
                }
              },
            ),

            SizedBox(height: 24),

            GetBuilder<LoginController>(
              builder: (controller) {
                return controller.maxSecond != 0
                    ? Center(
                  child: Text(
                    "Resend in ${controller.maxSecond} sec",
                    style: TextStyle(
                      color: buttonColor1,
                    ),
                  ),
                )
                    : Center(
                  child: GestureDetector(
                    onTap: () async {
                      controller.maxSecond = 60;
                      controller.timer();

                      await FastAPIServices()
                          .customerLoginOtp(
                        contactNo:
                        widget.phoneNumber,
                        countryCode:
                        widget.countryCode,
                        email: widget.email,
                      );
                    },
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: buttonColor1,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (loginController.smsCode.length ==
                      6) {
                    _verifyOtp();
                  } else {
                    global.showToast(
                      message:
                      "Enter valid 6-digit OTP",
                      textColor: Colors.white,
                      bgColor: Colors.orange,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "VERIFY & CONTINUE",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
