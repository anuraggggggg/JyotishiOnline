import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/customer_support_controller.dart';
import 'package:AstrowayCustomer/controllers/fastApiProvider/GetAllAstrologerProvider.dart';
import 'package:AstrowayCustomer/controllers/fastApiProvider/WalletProvider.dart';
import 'package:AstrowayCustomer/controllers/liveController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/themeController.dart';
import 'package:AstrowayCustomer/theme/nativeTheme.dart';
import 'package:AstrowayCustomer/utils/CallUtils.dart';
import 'package:AstrowayCustomer/utils/FallbackLocalizationDelegate.dart'; // Keep this for now, we'll address it later if needed
import 'package:AstrowayCustomer/utils/binding/networkBinding.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:AstrowayCustomer/utils/global.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/audioCall/newAudioCall.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:AstrowayCustomer/views/call/accept_call_screen.dart';
import 'package:AstrowayCustomer/views/call/incoming_call_request.dart';
import 'package:AstrowayCustomer/views/call/oneToOneVideo/onetooneVideo.dart';
import 'package:AstrowayCustomer/views/chat/chat_screen.dart';
import 'package:AstrowayCustomer/views/chat/incoming_chat_request.dart';
import 'package:AstrowayCustomer/views/chat/newChatScreen.dart';
import 'package:AstrowayCustomer/views/chat/video_call_page.dart';
import 'package:AstrowayCustomer/views/live_astrologer/live_astrologer_screen.dart';
import 'package:AstrowayCustomer/views/splashScreen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'controllers/fastApiProvider/GetOnlineAstrologerProvider.dart';
import 'controllers/fastApiProvider/LiveAstrologerProvider.dart';
import 'controllers/splashController.dart';
import 'controllers/timer_controller.dart';
import 'fastApi/fastApiServices.dart';
import 'firebase_options.dart';
import 'newglobal.dart';

