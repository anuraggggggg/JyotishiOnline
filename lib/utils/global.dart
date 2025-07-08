//import 'package:flutter/animation.dart';
// ignore_for_file: unused_local_variable, unnecessary_null_comparison, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/model/current_user_model.dart';
import 'package:AstrowayCustomer/model/hororscopeSignModel.dart';
import 'package:AstrowayCustomer/model/systemFlagNameListModel.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:url_launcher/url_launcher.dart';

import '../controllers/loginController.dart';
import '../controllers/networkController.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../views/loginScreen.dart';

String currentLocation = '';
SharedPreferences? sp;
String? currencyISOCode3;
dynamic generalPayload;
SharedPreferences? spLanguage;

String timeFormat = '24';
String? appDeviceId;
String languageCode = 'en';
String? mapBoxAPIKey;
APIHelper apiHelper = APIHelper();
bool isRTL = false;
String status = "WAITING";
CurrentUserModel? currentUserPayment;
CurrentUserModel user = CurrentUserModel();
Color toastBackGoundColor = Colors.green;
Color textColor = Colors.black;
NetworkController networkController = Get.put((NetworkController()));
SplashController splashController = Get.find<SplashController>();
final DateFormat formatter = DateFormat("dd MMM yy, hh:mm a");

String stripeBaseApi = 'https://api.stripe.com/v1';

// String baseUrl = "https://astroway.diploy.in/api";
// String imgBaseurl = "https://astroway.diploy.in/";
// String webBaseUrl = "https://astroway.diploy.in/api/";
// String appMode = "LIVE";

// String baseUrl = "https://jyotishionline.com/astro/api";
// String imgBaseurl = "https://jyotishionline.com/astro/";
// String webBaseUrl = "https://jyotishionline.com/astro/api/";
// String appMode = "LIVE";

// Map<String, dynamic> appParameters = {
//   "LIVE": {
//     "apiUrl": "https://astroway.diploy.in/api",
//     "imageBaseurl": "https://astroway.diploy.in/",
//   },
//   "DEV": {
//     "apiUrl": "http://192.168.29.223:8001/api",
//     "imageBaseurl": "http://192.168.29.223:8001/",
//   }
// };

// Map<String, dynamic> appParameters = {
//   "LIVE": {
//     "apiUrl": "https://jyotishionline.com/astro/api",
//     "imageBaseurl": "https://jyotishionline.com/astro/",
//   },
//   "DEV": {
//     "apiUrl": "http://192.168.29.223:8001/api",
//     "imageBaseurl": "http://192.168.29.223:8001/",
//   }
// };

String baseUrl = "https://jyotishionline.com/api";
String imgBaseurl = "https://jyotishionline.com/";
String webBaseUrl = "https://jyotishionline.com/api/";
String appMode = "LIVE";

Map<String, dynamic> appParameters = {
  "LIVE": {
    "apiUrl": "https://jyotishionline.com/api",
    "imageBaseurl": "https://jyotishionline.com/",
  },
  "DEV": {
    "apiUrl": "http://192.168.29.223:8001/api",
    "imageBaseurl": "http://192.168.29.223:8001/",
  }
};

String agoraChannelName = ""; //valid 24hr
String agoraToken = "";
String channelName = "astrowayLive";
String agoraLiveToken = "";
String liveChannelName = "astrowayLive";
String agoraChatUserId = "astrowayLive";
String chatChannelName = "astrowayLive";
String agoraChatToken = "";
String encodedString = "&&";
Color coursorColor = Color(0xFF757575);
int? currentUserId;
String agoraResourceId = "";
String agoraResourceId2 = "";
String agoraSid1 = "";
String agoraSid2 = "";
String? googleAPIKey;
String lat = "21.124857";
String lng = "73.112610";
var nativeAndroidPlatform = const MethodChannel('nativeAndroid');
int? localUid;
int? localLiveUid;
int? localLiveUid2;
bool isHost = false;

