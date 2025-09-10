import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/proKerela/bottomController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/main.dart';
import 'package:AstrowayCustomer/model/device_info_login_model.dart';
import 'package:AstrowayCustomer/model/login_model.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <--- Ensure this import is present for Rx and GetxController
import 'package:http/http.dart' as http;
import 'package:AstrowayCustomer/utils/global.dart' as global;
import '../views/verifyPhoneScreen.dart';
import '../views/bottomNavigationBarScreen.dart';
import 'package:AstrowayCustomer/utils/AppColors.dart';

class LoginController extends GetxController {
  TextEditingController phoneController = TextEditingController();
  SplashController splashController = Get.find<SplashController>();
  APIHelper apiHelper = APIHelper();
  HomeController homeController = Get.find<HomeController>();
  RxBool isLoading = false.obs;

  // CHANGE 1: Make countryCode an RxString
  RxString countryCode = "+91".obs; // Initialize as observable

  String? errorText;

  String? _sentOtp;
  String? get sentOtp => _sentOtp;

  int maxSecond = 60;
  Timer? time;
  String smsCode = '';

  @override
  void onInit() {
    super.onInit();
    _sentOtp = null;
  }

  // CHANGE 2: Update the value using .value
  void updateCountryCode(String? code) {
    countryCode.value = code ?? "+91"; // Update the observable's value
    // No need for update() here, setting .value automatically triggers rebuild for Obx
  }

  bool validedPhone() {
    String phone = phoneController.text.trim();
    String onlyDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (onlyDigits.length >= 7 && onlyDigits.length <= 15) {
      errorText = null;
      return true;
    } else {
      errorText = "Please enter a valid phone number";
      return false;
    }
  }