bool isWeb = false;

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final _localNotifications = FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("_firebaseMessagingBackgroundHandler a background message: ${message.messageId}");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔥 Firebase Project ID: ${Firebase.app().options.projectId}");
  print("🔥 Sender ID: ${Firebase.app().options.messagingSenderId}");
  print("🔥 App ID: ${Firebase.app().options.appId}");

  await GetStorage.init();

  global.sp = await SharedPreferences.getInstance();
  if (global.sp!.getString("currentUser") != null) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    global.generalPayload = json.encode(message.data['body']);
    var messageData;
    if (message.data['body'] != null) {
      messageData = json.decode((message.data['body']));
    }
    if (message.data["title"] ==
        "For starting the timer in other audions for video and audio") {
      Future.delayed(Duration(milliseconds: 500)).then((value) async {
        // await _localNotifications.cancelAll();
      });
      if (liveController.isImInLive == true) {
        int waitListId = int.parse(message.data["waitListId"].toString());
        String channelName = message.data['channelName'];
        liveController.joinUserName = message.data['name'] ?? "User";
        liveController.joinUserProfile = message.data['profile'] ?? "";
        await liveController.getWaitList(channelName);

        int index5 = liveController.waitList
            .indexWhere((element) => element.id == waitListId);
        if (index5 != -1) {
          liveController.endTime = DateTime.now().millisecondsSinceEpoch +
              1000 * int.parse(liveController.waitList[index5].time);
          liveController.update();
        }
      }
    } else if (message.data["title"] == "For Live accept/reject") {
      Future.delayed(Duration(milliseconds: 500)).then((value) async {
        // await _localNotifications.cancelAll();
      });
      if (liveController.isImInLive == true) {
        String astroName = message.data["astroName"];
        int astroId = message.data['astroId'] != null
            ? int.parse(message.data['astroId'].toString())
            : 0;
        String channel = message.data['channel'];
        String token = message.data['token'];
        String astrologerProfile = message.data['astroProfile'] ?? "";
        String requestType = message.data['requestType'];
        int id = message.data['id'] != null
            ? int.parse(message.data['id'].toString())
            : 0;
        double charge = message.data['charge'] != null
            ? double.parse(message.data['charge'].toString())
            : 0;
        double videoCallCharge = message.data['videoCallCharge'] != null
            ? double.parse(message.data['videoCallCharge'].toString())
            : 0;
        String astrologerFcmToken =
            message.data['fcmToken'] != null ? message.data['fcmToken'] : "";
        await bottomController.getAstrologerbyId(astroId);
        bool isFollow = bottomController.astrologerbyId[0].isFollow!;
        // not show notification just show dialog for accept/reject for live stream
        liveController.accpetDeclineContfirmationDialogForLiveStreaming(
          astroId: astroId,
          astroName: astroName,
          channel: channel,
          token: token,
          requestType: requestType,
          id: id,
          charge: charge,
          astrologerFcmToken2: astrologerFcmToken,
          astrologerProfile: astrologerProfile,
          videoCallCharge: videoCallCharge,
          isFollow: isFollow,
        );
      }
    } else if (message.data["title"] ==
        "For accepting time while user already splitted") {
      Future.delayed(Duration(milliseconds: 500)).then((value) async {
        // await _localNotifications.cancelAll();
      });
      int timeInInt = int.parse(message.data["timeInInt"].toString());

      liveController.endTime = DateTime.now().millisecondsSinceEpoch +
          1000 * int.parse(timeInInt.toString());
      liveController.joinUserName = message.data["joinUserName"] ?? "";
      liveController.joinUserProfile = message.data["joinUserProfile"] ?? "";
      liveController.update();
    } else if (message.data["title"] ==
        "Notification for customer support status update") {
      Future.delayed(Duration(milliseconds: 500)).then((value) async {
        // await _localNotifications.cancelAll();
      });
      var message1 = jsonDecode(message.data['body']);
      if (customerSupportController.isIn) {
        customerSupportController.status = message1["status"] ?? "WAITING";
        customerSupportController.update();
      }
    } else if (message.data["title"] == "End chat from astrologer") {
      Future.delayed(Duration(milliseconds: 500)).then((value) async {
        // await _localNotifications.cancelAll();
      });
      chatController.showBottomAcceptChat = false;
      global.sp = await SharedPreferences.getInstance();
      global.sp!.remove('chatBottom');
      global.sp!.setInt('chatBottom', 0);
      chatController.chatBottom = false;
      chatController.isAstrologerEndedChat = true;
      chatController.update();
    } else if (message.data["title"] == "Astrologer Leave call") {
      Future.delayed(Duration(milliseconds: 500)).then((value) async {
        // await _localNotifications.cancelAll();
      });
      callController.showBottomAcceptCall = false;
      global.sp!.remove('callBottom');
      global.sp!.setInt('callBottom', 0);
      callController.callBottom = false;
      callController.update();
    } else if (messageData['notificationType'] == 4) {
      await bottomController.getLiveAstrologerList();
      bottomController.liveAstrologer = bottomController.liveAstrologer;
      bottomController.update();
      if (messageData['isFollow'] == 1) {
        //1 means user follow that astrologer
      } else {
        Future.delayed(Duration(milliseconds: 500)).then((value) async {
          // await _localNotifications.cancelAll();
        });
      }
    } else if (messageData['notificationType'] == 3) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_chatdataAvailable', true);
      String extraDataJson = jsonEncode(message.data);
      await prefs.setString('chatdata', extraDataJson); // Save the data
      foregroundNotificatioCustomAuddio(message);

      chatController.showBottomAcceptChatRequest(
        astrologerId: messageData["astrologerId"],
        chatId: messageData["chatId"],
        astroName: messageData["astrologerName"] == null
            ? "Astrologer"
            : messageData["astrologerName"],
        astroProfile:
            messageData["profile"] == null ? "" : messageData["profile"],
        firebaseChatId: messageData["firebaseChatId"],
        fcmToken: messageData["fcmToken"],
        duration: messageData['call_duration'],
      );
    } else if (messageData['notificationType'] == 1) {
      log('notificationType background :- ${messageData["notificationType"]}');

      CallUtils.showIncomingCall(messageData);
      initforbackground();

      callController.showBottomAcceptCallRequest(
        channelName: messageData["channelName"] ?? "",
        astrologerId: messageData["astrologerId"] ?? 0,
        callId: messageData["callId"],
        token: messageData["token"] ?? "",
        astroName: messageData["astrologerName"] ?? "Astrologer",
        astroProfile: messageData["profile"] ?? "",
        fcmToken: messageData["fcmToken"] ?? "",
        callType: messageData["call_type"],
      );
    } else if (messageData['notificationType'] == 14) {
      Future.delayed(Duration(milliseconds: 500)).then((value) async {
        // await _localNotifications.cancelAll();
      });
      await bottomController.getLiveAstrologerList();
    } else {
      foregroundNotification(message, message.data['icon'] ?? "");
    }
  } else {
    Future.delayed(Duration(milliseconds: 500)).then((value) async {
      // await _localNotifications.cancelAll();
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Initialize Firebase FIRST
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("🔥 Firebase Project ID: ${Firebase.app().options.projectId}");
  print("🔥 Sender ID: ${Firebase.app().options.messagingSenderId}");
  print("🔥 App ID: ${Firebase.app().options.appId}");

  // 🚀 Get FCM Token (NOW it works correctly)
  String? token = await FirebaseMessaging.instance.getToken();
  print("✅ Latest FCM Token: $token");

  // Store token in global
  updateFcmToken(token ?? "");

  global.sp = await SharedPreferences.getInstance();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  if (kIsWeb) isWeb = true;

  // 🚀 Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🚀 Request Notification Permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 🚀 Create Notification Channel (VERY IMPORTANT)
  const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
    'astroway_main_channel',
    'Astroway Notifications',
    description: "High importance notifications for Astroway",
    importance: Importance.max,
    playSound: true,

  );

  final FlutterLocalNotificationsPlugin localNotif =
  FlutterLocalNotificationsPlugin();

  await localNotif
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(mainChannel);

  // Allow notifications in foreground
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Set locale
  final String? storedLang = global.sp!.getString('currentLanguage');
  final String? storedCountry = global.sp!.getString('currentCountry');

  Locale startLocale = (storedLang != null && storedCountry != null)
      ? Locale(storedLang, storedCountry)
      : const Locale('ml', 'IN');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => WalletProvider(FastAPIServices())),
        ChangeNotifierProvider(
            create: (_) => GetAllAstrologerProvider()),
        ChangeNotifierProvider(
          create: (_) => LiveAstrologerProvider(),
        ),

        ChangeNotifierProvider(create: (_) => GetOnlineAstrologerProvider())
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('hi', 'IN'),
          Locale('bn', 'IN'),
          Locale('es', 'ES'),
          Locale('gu', 'IN'),
          Locale('kn', 'IN'),
          Locale('ml', 'IN'),
          Locale('mr', 'IN'),
          Locale('ta', 'IN'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        startLocale: startLocale,
        child: MyApp(),
      ),
    ),
  );
}




