import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/model/current_user_model.dart';
import 'package:AstrowayCustomer/model/systemFlagModel.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';

class SplashController extends GetxController {
  // =====================================================
  // STATE (KEEPED)
  // =====================================================
  CurrentUserModel? currentUser;
  String currentLanguageCode = 'en';
  String? version;
  double? totalGst;
  var syatemFlag = <SystemFlag>[]; // ✅ REQUIRED
  String? appShareLinkForLiveSreaming;

  final APIHelper apiHelper = APIHelper();

  // =====================================================
  // INIT
  // =====================================================
  @override
  void onInit() {
    super.onInit();
    debugPrint("[SPLASH] 🟢 SplashController onInit()");
    _init();
  }

  // =====================================================
  // FORCE UPDATE
  // =====================================================
  Future<bool> _checkForceUpdate() async {
    debugPrint("[SPLASH] 🔍 Force update check started");

    final info = await PackageInfo.fromPlatform();
    final int installed = int.parse(info.buildNumber);
    const int required = 5;

    debugPrint("[SPLASH] 📦 Version → installed=$installed required=$required");

    if (installed < required) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: const Text("Update Required"),
              content: const Text(
                "A new version of the app is available. Please update to continue.",
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse(
                      "https://play.google.com/store/apps/details?id=com.jyotishi2025.user",
                    );
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  child: const Text("Update"),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      });
      return true;
    }

    debugPrint("[SPLASH] ✅ No force update needed");
    return false;
  }

  // =====================================================
  // MAIN FLOW (FINAL & SAFE)
  // =====================================================
  Future<void> _init() async {
    debugPrint("[SPLASH] 🚀 _init() started");

    final blocked = await _checkForceUpdate();
    if (blocked) return;

    // Language
    global.sp = await SharedPreferences.getInstance();
    currentLanguageCode = global.sp!.getString('currentLanguage') ?? 'en';
    global.sp!.setString('currentLanguage', currentLanguageCode);
    debugPrint("[SPLASH] 🌐 Language = $currentLanguageCode");

    Timer(const Duration(seconds: 3), () async {
      debugPrint("[SPLASH] ⏱ Splash delay completed");

      final hasSession = await _hasFastApiSession();
      debugPrint("[SPLASH] 🔐 Session exists = $hasSession");

      if (!hasSession) {
        debugPrint("[SPLASH] ➡ Redirecting to Login");
        Get.off(() => LoginScreen());
        return;
      }

      // ✅ SESSION EXISTS → GO HOME (NO VALIDATION)
      debugPrint("[SPLASH] 🏠 Navigating to Home");

      Get.find<BottomNavigationController>().setIndex(0, 0);
      Get.off(() => BottomNavigationBarScreen(index: 0));

      // Load flags AFTER navigation
      getSystemFlag();
    });
  }

  // =====================================================
  // SESSION CHECK (FASTAPI ONLY)
  // =====================================================
  Future<bool> _hasFastApiSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final userId = prefs.getString("user_id");

    debugPrint("[AUTH] access_token = $token");
    debugPrint("[AUTH] user_id = $userId");

    return token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty;
  }

  // =====================================================
  // SYSTEM FLAGS (SAFE)
  // =====================================================
  Future<void> getSystemFlag() async {
    try {
      debugPrint("[SPLASH] 🌐 Loading system flags");

      final ok = await global.checkBody();
      if (!ok) return;

      final apiResult = await apiHelper.getSystemFlag();
      if (apiResult != null && apiResult.status == "200") {
        syatemFlag = apiResult.recordList;
        update();
        debugPrint("[SPLASH] ✅ System flags loaded");
      }
    } catch (e) {
      debugPrint("[SPLASH] ❌ getSystemFlag error: $e");
    }
  }
}