  String generateOtp() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> sendOtpToPhone() async {
    _sentOtp = null;
    update();

    developer.log("sendOtpToPhone called. _sentOtp cleared to: $_sentOtp");

    String phone = phoneController.text.trim();
    String onlyDigits = phone.replaceAll(RegExp(r'\D'), '');

    if (!validedPhone()) {
      global.showToast(
        message: errorText!,
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      return;
    }

    final otp = generateOtp();
    _sentOtp = otp;
    update();
    developer.log("Generated OTP (SMS): $otp. Stored _sentOtp: $_sentOtp");

    final message =
        "Your OTP for mobile application jyotishionline login is $otp jyotishi online";
    final url =
        "http://sms.messageindia.in/v2/sendSMS?username=sameerji&message=$message&sendername=JYTSHI&smstype=TRANS&numbers=$onlyDigits&apikey=242d4043-4734-4ae8-acb6-bcbb5b855bcc&peid=1701175032658751812&templateid=1707175048832142304";

    try {
      global.showOnlyLoaderDialog(Get.context!);
      final response = await http.get(Uri.parse(url));
      global.hideLoader();

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          body is List &&
          body[0]['status'] == 'success') {
        timer();
        await Future.delayed(Duration(milliseconds: 100));
        Get.to(() => VerifyPhoneScreen(
              phoneNumber: onlyDigits,
              countryCode: '',
            ));
      } else {
        _sentOtp = null;
        update();
        global.showToast(
          message: "OTP sending failed via SMS. Try again.",
          textColor: Colors.white,
          bgColor: Colors.red,
        );
      }
    } catch (e) {
      global.hideLoader();
      _sentOtp = null;
      update();
      global.showToast(
        message: "Network error while sending SMS OTP",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      developer.log("SMS OTP Error: $e");
    }
  }

  Future<void> loginUser(int? phoneNumber, String email) async {
    try {
      isLoading.value = true;
      await global.getDeviceData();

      final loginModel = LoginModel()
        ..countryCode = countryCode.value
        ..deviceInfo = DeviceInfoLoginModel(
          appId: global.appId,
          appVersion: global.appVersion,
          deviceId: global.deviceId,
          deviceLocation: global.deviceLocation ?? "",
          deviceManufacturer: global.deviceManufacturer,
          deviceModel: global.deviceModel,
          fcmToken: global.fcmToken,
        );

      if (email.isEmpty) {
        loginModel.contactNo = phoneNumber.toString();
      } else {
        loginModel.email = email;
      }

      // 🔍 Log input model
      developer.log("🧾 Attempting Login:");
      developer.log("📧 Email: ${loginModel.email}");
      developer.log("📞 Contact No: ${loginModel.contactNo}");
      developer.log("🌐 Country Code: ${loginModel.countryCode}");
      developer.log("📱 Device Info:");
      developer.log("  • App ID: ${loginModel.deviceInfo?.appId}");
      developer.log("  • App Version: ${loginModel.deviceInfo?.appVersion}");
      developer.log("  • Device ID: ${loginModel.deviceInfo?.deviceId}");
      developer.log("  • Location: ${loginModel.deviceInfo?.deviceLocation}");
      developer.log(
          "  • Manufacturer: ${loginModel.deviceInfo?.deviceManufacturer}");
      developer.log("  • Model: ${loginModel.deviceInfo?.deviceModel}");
      developer.log("  • FCM Token: ${loginModel.deviceInfo?.fcmToken}");

      final result = await apiHelper.loginSignUp(loginModel);

      developer.log("📩 Server Response:");
      developer.log("  ✅ Status: ${result.status}");
      developer.log("  📝 Message: ${result.message}");
      developer.log("  📦 Record: ${result.recordList}");

      if (result.status == "200") {
        final recordId = result.recordList["recordList"];
        final token = result.recordList["token"];
        final tokenType = result.recordList["token_type"];

        developer.log("🎉 Login successful!");
        developer.log("  🆔 User ID: ${recordId["id"]}");
        developer.log("  🔐 Token: $token");
        developer.log("  🔒 Token Type: $tokenType");

        await global.saveCurrentUser(recordId["id"], token, tokenType);
        await splashController.getCurrentUserData();
        await global.getCurrentUser();

        homeController.myOrders.clear();
        time?.cancel();
        update();

        if (!Get.isRegistered<BottomController>()) {
          Get.put(BottomController());
        }

        Get.offAll(() => BottomNavigationBarScreen(index: 0));
      } else {
        global.showToast(
          message: result.message ?? 'Failed to sign in',
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
      }
    } catch (e, st) {
      developer.log("❌ Login Error: $e", stackTrace: st);
      global.showToast(
        message: "Login failed. Please try again.",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // REMOVED phoneController.dispose();
    developer.log(
        'LoginController onClose: phoneController NOT disposed (permanent)'); // Add log
    time?.cancel();
    super.onClose();
  }

  Future<void> sendOtpViaWhatsApp({required String phoneNumber}) async {
    _sentOtp = null;
    update();

    developer.log("sendOtpViaWhatsApp called. _sentOtp cleared to: $_sentOtp");

    String phone = phoneNumber.trim();
    String onlyDigits = phone.replaceAll(RegExp(r'\D'), '');

    // CHANGE 3: Access countryCode.value here
    String formattedPhoneNumber = "${countryCode.value}$onlyDigits";

    if (!validedPhone()) {
      global.showToast(
        message: errorText!,
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      return;
    }

    final otp = generateOtp();
    _sentOtp = otp;
    update();
    developer.log("Generated OTP (WhatsApp): $otp. Stored _sentOtp: $_sentOtp");

    final message = "Your OTP for login is $otp";
    final url =
        "http://148.251.129.118/wapp/api/send?apikey=c26b5da4b3e9485cbf3413df31080450&mobile=$formattedPhoneNumber&msg=$message";

    try {
      global.showOnlyLoaderDialog(Get.context!);
      developer.log("WhatsApp API URL: $url");
      final response = await http.get(Uri.parse(url));
      global.hideLoader();

      developer.log("WhatsApp API Raw Response Body: ${response.body}");
      final data = jsonDecode(response.body);
      developer.log("WhatsApp API Parsed Data: $data");

      if (data["status"] == "success" && data["statuscode"] == 200) {
        developer
            .log("✅ WhatsApp OTP sent successfully to $formattedPhoneNumber");
        timer();
        await Future.delayed(Duration(milliseconds: 100));
        Get.to(() => VerifyPhoneScreen(
              phoneNumber: onlyDigits,
              countryCode: '',
            ));
      } else {
        _sentOtp = null;
        update();
        String errorMessage =
            data["errormsg"] ?? "Failed to send OTP via WhatsApp. Try again.";
        global.showToast(
            message: errorMessage,
            textColor: Colors.white,
            bgColor: Colors.red);
      }
    } catch (e) {
      global.hideLoader();
      _sentOtp = null;
      update();
      developer.log("WhatsApp OTP error: $e");
      global.showToast(
          message: "Network error while sending OTP via WhatsApp",
          textColor: Colors.white,
          bgColor: Colors.red);
    }
  }

  Future<void> sendOtpViaEmail({required String email}) async {
    _sentOtp = null;
    update();
    developer.log("sendOtpViaEmail called. _sentOtp cleared to: $_sentOtp");

    if (email.isEmpty || !email.contains('@')) {
      global.showToast(
        message: "Please enter a valid email address.",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      return;
    }

    final otp = generateOtp();
    _sentOtp = otp;
    update();
    developer.log("Generated OTP (Email): $otp. Stored _sentOtp: $_sentOtp");

    global.showOnlyLoaderDialog(Get.context!);
    await Future.delayed(Duration(seconds: 2));
    global.hideLoader();
    global.showToast(
      message: "Email OTP sent (simulated)",
      textColor: global.textColor,
      bgColor: global.toastBackGoundColor,
    );
    timer();
    Get.to(() => VerifyPhoneScreen(
          phoneNumber: email,
          countryCode: '+91',
        ));
  }

  Future<void> verifyOtp({
    required String phone,
    required String otp,
    required BuildContext context,
  }) async {
    developer.log("🔐 Sent OTP (stored): $_sentOtp");
    developer.log("🔑 Entered OTP: $otp");
    developer.log("📞 Verifying for phone/email: $phone");

    if (_sentOtp != null && otp == _sentOtp) {
      developer.log("OTP matched! Proceeding to login/signup.");
      _sentOtp = null;
      update();

      developer.log("✅ OTP matched. Proceeding to login/signup...");

      if (phone.contains('@')) {
        await loginAndSignupUser(null, phone);
      } else {
        await loginAndSignupUser(int.tryParse(phone), "");
      }
    } else {
      developer.log("OTP mismatch! Entered: '$otp', Expected: '$_sentOtp'");
      developer.log("❌ OTP Mismatch! Verification failed.");
      global.showToast(
        message: "Invalid OTP",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
    }
  }

  void timer() {
    maxSecond = 60;
    update();
    time?.cancel();
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time?.cancel();
      }
    });
  }

  Future<void> loginAndSignupUser(int? phoneNumber, String email) async {
    try {
      global.showOnlyLoaderDialog(Get.context!);
      await global.getDeviceData();

      final loginModel = LoginModel()
        // CHANGE 4: Access countryCode.value here
        ..countryCode = countryCode.value
        ..deviceInfo = DeviceInfoLoginModel(
          appId: global.appId,
          appVersion: global.appVersion,
          deviceId: global.deviceId,
          deviceLocation: global.deviceLocation ?? "",
          deviceManufacturer: global.deviceManufacturer,
          deviceModel: global.deviceModel,
          fcmToken: global.fcmToken,
        );

      if (email.isEmpty) {
        loginModel.contactNo = phoneNumber.toString();
      } else {
        loginModel.email = email;
      }

      final result = await apiHelper.loginSignUp(loginModel);

      if (result.status == "200") {
        final recordId = result.recordList["recordList"];
        final token = result.recordList["token"];
        final tokenType = result.recordList["token_type"];

        await global.saveCurrentUser(recordId["id"], token, tokenType);
        await splashController.getCurrentUserData();
        await global.getCurrentUser();

        homeController.myOrders.clear();
        time?.cancel();
        update();

        if (!Get.isRegistered<BottomController>()) {
          Get.put(BottomController());
        }

        global.hideLoader();

        Get.offAll(() => BottomNavigationBarScreen(index: 0));
      } else {
        global.hideLoader();
        global.showToast(
          message: result.message ?? 'Failed to sign in',
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
      }
    } catch (e) {
      global.hideLoader();
      developer.log("❌ Login Error: $e");
      global.showToast(
        message: "Login failed. Please try again.",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
    }
  }
}