class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

final bottomController = Get.put(BottomNavigationController());
final liveController = Get.put(LiveController());
final customerSupportController = Get.put(CustomerSupportController());
final chatController = Get.put(ChatController());
final callController = Get.put(CallController());
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'astroway_main_channel',
  'Astroway Notifications',
  importance: Importance.max,
  playSound: true,
);


class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    // 🔥 Foreground Notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 Foreground message received");
      print("🔔 Title: ${message.notification?.title}");
      print("📝 Body: ${message.notification?.body}");
      print("📦 Data: ${message.data}");

      final data = message.data;

      // ------------------ AUDIO CALL ACCEPT -------------------
      if (data["type"] == "audio_accept") {
        _handleAudioAccept(data);
        return;
      }

      // ------------------ VIDEO CALL ACCEPT -------------------
      if (data["type"] == "video_accept") {
        _handleVideoAccept(data);
        return;
      }

      // ------------------ CHAT ACCEPT -------------------
      if (data["type"] == "chat_accept") {
        // _handleChatAccept(data);
        return;
      }

      // ------------------ NORMAL NOTIFICATION -------------------
      final FlutterLocalNotificationsPlugin fln =
      FlutterLocalNotificationsPlugin();

      fln.show(
        0,
        message.notification?.title ?? "New Notification",
        message.notification?.body ?? "",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'astroway_main_channel',
            'Astroway Notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    });



    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("📲 Notification tapped: ${message.data}");
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onSelectNotification(json.encode(message.data));
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        global.generalPayload = json.encode(message.data);
        log('initial msg in firebase is ${message.data}');
      }
    });

    initializeCallKitEventHandlers();
  }

  @override
  void dispose() {
    print('main - ondispose called');

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Perform cleanup or save state
      print("App is detached and disposed");
    }
  }

  ThemeController themeController = Get.put(ThemeController());
  SplashController splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<SplashController>(builder: (s) {
        return ResponsiveSizer(
          builder: (context, orientation, deviceType) {
            return GetMaterialApp(
              navigatorKey: Get.key,
              debugShowCheckedModeBanner: false,
              enableLog: true,
              theme: nativeTheme(),
              initialBinding: NetworkBinding(),
              locale: context.locale,
              localizationsDelegates: [
                ...context.localizationDelegates,
                // Make sure FallbackLocalizationDelegate is correctly implemented
                // or remove it if not needed for initial troubleshooting
                FallbackLocalizationDelegate()
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('hi', 'IN'),
                Locale('bn', 'IN'),
                Locale('es', 'ES'),
                Locale('gu', 'IN'),
                Locale('kn', 'IN'),
                Locale('ml', 'IN'),
                Locale('mr', 'IN'), //marathi
                Locale('ta', 'IN'),
              ],
              title: 'Jyotishi Online',
              initialRoute: "SplashScreen",
              home: SplashScreen(),
            );
          },
        );
      });
    });
  }
}

