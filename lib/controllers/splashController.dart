import 'dart:async';
import 'dart:convert';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';

import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/model/current_user_model.dart';
import 'package:AstrowayCustomer/model/systemFlagModel.dart';
import 'package:AstrowayCustomer/utils/global.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:AstrowayCustomer/views/settings/termsAndConditionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/astrologerProfile/astrologerProfile.dart';
import '../views/bottomNavigationBarScreen.dart';
import '../views/call/accept_call_screen.dart';
import '../views/call/incoming_call_request.dart';
import '../views/call/oneToOneVideo/onetooneVideo.dart';
import '../views/chat/incoming_chat_request.dart';

class SplashController extends GetxController {
  APIHelper apiHelper = APIHelper();

  // User and system-related data
  CurrentUserModel? currentUser;
  String appName = "";
  String currentLanguageCode = 'en';
  String? version;
  double? totalGst;

  // Flags and shared preferences
  var syatemFlag = <SystemFlag>[];
  String? appShareLinkForLiveSreaming;

  @override
  void onInit() {
    _inIt(); // Custom initializer
    super.onInit();
  }

  /// Main Splash logic executed on app start
  _inIt() async {
    await getSystemFlag(); // Load system flags
    appName =
        global.getSystemFlagValueForLogin(global.systemFlagNameList.appName);

    global.sp = await SharedPreferences.getInstance();

    // Set or get language code
    currentLanguageCode = global.sp!.getString('currentLanguage') ?? 'en';
    global.sp!.setString('currentLanguage', currentLanguageCode);

    update();

    // Wait for splash screen duration
    Timer(const Duration(seconds: 3), () async {
      try {
        // ✅ Check if terms have been accepted
        bool termsAccepted = global.sp!.getBool('termsAccepted') ?? false;

        if (!termsAccepted) {
          // If not accepted, go to Terms & Conditions screen
          Get.off(() => const TermAndConditionScreen());
          return;
        }

        // ✅ Check if user is already logged in
        bool isLogin = await global.isLogin();

        if (isLogin) {
          PackageInfo.fromPlatform().then((info) {
            version = info.version;
            update();
          });

          await global.checkBody().then((result) async {
            if (result) {
              await apiHelper.validateSession().then((result) async {
                if (result.status == "200") {
                  currentUser = result.recordList;
                  global.saveUser(currentUser!);
                  global.user = currentUser!;

                  await getCurrentUserData();
                  await global.getCurrentUser();

                  _loadsaveChatData();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadSavedData();
                  });

                  if (global.generalPayload != null) {
                    Map<String, dynamic> payload =
                        json.decode(global.generalPayload);
                    Map<String, dynamic> body = jsonDecode(payload['body']);

                    switch (body["notificationType"]) {
                      case 1: // Call
                        if (body['call_type'].toString() == "11") {
                          Get.to(() => OneToOneLiveScreen(
                                channelname: body["channelName"],
                                callId: body["callId"],
                                fcmToken: body["token"],
                                end_time: body['call_duration'].toString(),
                              ));
                        } else {
                          Get.to(() => IncomingCallRequest(
                                astrologerId: body["astrologerId"],
                                astrologerName:
                                    body["astrologerName"] ?? "Astrologer",
                                astrologerProfile: body["profile"] ?? "",
                                token: body["token"],
                                channel: body["channelName"],
                                callId: int.parse(body["callId"].toString()),
                                fcmToken: body["fcmToken"] ?? "",
                                duration: body['call_duration'].toString(),
                              ));
                        }
                        break;

                      case 3: // Chat
                        Get.to(() => IncomingChatRequest(
                              astrologerName:
                                  body["astrologerName"] ?? "Astrologer",
                              profile: body["profile"] ?? "",
                              fireBasechatId: body["firebaseChatId"],
                              chatId: int.parse(body["chatId"].toString()),
                              astrologerId: body["astrologerId"],
                              fcmToken: body["fcmToken"],
                              duration: body['chat_duration'].toString(),
                            ));
                        break;

                      case 4: // Profile
                        Get.find<ReviewController>()
                            .getReviewData(body["astrologerId"]);
                        await Get.find<BottomNavigationController>()
                            .getAstrologerbyId(body["astrologerId"]);
                        Get.to(() => AstrologerProfile(index: 0));
                        break;

                      default:
                        Get.find<BottomNavigationController>().setIndex(1, 0);
                        Get.off(() => BottomNavigationBarScreen(index: 1));
                        break;
                    }
                  } else {
                    Get.find<BottomNavigationController>().setIndex(0, 0);
                    Get.off(() => BottomNavigationBarScreen(index: 0));
                  }
                } else {
                  await _resetToLogin();
                }
              });
            }
          });
        } else {
          PackageInfo.fromPlatform().then((info) {
            version = info.version;
            update();
          });
          Get.off(() => LoginScreen());
        }
      } catch (e) {
        print('Exception in _inIt(): ${e.toString()}');
      }
    });
  }

  Future<void> _resetToLogin() async {
    PackageInfo.fromPlatform().then((info) {
      version = info.version;
      update();
    });

    HomeController homeController = Get.find<HomeController>();
    global.sp = await SharedPreferences.getInstance();
    global.sp!.clear();

    global.user = CurrentUserModel();
    homeController.myOrders.clear();

    Get.off(() => LoginScreen());
  }

  /// Restore incoming or accepted call from SharedPreferences
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    bool? isAccepted = await prefs.getBool('is_accepted');
    if (isAccepted == true) {
      String? acceptedData = await prefs.getString('is_accepted_data');
      if (acceptedData != null && acceptedData.isNotEmpty) {
        await prefs.setBool('is_accepted', false);
        await prefs.setString('is_accepted_data', '');
        callAccept(jsonDecode(acceptedData));
      }
    }

    bool? isRejected = await prefs.getBool('is_rejected');
    if (isRejected == true) {
      await prefs.setBool('is_accepted', false);
      await prefs.setString('is_accepted_data', '');
    }
  }

  /// Restore pending chat request
  void _loadsaveChatData() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isChatDataAvailable = await prefs.getBool('is_chatdataAvailable');

    if (isChatDataAvailable == true) {
      await prefs.setBool('is_chatdataAvailable', false);
      String? chatDataJson = await prefs.getString('chatdata');
      if (chatDataJson != null) {
        Map<String, dynamic> chatData = jsonDecode(chatDataJson);
        _handleNotificationNavigation(chatData);
      }
    }
  }

  /// Navigate to chat request from payload
  void _handleNotificationNavigation(Map<String, dynamic> chatData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chatdata', '');

    if (chatData.containsKey('body')) {
      Map<String, dynamic> body = jsonDecode(chatData['body']);
      if (body["notificationType"] == 3) {
        Get.to(() => IncomingChatRequest(
              astrologerName: body["astrologerName"] ?? "Astrologer",
              profile: body["profile"] ?? "",
              fireBasechatId: body["firebaseChatId"],
              chatId: int.parse(body["chatId"].toString()),
              astrologerId: body["astrologerId"],
              fcmToken: body["fcmToken"],
              duration: body['chat_duration'].toString(),
            ));
      }
    }
  }

  /// Fetch and save current user data again
  getCurrentUserData() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          global.sp = await SharedPreferences.getInstance();
          await apiHelper.getCurrentUser().then((result) {
            if (result.status == "200") {
              currentUser = result.recordList;
              global.saveUser(currentUser!);
              global.user = currentUser!;
              update();
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getCurrentUserData(): ${e.toString()}');
    }
  }

  /// Fetch system flags like app name, links, etc.
  /// Fetch system flags like app name, links, etc.
  getSystemFlag() async {
    try {
      bool result = await global.checkBody();

      if (result) {
        global.sp = await SharedPreferences.getInstance();
        var apiResult = await apiHelper.getSystemFlag();

        if (apiResult != null && apiResult.status == "200") {
          syatemFlag = apiResult.recordList;
          update();
        } else {
          print("SystemFlag fetch failed or returned invalid data.");
        }
      }
    } catch (e) {
      print('Exception in getSystemFlag(): ${e.toString()}');
    }
  }

  /// Share app via link
  Future<void> createAstrologerShareLink() async {
    try {
      await FlutterShare.share(
        title:
            'Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)}...',
        text:
            'Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)}...',
        linkUrl: '$appShareLinkForLiveSreaming',
      );
    } catch (e) {
      print("Exception - createAstrologerShareLink(): ${e.toString()}");
    }
  }
}

/// Static function to accept a call even when app is launched from background
@pragma('vm:entry-point')
void callAccept(Map<String, dynamic> extraData) async {
  final callController = Get.find<CallController>();

  if (extraData['call_type'] == 10) {
    await callController.acceptedCall(extraData["callId"]);
    Get.to(() => AcceptCallScreen(
          astrologerId: extraData["astrologerId"],
          astrologerName: extraData["astrologerName"] ?? "Astrologer",
          astrologerProfile: extraData["profile"] ?? "",
          token: extraData["token"],
          callChannel: extraData["channelName"],
          callId: extraData["callId"],
          duration: extraData['call_duration'].toString(),
        ));
  } else if (extraData['call_type'] == 11) {
    Get.to(() => OneToOneLiveScreen(
          channelname: extraData["channelName"],
          callId: extraData["callId"],
          fcmToken: extraData["token"].toString(),
          end_time: extraData['call_duration'].toString(),
        ));
  }
}