Future<void> callOnFcmApiSendPushNotifications({
  List<String?>? fcmTokem,
  String? subTitle,
  String? fcmToken,
  String? title,
  String? name,
  String? channelname,
  String? profile,
  String? waitListId,
  String? liveChatSUserName,
  String? sessionType,
  String? chatId,
  String? timeInInt,
  String? joinUserName,
  String? joinUserProfile,
}) async {
  var accountCredentials = await loadCredentials();
  var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  var client = http.Client();
  try {
    var credentials = await obtainAccessCredentialsViaServiceAccount(
        ServiceAccountCredentials.fromJson(accountCredentials), scopes, client);
    if (credentials == null) {
      log('Failed to obtain credentials');
      return;
    }
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${credentials.accessToken.data}'
    };
    log("GENERATED TOKEN IS-> ${credentials.accessToken.data}");
    final data = {
      "message": {
        "token": fcmTokem![0].toString(),
        "notification": {"body": subTitle, "title": title},
        "data": {
          "name": name,
          "channelName": channelname,
          "profile": profile,
          "waitListId": waitListId,
          "liveChatSUserName": liveChatSUserName,
          "sessionType": sessionType,
          "chatId": chatId,
          "timeInInt": timeInInt,
          "joinUserName": joinUserName,
          "joinUserProfile": joinUserProfile
        },
        "android": {
          "notification": {"click_action": "android.intent.action.MAIN"}
        }
      }
    };
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/astroway-diploy/messages:send');
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    log('noti response ${response.body}');
    if (response.statusCode == 200) {
      log('Notification sent successfully');
    } else {
      log('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> loadCredentials() async {
  String credentialsPath = 'lib/utils/noti_service.json';
  String content = await rootBundle.loadString(credentialsPath);
  return json.decode(content);
}

//Strip implement finish

Future<void> createAndShareLinkForHistoryChatCall() async {
  try {
    await FlutterShare.share(
      title:
          'Check my call on ${global.getSystemFlagValue(global.systemFlagNameList.appName)} app. You should also try and see your future. First call is free',
      text:
          'Check my call on ${global.getSystemFlagValue(global.systemFlagNameList.appName)} app. You should also try and see your future. First call is free',
      linkUrl: '',
    );
  } catch (e) {
    print("Exception - global.dart - referAndEarn():" + e.toString());
  }
}

Future<void> createAndShareLinkForBloog(String title) async {
  try {
    await FlutterShare.share(
      title: '$title Astroway',
      text: '$title Astroway',
    );
  } catch (e) {
    print("Exception - global.dart - referAndEarn():" + e.toString());
  }
}

createAndShareLinkForDailyHorscope() async {
  await FlutterShare.share(
          title: '${getSystemFlagValueForLogin(systemFlagNameList.appName)}',
          text:
              "Check out your free daily horoscope on ${global.getSystemFlagValue(global.systemFlagNameList.appName)} & plan your day batter ")
      .then((value) {})
      .catchError((e) {
    print(e);
  });
}

abstract class DateFormatter {
  static String? formatDate(DateTime timestamp) {
    if (timestamp == null) {
      return null;
    }
    String date =
        "${timestamp.day} ${DateFormat('MMMM').format(timestamp)} ${timestamp.year}";
    return date;
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static DateTime? toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }
}

showOnlyLoaderDialog(context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        //backgroundColor: Colors.transparent,
        child: kIsWeb
            ? Container(
                width: Get.width * 0.10,
                padding: EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "please wait",
                      style: TextStyle(color: Colors.black),
                    ).tr()
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "please wait",
                      style: TextStyle(color: Colors.black),
                    ).tr()
                  ],
                ),
              ),
      );
    },
  );
}

showSnackBar(String title, String text, {Duration? duration}) {
  return Get.snackbar(title, text,
      dismissDirection: DismissDirection.horizontal,
      showProgressIndicator: true,
      isDismissible: true,
      duration: duration != null ? duration : Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM);
}

void hideLoader() {
  Get.back();
}

Future<bool> checkBody() async {
  bool result;
  try {
    await networkController.initConnectivity();
    if (networkController.connectionStatus.value != 0) {
      result = true;
    } else {
      print(networkController.connectionStatus.value);
      Get.snackbar(
        'Warning',
        'No internet connection',
        snackPosition: SnackPosition.BOTTOM,
        messageText: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.signal_wifi_off,
              color: Colors.white,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                ),
                child: Text(
                  'No internet available',
                  textAlign: TextAlign.start,
                ).tr(),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (networkController.connectionStatus.value != 0) {
                  Get.back();
                }
              },
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.white),
                height: 30,
                width: 55,
                child: Center(
                  child: Text(
                    'Retry',
                    style: TextStyle(color: Get.theme.primaryColor),
                  ).tr(),
                ),
              ),
            )
          ],
        ),
        duration: Duration(days: 1),
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );

      result = false;
    }

    return result;
  } catch (e) {
    print("Exception - checkBodyController - checkBody():" + e.toString());
    return false;
  }
}