// void _handleChatAccept(Map<String, dynamic> data) {
//   final requestId = data["request_id"]?.toString() ?? "";
//
//   print("📌 Chat request_id → $requestId");
//
//   if (requestId.isEmpty) {
//     print("❌ ERROR: request_id missing in chat_accept");
//     return;
//   }
//
//   Future.delayed(const Duration(milliseconds: 300), () {
//     Get.to(() => CustomerChatPage(requestId: requestId));
//   });
// }






// Handler
Future<void> _handleVideoAccept(Map<String, dynamic> data) async {
  final astroId = (data["astro_id"] ?? data["astrologerUid"] ?? "").toString();
  debugPrint("📌 FINAL astrologerUid (video) → $astroId");

  if (astroId.isEmpty) {
    debugPrint("❌ ERROR: astro_id missing in video_accept");
    return;
  }

  // Prefer channel/token/account/appId straight from push payload if present
  String channelFromPush = (data['agora_channel'] ?? data['room_id'] ?? data['roomId'] ?? '').toString();
  String tokenFromPush = (data['agora_token'] ?? data['token'] ?? '').toString();
  String accountFromPush = (data['agora_account'] ?? data['account'] ?? data['user'] ?? '').toString();
  String appIdFromPush = (data['appID'] ?? data['appId'] ?? data['agora_appid'] ?? '').toString();
  final requestId = (data['request_id'] ?? data['requestId'] ?? '').toString();

  // If push contains channel info, navigate immediately with overrides (best-case)
  if (channelFromPush.isNotEmpty) {
    debugPrint("🔔 Push contains channel -> navigating: channel=$channelFromPush tokenPresent=${tokenFromPush.isNotEmpty} account=$accountFromPush appId=$appIdFromPush");
    Get.to(() => CustomerVideoCallPage(
      astroId: astroId,
      overrideRoomId: channelFromPush,
      overrideToken: tokenFromPush.isNotEmpty ? tokenFromPush : null,
      overrideAccount: accountFromPush.isNotEmpty ? accountFromPush : null,
      overrideAppId: appIdFromPush.isNotEmpty ? appIdFromPush : null,
    ));
    return;
  }

  // If push gave a request_id, fetch that exact session object from server (preferred)
  if (requestId.isNotEmpty) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearer = prefs.getString('access_token') ?? '';
      final uri = Uri.parse("https://fastapi.jyotishionline.com/api/v1/$requestId");

      debugPrint("🔎 Fetching session by request_id -> GET $uri");
      final resp = await http.get(uri, headers: {
        "accept": "application/json",
        if (bearer.isNotEmpty) "Authorization": "Bearer $bearer",
      });

      if (resp.statusCode == 200) {
        final Map<String, dynamic> session = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint("✅ Session fetched id=${session['id']} room_id=${session['room_id']} status=${session['status']}");

        final roomId = (session['room_id'] ?? session['agora_channel'] ?? '').toString();
        final agoraToken = (session['agora_token'] ?? session['token'] ?? session['current_user_token'] ?? '').toString();
        final agoraAccount = (session['agora_account'] ?? session['user_account'] ?? session['current_user_id'] ?? '').toString();
        final appId = (session['appID'] ?? session['appId'] ?? '').toString();

        if (roomId.isNotEmpty) {
          debugPrint("➡️ Navigating with room_id=$roomId tokenPresent=${agoraToken.isNotEmpty} account=$agoraAccount appId=$appId");
          Get.to(() => CustomerVideoCallPage(
            astroId: astroId,
            overrideRoomId: roomId,
            overrideToken: (agoraToken.isNotEmpty ? agoraToken : null),
            overrideAccount: (agoraAccount.isNotEmpty ? agoraAccount : null),
            overrideAppId: (appId.isNotEmpty ? appId : null),
          ));
          return;
        } else {
          debugPrint("⚠️ Session returned but no room_id/agora_channel present. session JSON keys: ${session.keys.toList()}");
        }
      } else {
        debugPrint("⚠️ Failed to fetch session $requestId: ${resp.statusCode} ${resp.body}");
      }
    } catch (e, st) {
      debugPrint("⚠️ Exception fetching session by id: $e\n$st");
    }
  } else {
    debugPrint("⚠️ No request_id present in push; will try polling fallback.");
  }

  // 3) Fallback: short polling (only if you have a valid list endpoint)
  const int maxAttempts = 5;
  const Duration delayBetween = Duration(seconds: 1);
  bool found = false;
  Map<String, dynamic>? matchedSession;

  for (int attempt = 1; attempt <= maxAttempts && !found; attempt++) {
    try {
      debugPrint("🔎 Polling for sessions for astro ($astroId) — attempt $attempt/$maxAttempts");
      final prefs = await SharedPreferences.getInstance();
      final bearer = prefs.getString('access_token') ?? '';

      final uri = Uri.parse("https://fastapi.jyotishionline.com/api/v1/sessions")
          .replace(queryParameters: {"astrologer_id": astroId});
      final resp = await http.get(uri, headers: {
        "accept": "application/json",
        if (bearer.isNotEmpty) "Authorization": "Bearer $bearer",
      });

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body is List) {
          debugPrint("🔎 sessions fetched: count=${body.length}");
          final match = body.firstWhere(
                (s) =>
            s is Map<String, dynamic> &&
                (s["session_type"] == "video_call") &&
                (s["status"] == "pending" || s["status"] == "accepted"),
            orElse: () => null,
          );
          if (match != null && match is Map<String, dynamic>) {
            matchedSession = match;
            found = true;
            debugPrint("✅ Found matching session (id=${matchedSession['id']}, room_id=${matchedSession['room_id']})");
            break;
          }
        } else {
          debugPrint("⚠️ Unexpected sessions payload (not a list): ${resp.body}");
        }
      } else {
        debugPrint("⚠️ Failed to fetch sessions: ${resp.statusCode} ${resp.body}");
        if (resp.statusCode == 405) {
          debugPrint("❌ Server responded 405 for sessions list — polling aborted.");
          break;
        }
      }
    } catch (e, st) {
      debugPrint("⚠️ Exception while polling sessions: $e\n$st");
    }

    await Future.delayed(delayBetween);
  }

  if (!found || matchedSession == null) {
    debugPrint("❌ Could not find a matching video session for astro=$astroId after fallback. Aborting navigation.");
    return;
  }

  final roomId = (matchedSession['room_id'] ?? matchedSession['agora_channel'] ?? '').toString();
  final agoraToken = (matchedSession['agora_token'] ?? matchedSession['token'] ?? matchedSession['current_user_token'] ?? '').toString();
  final agoraAccount = (matchedSession['agora_account'] ?? matchedSession['user_account'] ?? matchedSession['current_user_id'] ?? '').toString();
  final appId = (matchedSession['appID'] ?? matchedSession['appId'] ?? '').toString();

  if (roomId.isNotEmpty) {
    debugPrint("➡️ Navigating to CustomerVideoCallPage with session room_id=$roomId tokenPresent=${agoraToken.isNotEmpty} account=$agoraAccount appId=$appId");
    Get.to(() => CustomerVideoCallPage(
      astroId: astroId,
      overrideRoomId: roomId,
      overrideToken: (agoraToken.isNotEmpty ? agoraToken : null),
      overrideAccount: (agoraAccount.isNotEmpty ? agoraAccount : null),
      overrideAppId: (appId.isNotEmpty ? appId : null),
    ));
  } else {
    debugPrint("❌ Matching session found but no room_id present. Aborting.");
  }
}



