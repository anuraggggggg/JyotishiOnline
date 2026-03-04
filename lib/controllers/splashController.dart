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

import '../services/location_services.dart';
import '../views/loginWithEmail.dart';

class SplashController extends GetxController {
  CurrentUserModel? currentUser;
  String currentLanguageCode = 'en';
  String? version;
  double? totalGst;
  var systemFlag = <SystemFlag>[];
  String? appShareLinkForLiveStreaming;

  final APIHelper apiHelper = APIHelper();

  @override
  void onInit() {
    super.onInit();
    debugPrint("[SPLASH] 🟢 SplashController onInit()");
    _init();
  }

  // =====================================================
  // SIMPLE FORCE UPDATE CHECK - NO PLUGIN DEPENDENCIES
  // =====================================================
  Future<bool> _checkForceUpdate() async {
    debugPrint("[SPLASH] 🔍 Force update check started");

    try {
      final info = await PackageInfo.fromPlatform();

      // Safely parse build number
      int installed = 0;
      if (info.buildNumber.isNotEmpty) {
        installed = int.tryParse(info.buildNumber) ?? 0;
      }

      // IMPORTANT: Update this number EVERY TIME you publish to Play Store
      const int requiredVersion = 17;

      debugPrint("[SPLASH] 📱 Current build: $installed, Required: $requiredVersion");

      if (installed < requiredVersion) {
        debugPrint("[SPLASH] ⚠️ Update required! Showing dialog");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUpdateDialog();
        });
        return true; // Block navigation
      }

      debugPrint("[SPLASH] ✅ App is up to date");
      return false;

    } catch (e) {
      debugPrint("[SPLASH] ❌ Update check failed: $e");
      return false; // Continue even if check fails
    }
  }

  // =====================================================
  // UPDATE DIALOG - REDIRECTS TO PLAY STORE
  // =====================================================
  void _showUpdateDialog() {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button
        child: AlertDialog(
          title: const Text(
            "Update Available",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("A new version of Jyotishi Online is available."),
              SizedBox(height: 12),
              Text(
                "Please update to continue using the app.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.jyotishi2025.user"
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                "Update Now",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Can't dismiss by tapping outside
    );
  }

  // =====================================================
  // MAIN FLOW
  // =====================================================
  Future<void> _init() async {
    debugPrint("[SPLASH] 🚀 _init() started");

    // Initialize SharedPreferences
    global.sp = await SharedPreferences.getInstance();

    // Check for updates FIRST
    final updateBlocked = await _checkForceUpdate();
    if (updateBlocked) {
      debugPrint("[SPLASH] ⏸ Navigation blocked by update check");
      return;
    }

    // Language setup
    currentLanguageCode = global.sp!.getString('currentLanguage') ?? 'en';
    await global.sp!.setString('currentLanguage', currentLanguageCode);
    debugPrint("[SPLASH] 🌐 Language = $currentLanguageCode");

    // Small delay for splash screen
    Timer(const Duration(seconds: 2), () async {
      debugPrint("[SPLASH] ⏱ Splash delay completed");

      final hasSession = await _hasFastApiSession();
      debugPrint("[SPLASH] 🔐 Session exists = $hasSession");

      if (!hasSession) {
        debugPrint("[SPLASH] ➡ Redirecting to Login");
        if (LocationService.isIndianUser) {
          Get.offAll(() => LoginScreen());
        } else {
          Get.offAll(() => LoginWithEmailScreen());
        }
        return;
      }

      // Navigate to Home
      debugPrint("[SPLASH] 🏠 Navigating to Home");
      Get.find<BottomNavigationController>().setIndex(0, 0);
      Get.off(() => BottomNavigationBarScreen(index: 0));

      // Load system flags
      getSystemFlag();
    });
  }

  Future<bool> _hasFastApiSession() async {
    final token = global.sp!.getString("access_token");
    final userId = global.sp!.getString("user_id");
    return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
  }

  Future<void> getSystemFlag() async {
    try {
      debugPrint("[SPLASH] 🌐 Loading system flags");

      final ok = await global.checkBody();
      if (!ok) return;

      final apiResult = await apiHelper.getSystemFlag();
      if (apiResult != null && apiResult.status == "200") {
        systemFlag = apiResult.recordList;
        update();
        debugPrint("[SPLASH] ✅ System flags loaded");
      }
    } catch (e) {
      debugPrint("[SPLASH] ❌ getSystemFlag error: $e");
    }
  }
}