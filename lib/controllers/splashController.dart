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
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';

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
  final FastAPIServices fastApiServices = FastAPIServices();

  @override
  void onInit() {
    super.onInit();
    debugPrint("[SPLASH] 🟢 SplashController onInit()");
    _init();
  }

  // =====================================================
  // API-BASED FORCE UPDATE CHECK
  // =====================================================
  Future<bool> _checkForceUpdate() async {
    debugPrint("[SPLASH] 🔍 Force update check started");

    try {
      final info = await PackageInfo.fromPlatform();

      // Safely parse build number
      int installedBuild = 0;
      if (info.buildNumber.isNotEmpty) {
        installedBuild = int.tryParse(info.buildNumber) ?? 0;
      }

      debugPrint("[SPLASH] 📱 Current build: $installedBuild");

      // Fetch version info from API
      final versionData = await fastApiServices.fetchAppVersion();

      if (versionData != null) {
        final int requiredBuild = versionData['android_min_build'] ?? 0;
        final bool forceUpdate = versionData['force_update'] ?? false;
        final String updateMessage = versionData['update_message'] ?? 'New version available';
        final String playStoreUrl = versionData['play_store_url'] ??
            'https://play.google.com/store/apps/details?id=com.jyotishi2025.user';

        debugPrint("[SPLASH] 📡 API → required=$requiredBuild, force=$forceUpdate");

        // Check if update is needed
        if (installedBuild < requiredBuild && forceUpdate) {
          debugPrint("[SPLASH] ⚠️ Force update required! Showing dialog");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpdateDialog(
              message: updateMessage,
              storeUrl: playStoreUrl,
            );
          });
          return true; // Block navigation
        } else if (installedBuild < requiredBuild && !forceUpdate) {
          debugPrint("[SPLASH] ℹ️ Optional update available (not forced)");
          // Optional: Show non-blocking update prompt here if desired
        } else {
          debugPrint("[SPLASH] ✅ App is up to date");
        }
      } else {
        // Fallback to hardcoded value if API fails
        debugPrint("[SPLASH] ⚠️ API failed, using fallback check");
        const int fallbackRequired = 17;

        if (installedBuild < fallbackRequired) {
          debugPrint("[SPLASH] ⚠️ Fallback: Update required");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpdateDialog(
              message: "A new version is available. Please update to continue.",
              storeUrl: "https://play.google.com/store/apps/details?id=com.jyotishi2025.user",
            );
          });
          return true;
        }
      }

      return false; // No update needed

    } catch (e) {
      debugPrint("[SPLASH] ❌ Update check failed: $e");
      return false; // Continue even if check fails
    }
  }

  // =====================================================
  // UPDATE DIALOG - REDIRECTS TO PLAY STORE
  // =====================================================
  void _showUpdateDialog({
    required String message,
    required String storeUrl,
  }) {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button
        child: AlertDialog(
          title: const Text(
            "Update Available",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("A new version of Jyotishi Online is available."),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(storeUrl);
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

    // Check for updates FIRST using API
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