void _handleAudioAccept(Map<String, dynamic> data) {
  final astroId = (data["astro_id"] ?? data["astrologerUid"] ?? "").toString();
  debugPrint("📌 FINAL astrologerUid → $astroId");

  if (astroId.isEmpty) {
    debugPrint("❌ ERROR: astro_id missing in audio_accept");
    return;
  }

  // Extract overrides that may be present in the push
  final channelFromPush = (data['agora_channel'] ?? data['room_id'] ?? data['roomId'] ?? '').toString();
  final tokenFromPush = (data['agora_token'] ?? data['token'] ?? '').toString();
  final accountFromPush = (data['agora_account'] ?? data['agora_account'] ?? data['user'] ?? '').toString();
  final appIdFromPush = (data['appID'] ?? data['appId'] ?? '').toString();
  int? timerFromPush;
  try {
    final t = data['timer'] ?? data['duration'] ?? data['expireIn'];
    if (t != null) timerFromPush = int.tryParse(t.toString());
  } catch (_) {}

  debugPrint("🔔 audio_accept payload overrides -> channel:$channelFromPush tokenPresent:${tokenFromPush.isNotEmpty} account:$accountFromPush appId:$appIdFromPush timer:$timerFromPush");

  Future.delayed(const Duration(milliseconds: 300), () {
    Get.to(() => AudioCallPage(
      otherUserId: astroId,
      overrideChannel: channelFromPush.isNotEmpty ? channelFromPush : null,
      overrideToken: tokenFromPush.isNotEmpty ? tokenFromPush : null,
      overrideAccount: accountFromPush.isNotEmpty ? accountFromPush : null,
      overrideAppId: appIdFromPush.isNotEmpty ? appIdFromPush : null,
      overrideTimerSeconds: timerFromPush,
    ));
  });
}



