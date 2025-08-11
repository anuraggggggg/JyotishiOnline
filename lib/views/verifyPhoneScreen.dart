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

class VerifyPhoneScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  VerifyPhoneScreen(
      {Key? key, required this.phoneNumber, required this.countryCode})
      : super(key: key);

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
    setState(() {
      pinEditingControllerlogin.text = code ?? '';
      loginController.smsCode = code ?? '';
      loginController.update();
    });
  }

  @override
  void dispose() {
    cancel();
    pinEditingControllerlogin.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    try {
      global.showOnlyLoaderDialog(context);
      final response = await FastAPIServices().verifyOtp(
        contactNo: widget.phoneNumber,
        countryCode: widget.countryCode,
        otp: loginController.smsCode,
      );
      global.hideLoader();

      if (response.statusCode == 200) {
        global.showToast(
          message: "OTP verified successfully!",
          textColor: global.textColor,
          bgColor: Colors.green,
        );
        // TODO: Navigate to dashboard or home page
      } else {
        global.showToast(
          message: "OTP verification failed!",
          textColor: Colors.white,
          bgColor: Colors.red,
        );
      }
    } catch (e) {
      global.hideLoader();
      global.showToast(
        message: "Error verifying OTP. Please try again.",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        loginController.maxSecond = 61;
        loginController.time?.cancel();
        loginController.update();
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/newLogo.png",
                    height: MediaQuery.of(context).size.height * 0.20,
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Verify Mobile Number",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: buttonColor1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PinFieldAutoFill(
                    codeLength: 6,
                    controller: pinEditingControllerlogin,
                    currentCode: pinEditingControllerlogin.text,
                    decoration: UnderlineDecoration(
                      textStyle:
                          const TextStyle(fontSize: 20, color: Colors.black),
                      colorBuilder: FixedColorBuilder(Colors.grey.shade400),
                    ),
                    onCodeChanged: (code) {
                      loginController.smsCode = code ?? '';
                      loginController.update();
                    },
                    onCodeSubmitted: (code) {
                      loginController.smsCode = code;
                      loginController.update();
                    },
                  ),
                  const SizedBox(height: 15),
                  GetBuilder<LoginController>(
                    builder: (controller) {
                      return controller.maxSecond != 0
                          ? Row(
                              children: [
                                const SizedBox(width: 15),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Resend OTP in ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${controller.maxSecond} s',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  controller.maxSecond = 60;
                                  controller.update();
                                  controller.timer();
                                  controller.phoneController.text =
                                      widget.phoneNumber;
                                  global.showOnlyLoaderDialog(context);
                                  await controller.sendOtpToPhone();
                                  global.hideLoader();
                                },
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: 90),
                  GestureDetector(
                    onTap: () async {
                      await FastAPIServices().verifyOtp(
                        contactNo: widget.phoneNumber,
                        countryCode: widget.countryCode,
                        otp: loginController.smsCode,
                      );
                    },
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: appYellow,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Text(
                          'NEXT',
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
