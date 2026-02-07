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

class VerifyPhoneScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  VerifyPhoneScreen({
    Key? key,
    required this.phoneNumber,
    required this.countryCode,
  }) : super(key: key);

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen>
    with CodeAutoFill {
  final LoginController loginController = Get.find<LoginController>();
  final TextEditingController pinEditingControllerlogin =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    requestSmsPermission();
    listenForCode();

    // ✅ Reset and start timer every time screen opens
    loginController.maxSecond = 60;
    loginController.timer();

    SmsAutoFill().getAppSignature.then((signature) {
      debugPrint("App Signature: $signature");
    });
  }

  Future<void> requestSmsPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.sms.status;
      if (!status.isGranted) {
        await Permission.sms.request();
      }
    }
  }

  @override
  void codeUpdated() {
    // ✅ Avoid setState & update during build phase
    pinEditingControllerlogin.text = code ?? '';
    loginController.smsCode = code ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginController.update();
    });
  }

  @override
  void dispose() {
    cancel();
    pinEditingControllerlogin.dispose();
    loginController.time?.cancel(); // ✅ Cancel timer when leaving screen
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    try {
      global.showOnlyLoaderDialog(context);

      debugPrint("🔐 VERIFY OTP START");
      debugPrint("📞 Phone: ${widget.phoneNumber}");
      debugPrint("🌍 Country: ${widget.countryCode}");
      debugPrint("🔢 OTP: ${loginController.smsCode}");

      final response = await FastAPIServices().verifyLoginOtp(
        contactNo: widget.phoneNumber.trim(),
        otp: loginController.smsCode.trim(),
        countryCode: widget.countryCode.replaceAll("+", ""),
      );

      debugPrint("📡 OTP VERIFY STATUS: ${response.statusCode}");
      debugPrint("📩 OTP VERIFY BODY: ${response.body}");

      global.hideLoader();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data["access_token"];
        final userId = data["user"]?["id"];
        final role = data["user"]?["role"];

        debugPrint("✅ LOGIN SUCCESS");
        debugPrint("🔑 AccessToken length: ${accessToken?.length}");
        debugPrint("👤 UserId: $userId");
        debugPrint("🎭 Role: $role");

        /// ✅ SAVE SESSION PROPERLY
        await loginController.saveLoginSession(
          accessToken: accessToken,
          userId: userId,
          role: role,
        );

        /// 🔄 FORCE LOAD INTO FastAPIServices
        await FastAPIServices().loadFromStorage();

        global.showToast(
          message: "Login successful!",
          textColor: Colors.white,
          bgColor: Colors.green,
        );

        debugPrint("➡️ Navigating to Home");

        Get.offAll(() => BottomNavigationBarScreen(index: 0));
      } else {
        debugPrint("❌ OTP FAILED");

        global.showToast(
          message: "OTP verification failed!",
          textColor: Colors.white,
          bgColor: Colors.red,
        );
      }
    } catch (e, st) {
      global.hideLoader();
      debugPrint("💥 OTP VERIFY EXCEPTION: $e");
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
    return WillPopScope(
      onWillPop: () async {
        loginController.time?.cancel(); // ✅ Cancel timer on back press
        loginController.maxSecond = 60; // reset value
        loginController.update();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              loginController.time?.cancel();
              loginController.maxSecond = 60;
              loginController.update();
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    "assets/images/newLogo.png",
                    height: MediaQuery.of(context).size.height * 0.15,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Verify Your Number",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text:
                        "We've sent a 6-digit verification code to your mobile number and email.\n"
                            "Please check your inbox or spam folder to continue.\n\n",
                      ),
                      TextSpan(
                        text: "${widget.countryCode} ${widget.phoneNumber}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: buttonColor1,
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 40),
                PinFieldAutoFill(
                  codeLength: 6,
                  controller: pinEditingControllerlogin,
                  currentCode: pinEditingControllerlogin.text,
                  decoration: BoxLooseDecoration(
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    strokeColorBuilder:
                    FixedColorBuilder(Colors.grey.shade300),
                    bgColorBuilder: FixedColorBuilder(Colors.grey.shade50),
                    gapSpace: 12,
                    strokeWidth: 2,
                  ),
                  onCodeChanged: (code) {
                    loginController.smsCode = code ?? '';

                    // ✅ Delay update until after current frame
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      loginController.update();
                    });

                    if ((code?.length ?? 0) == 6) {
                      _verifyOtp();
                    }
                  },
                  onCodeSubmitted: (code) {
                    loginController.smsCode = code;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      loginController.update();
                    });

                    _verifyOtp();
                  },
                ),
                SizedBox(height: 24),
                GetBuilder<LoginController>(
                  builder: (controller) {
                    return controller.maxSecond != 0
                        ? Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Resend code in ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: '${controller.maxSecond} ',
                              style: TextStyle(
                                color: buttonColor1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'seconds',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : Center(
                      child: GestureDetector(
                        onTap: () async {
                          controller.maxSecond = 60;
                          controller.timer(); // ✅ restart timer
                          controller.phoneController.text =
                              widget.phoneNumber;

                          await controller.sendOtpToPhone();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: buttonColor1,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 40),
                Container(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (loginController.smsCode.length == 6) {
                        await _verifyOtp();
                      } else {
                        global.showToast(
                          message: "Please enter a valid 6-digit OTP",
                          textColor: Colors.white,
                          bgColor: Colors.orange,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'VERIFY & CONTINUE',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Option to edit phone number
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Edit Phone Number',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
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
}