void _showChatAcceptPopup(Map data) {
  if (Get.context == null) return;

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Chat Accepted", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("The astrologer has accepted your chat request."),
        actions: [
          TextButton(
            child: Text("Start Chat"),
            onPressed: () {
              Navigator.pop(context);

              Get.to(() => CustomerChatPage(
                roomId: data["roomId"],
                astrologerUid: data["astrologerUid"],
                myUserId: data["myUserId"],
                astrologerName: data["astrologerName"],
                token: data["token"],
                chatRate: double.tryParse(data["chatRate"].toString()) ?? 0,
              ));
            },
          ),
        ],
      );
    },
  );
}



void _showVideoAcceptPopup(Map data) {
  if (Get.context == null) return;

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Video Call Accepted", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("The astrologer has accepted your video call. Please continue."),
        actions: [
          TextButton(
            child: Text("Continue"),
            onPressed: () {
              Navigator.pop(context);

              Get.to(() => CustomerVideoCallPage(
                astroId: data["astro_id"],
              ));
            },
          ),
        ],
      );
    },
  );
}



  void _showAudioAcceptPopup(Map data) {
    if (Get.context == null) return;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Audio Call Accepted", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("The astrologer has accepted your audio call. Please continue."),
          actions: [
            TextButton(
              child: Text("Continue"),
              onPressed: () {
                Navigator.pop(context);

                print("📌 Notification Data → $data");

                final astroId = data["astrologerUid"]?.toString() ?? "";
                print("📌 FINAL astrologerUid → $astroId");

                Get.to(() => AudioCallPage(
                  otherUserId: data["astrologerUid"].toString(),
                ));
              },
            ),
          ],
        );
      },
    );
  }






@pragma('vm:entry-point')
void initializeCallKitEventHandlers() {
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    if (event == null) return;
    switch (event.event) {
      case Event.actionCallStart:
        print('actionCallStart call incoming');
        break;
      case Event.actionCallAccept:
        final prefs = await SharedPreferences.getInstance();

        print('actionCallAccept call incoming');
        await prefs.setBool('is_accepted', false);
        await prefs.setString('is_accepted_data', '');

        callAccept(event);
        break;
      case Event.actionCallDecline:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_accepted', false);
        await prefs.setString('is_accepted_data', '');

        global.callOnFcmApiSendPushNotifications(
            fcmTokem: [event.body['extra']["fcmToken"]],
            title: 'End chat from customer');
        callController.update();
        await chatController
            .rejectedChat(event.body['extra']["callId"].toString());
        callController.update();

        print('call rejected');
        await chatController.rejectedChat(event.body['extra']['callId']);

        break;
      case Event.actionCallCallback:
        print('actionCallCallback call incoming click');
        callAccept(event);
        break;
      case Event.actionCallIncoming:
        print('actionCallIncoming call incoming click');

      case Event.actionCallCustom:
        print('actionCallIncoming call incoming click');

        break;
      default:
        break;
    }
  });
}