//check login
Future<bool> isLogin() async {
  sp = await SharedPreferences.getInstance();
  print("isLoginCheck");
  print("${sp!.getString("token")}");
  print("${sp!.getInt("currentUserId")}");
  print("${currentUserId}");
  if (sp!.getString("token") == null &&
      sp!.getInt("currentUserId") == null &&
      currentUserId == null) {
    Get.to(() => LoginScreen());
    return false;
  } else {
    return true;
  }
}

logoutUser() async {
  await apiHelper.logout();
  sp = await SharedPreferences.getInstance();
  sp!.remove("currentUser");
  sp!.remove("currentUserId");
  sp!.remove("token");
  sp!.remove("tokenType");
  user = CurrentUserModel();
  sp!.clear();
  final LoginController loginController = Get.find<LoginController>();
  loginController.phoneController.clear();
  loginController.update();
  log("current user logout:- ${sp!.getString('currentUserId')}");
  currentUserId = null;
  splashController.currentUser = null;
  Get.off(() => LoginScreen());
}

//save current user
// CurrentUserModel? user;
saveCurrentUser(int id, String token, String tokenType) async {
  try {
    sp = await SharedPreferences.getInstance();
    await sp!.setInt('currentUserId', id);
    await sp!.setString('token', token);
    await sp!.setString('tokenType', tokenType);
  } catch (e) {
    print("Exception - gloabl.dart - saveCurrentUser():" + e.toString());
  }
}

getCurrentUser() async {
  try {
    sp = await SharedPreferences.getInstance();
    currentUserId = sp!.getInt('currentUserId');
    log('user ID is :- $currentUserId');
  } catch (e) {
    print("Exception - gloabl.dart - getCurrentUser():" + e.toString());
  }
}

String appId = kIsWeb
    ? '1'
    : Platform.isAndroid
        ? "1"
        : "1";
AndroidDeviceInfo? androidInfo;
IosDeviceInfo? iosInfo;
WebBrowserInfo? webBrowserInfo;
DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
var appVersion = "1.0.0";
String? deviceId;
String? fcmToken;
String? deviceLocation;
String? deviceManufacturer;
String? deviceModel;
SystemFlagNameList systemFlagNameList = SystemFlagNameList();
List<HororscopeSignModel> hororscopeSignList = [];

String getAppVersion() {
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appVersion = packageInfo.version;
  });
  return appVersion;
}

String getSystemFlagValue(String flag) {
  String value = splashController.currentUser!.systemFlagList!
      .firstWhere((e) => e.name == flag)
      .value;
  return splashController.currentUser!.systemFlagList!
      .firstWhere((e) => e.name == flag)
      .value;
}

String getSystemFlagValueForLogin(String flag) {
  String value =
      splashController.syatemFlag.firstWhere((e) => e.name == flag).value;
  return splashController.syatemFlag.firstWhere((e) => e.name == flag).value;
}

showToast(
    {required String message,
    required Color textColor,
    required Color bgColor}) async {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: bgColor,
    textColor: textColor,
    fontSize: 14.0,
  );
}

Future<Widget> showHtml({
  required String html,
  Map<String, Style>? style,
}) async {
  try {
    return Html(
      data: html,
      style: style ?? {},
    );
  } catch (e) {
    return Html(
      data: html,
      style: style ?? {},
    );
  }
}

Future<BottomNavigationBarItem> showBottom(
    {required String text, required Widget widget}) async {
  return BottomNavigationBarItem(
    icon: widget,
    label: text,
  );
}

Future<InputDecoration> showDecorationHint(
    {required String hint, InputBorder? inputBorder}) async {
  return InputDecoration(hintText: hint, border: inputBorder);
}