@pragma('vm:entry-point')
void initforbackground() async {
  final prefs = await SharedPreferences.getInstance();

  debugPrint('inside initforbackground');
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    debugPrint('inside initforbackground $event');

    if (event == null) {
      await prefs.setBool('is_accepted', false);
      await prefs.setBool('is_rejected', false);

      return;
    }

    switch (event.event) {
      case Event.actionCallStart:
        print('actionCallStart call incoming');
        break;
      case Event.actionCallAccept:
        print('actionCallAccept call incoming');
        await prefs.setBool('is_accepted', true);
        String extraDataJson = jsonEncode(event.body['extra']);
        print('actionCallAccept extraDataJson $extraDataJson');
        await prefs.setString('is_accepted_data', extraDataJson);

        break;
      case Event.actionCallDecline:
        print('call rejected');
        await chatController.rejectedChat(event.body['extra']['callId']);

        await prefs.setBool('is_rejected', true);
        await prefs.setBool('is_accepted', false);
        await prefs.setBool('is_rejected', false);
        await prefs.setString('is_accepted_data', '');

        break;
      case Event.actionCallCallback:
        print('actionCallCallback initforbackground call incoming click');

        break;

      case Event.actionCallTimeout:
        print('actionCallTimeout initforbackground call incoming click');
        await prefs.setBool('is_accepted', false);
        await prefs.setBool('is_rejected', false);
        await prefs.setString('is_accepted_data', '');
        break;

      default:
        break;
    }
  });
}

@pragma('vm:entry-point')
void callAccept(CallEvent event) async {
  log('extra call astrologerId ${event.body['extra']['astrologerId']}');
  log('extra call astrologerName ${event.body['extra']['astrologerName']}');
  log('extra call call_type ${event.body['extra']['call_type']}');
  log('extra call channelName ${event.body['extra']['channelName']}');
  log('extra call callId ${event.body['extra']['callId']}');
  log('extra call profile ${event.body['extra']['profile']}');
  log('extra call call_duration ${event.body['extra']['call_duration']}');
  log('extra call token ${event.body['extra']['token']}');

  if (event.body['extra']['call_type'] == 10) {
    await callController.acceptedCall(event.body['extra']["callId"]);
    Get.to(() => AcceptCallScreen(
          astrologerId: event.body['extra']["astrologerId"],
          astrologerName: event.body['extra']["astrologerName"] == null
              ? "Astrologer"
              : event.body['extra']["astrologerName"],
          astrologerProfile: event.body['extra']["profile"] == null
              ? ""
              : event.body['extra']["profile"],
          token: event.body['extra']["token"],
          callChannel: event.body['extra']["channelName"],
          callId: event.body['extra']["callId"],
          duration: event.body['extra']['call_duration'].toString(),
        ));
  } else if (event.body['extra']['call_type'] == 11) {
    Get.to(() => OneToOneLiveScreen(
          channelname: event.body['extra']["channelName"],
          callId: event.body['extra']["callId"],
          fcmToken: event.body['extra']["token"].toString(),
          end_time: event.body['extra']['call_duration'].toString(),
        ));
  }
}

///custom notification
Future<void> foregroundNotificatioCustomAuddio(RemoteMessage payload) async {
  final initializationSettingsDarwin = DarwinInitializationSettings(
    defaultPresentBadge: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
    defaultPresentSound: false,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      return;
    },
  );

  log('payload is ${payload.data['title']}');
  log('payload description 1 ${payload.data['description']}');

  final android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  final initialSetting = InitializationSettings(
      android: android, iOS: initializationSettingsDarwin);
  FlutterLocalNotificationsPlugin().initialize(initialSetting,
      onDidReceiveNotificationResponse: (_) {
    log('foregroundNotificatioCustomAuddio tap');

    onSelectNotification(json.encode(payload.data));
  });
  final customSound = 'app_sound.wav';
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'astroway_main_channel',        // SAME ID everywhere
    'Astroway Notifications',       // SAME name
    importance: Importance.max,     // 🔥 required for heads-up
    priority: Priority.high,        // 🔥 required for heads-up
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
    fullScreenIntent: false,        // true only if you want full-screen (like incoming call)
  );



  final iOSDetails = DarwinNotificationDetails(
    sound: customSound,
  );
  final platformChannelSpecifics =
      NotificationDetails(android: androidDetails, iOS: iOSDetails);
  global.sp = await SharedPreferences.getInstance();

  if (global.sp!.getString("currentUser") != null) {
    await FlutterLocalNotificationsPlugin().show(
      10,
      payload.data['title'], //message.data["title"]
      payload.data['description'] ?? '',
      platformChannelSpecifics,
      payload: json.encode(payload.data.toString()),
    );
  }
}

///normal notification

Future<void> foregroundNotification(
    RemoteMessage payload, String imageUrl) async {
  print("foreground notification:- $payload");
  final String? largeIconPath =
      await _downloadAndSaveFile("${imgBaseurl}${imageUrl}", 'largeIcon');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    defaultPresentBadge: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
    defaultPresentSound: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      return;
    },
  );
  AndroidInitializationSettings android =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initialSetting = InitializationSettings(
      android: android, iOS: initializationSettingsDarwin);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initialSetting,
      onDidReceiveNotificationResponse: (_) {
    onSelectNotification(json.encode(payload.data));
  });

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'astroway_main_channel',
    'Astroway Notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );
  global.sp = await SharedPreferences.getInstance();
  if (global.sp!.getString("currentUser") != null) {
    await flutterLocalNotificationsPlugin.show(
      0,
      payload.data["title"],
      payload.data["description"],
      platformChannelSpecifics,
      payload: json.encode(payload.data.toString()),
    );
  }
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

AudioPlayer player = AudioPlayer();
Future<void> onSelectNotification(String payload) async {
  global.sp = await SharedPreferences.getInstance();
  if (global.sp!.getString("currentUser") != null) {
    Map<dynamic, dynamic> messageData;
    try {
      messageData = json.decode(payload);
      Map<dynamic, dynamic> body;
      body = jsonDecode(messageData['body']);
      log("onNotification click");
      log("${body["notificationType"]}");
      log("${body}");
      if (body["notificationType"] == 1) {
        await player.stop();
        body['call_type'].toString() == "11"
            ? Get.to(() => OneToOneLiveScreen(
                  channelname: body["channelName"],
                  callId: body["callId"],
                  fcmToken: body["token"],
                  end_time: body['call_duration'].toString(),
                ))
            : Get.to(() => IncomingCallRequest(
                  astrologerId: body["astrologerId"],
                  astrologerName: body["astrologerName"] == null
                      ? "Astrologer"
                      : body["astrologerName"],
                  astrologerProfile:
                      body["profile"] == null ? "" : body["profile"],
                  token: body["token"],
                  channel: body["channelName"],
                  callId: int.parse(body["callId"].toString()),
                  fcmToken: body["fcmToken"] ?? "",
                  duration: body['call_duration'].toString(),
                ));
      } else if (body["notificationType"] == 3) {
        await player.stop();
        Get.to(() => IncomingChatRequest(
              astrologerName: body["astrologerName"] == null
                  ? "Astrologer"
                  : body["astrologerName"],
              profile: body["profile"] == null ? "" : body["profile"],
              fireBasechatId: body["firebaseChatId"],
              chatId: int.parse(body["chatId"].toString()),
              astrologerId: body["astrologerId"],
              fcmToken: body["fcmToken"],
              duration: body['chat_duration'].toString(),
            ));
      } else if (body["notificationType"] == 4) {
        String? token = body['token'].toString();
        String channelName = body["channelName"].toString();
        String astrologerName = body["name"].toString();
        int astrologerId = int.parse(body["astrologerId"].toString());
        double charge = double.parse(body["charge"].toString());
        double videoCallCharge = double.parse(body["videoCallRate"].toString());
        bottomController.anotherLiveAstrologers = bottomController
            .liveAstrologer
            .where((element) => element.astrologerId != astrologerId)
            .toList();
        bottomController.update();
        await liveController.getWaitList(channelName);
        int index2 = liveController.waitList
            .indexWhere((element) => element.userId == global.currentUserId);
        if (index2 != -1) {
          liveController.isImInWaitList = true;
          liveController.update();
        } else {
          liveController.isImInWaitList = false;
          liveController.update();
        }
        liveController.isImInLive = true;
        liveController.isJoinAsChat = false;
        liveController.isLeaveCalled = false;
        await bottomController.getAstrologerbyId(astrologerId);
        bool isFollow = bottomController.astrologerbyId[0].isFollow!;
        liveController.update();
        Get.to(() => LiveAstrologerScreen(
              token: token,
              channel: channelName,
              astrologerName: astrologerName,
              astrologerId: astrologerId,
              isFromHome: true,
              charge: charge,
              isForLiveCallAcceptDecline: false,
              videoCallCharge: videoCallCharge,
              isFollow: isFollow,
            ));
      } else {
        print('other notification');
        BottomNavigationController bottomNavigationController =
            Get.find<BottomNavigationController>();
        bottomNavigationController.setIndex(1, 0);
        Get.off(() => BottomNavigationBarScreen(index: 1));
      }
    } catch (e) {
      print(
        'Exception in onSelectNotification main.dart:- ${e.toString()}',
      );
    }
  }
}