Future getDeviceData() async {
  log('in getDeviceData');

  await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appVersion = packageInfo.version;
  });
  if (kIsWeb) {
    if (webBrowserInfo == null) {
      webBrowserInfo = await deviceInfo.webBrowserInfo;
    }
    String browserNameString = 'Unknow browser';
    switch (webBrowserInfo!.browserName) {
      case BrowserName.firefox:
        browserNameString = 'Firefox';
        break;
      case BrowserName.samsungInternet:
        browserNameString = 'Samsung Internet Browser';
        break;
      case BrowserName.opera:
        browserNameString = 'opera';
        break;
      case BrowserName.msie:
        browserNameString = 'msie';
        break;
      case BrowserName.edge:
        browserNameString = 'edge';
        break;
      case BrowserName.chrome:
        browserNameString = 'chrome';
        break;
      case BrowserName.safari:
        browserNameString = 'safari';
        break;
      default:
        browserNameString = 'Unknown browser';
    }
    deviceModel = browserNameString;
    deviceManufacturer = webBrowserInfo!.vendor;
    deviceId = webBrowserInfo!.productSub;
    fcmToken = await FirebaseMessaging.instance.getToken();
    log('fcm token:- $fcmToken');
    log('deviceManufacturer:- $browserNameString');
    log('vendor:- ${webBrowserInfo!.vendor}');
    log('platorm:- ${webBrowserInfo!.platform}');
    log('product snub:- ${webBrowserInfo!.productSub}');

    //webBrowserInfo
  } else {
    if (Platform.isAndroid) {
      if (androidInfo == null) {
        androidInfo = await deviceInfo.androidInfo;
      }
      deviceModel = androidInfo!.model;
      deviceManufacturer = androidInfo!.manufacturer;
      deviceId = androidInfo!.id;
      fcmToken = await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      if (iosInfo == null) {
        iosInfo = await deviceInfo.iosInfo;
      }
      deviceModel = iosInfo!.model;
      deviceManufacturer = "Apple";
      deviceId = iosInfo!.identifierForVendor;
      fcmToken = await FirebaseMessaging.instance.getToken();
    }
  }
}

saveUser(CurrentUserModel user) async {
  try {
    sp = await SharedPreferences.getInstance();
    await sp!.setString('currentUser', json.encode(user.toJson()));
  } catch (e) {
    print("Exception - global.dart - saveUser(): ${e.toString()}");
  }
}

Future<void> share() async {
  await FlutterShare.share(
    title: '1 item',
    text: '1 item',
    chooserTitle: '1 item',
  );
}

//Api Header
Future<Map<String, String>> getApiHeaders(bool authorizationRequired) async {
  Map<String, String> apiHeader = new Map<String, String>();

  if (authorizationRequired) {
    sp = await SharedPreferences.getInstance();
    String tokenType = sp!.getString("tokenType") ?? "Bearer";
    String token = sp!.getString("token") ?? "invalid token";
    print('authentication token :- $token');
    apiHeader.addAll({"Authorization": " $tokenType $token"});
  }
  apiHeader.addAll({"Content-Type": "application/json"});
  apiHeader.addAll({"Accept": "application/json"});
  return apiHeader;
}
// String url = "https://1.envato.market/da0XDM";
// String diployurl = "https://diploy.in";
// warningDialog(BuildContext context) {
//   BuildContext context = Get.context!;
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Container(
//         margin: EdgeInsets.symmetric(horizontal: 2.w),
//         child: AlertDialog(
//           surfaceTintColor: Colors.white,
//           insetPadding: EdgeInsets.symmetric(horizontal: 1.w),
//           backgroundColor: Colors.white,
//           contentPadding: EdgeInsets.zero,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           title: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(1.w),
//                 child: Center(
//                   child: Text(
//                     "Notice: ",
//                     style: Get.theme.textTheme.displayLarge!.copyWith(
//                       color: Colors.black,
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.w600,
//                       fontStyle: FontStyle.normal,
//                     ),
//                   ).tr(),
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(1.w),
//                 child: Center(
//                   child: RichText(
//                     text: TextSpan(
//                       text:
//                       'Beware of scammer & nulled codes. Some websites are using our name & assets to mislead like astroway.in & more (Buy the astroway source code from codecanyon & ',
//                       style: const TextStyle(color: Colors.black),
//                       children: <TextSpan>[
//                         TextSpan(
//                           text: 'diploy.in ',
//                           style: const TextStyle(
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () async {
//                               if (await canLaunch(diployurl)) {
//                                 await launch(diployurl);
//                               } else {
//                                 throw 'Could not launch $diployurl';
//                               }
//                             },
//                         ),
//                         const TextSpan(text: ' at \$96 only: '),
//                         TextSpan(
//                           text: url,
//                           style: const TextStyle(
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () async {
//                               if (await canLaunch(url)) {
//                                 await launch(url);
//                               } else {
//                                 throw 'Could not launch $url';
//                               }
//                             },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Get.back();
//                       // Get.back();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5.w),
//                         side: BorderSide(color: Colors.pink.shade200),
//                       ),
//                       shadowColor: Colors.transparent,
//                     ),
//                     child: Text(
//                       'OK',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.normal,
//                         color: Colors.black,
//                       ),
//                     ).tr(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actionsAlignment: MainAxisAlignment.spaceBetween,
//           actionsPadding:
//           const EdgeInsets.only(bottom: 15, left: 15, right: 15),
//         ),
//       );
//     },
//   );
// }
