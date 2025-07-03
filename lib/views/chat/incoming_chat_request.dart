// ignore_for_file: must_be_immutable

import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/chat/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/bottomNavigationController.dart';
import '../../controllers/timer_controller.dart';
import '../bottomNavigationBarScreen.dart';

class IncomingChatRequest extends StatelessWidget {
  final String? profile;
  final String? astrologerName;
  final String fireBasechatId;
  final int astrologerId;
  final dynamic chatId;
  final String? fcmToken;
  String duration;
  IncomingChatRequest({
    super.key,
    this.profile,
    this.astrologerName,
    required this.fireBasechatId,
    required this.astrologerId,
    required this.chatId,
    this.fcmToken,
    required this.duration,
  });
  final ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "Incoming chat request from",
                style: Get.textTheme.bodyLarge,
              ).tr(),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Get.theme.primaryColor,
                    backgroundImage: AssetImage('assets/images/splash.png'),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    '${global.getSystemFlagValue(global.systemFlagNameList.appName)}',
                    style: Get.textTheme.headlineSmall,
                  ).tr(),
                ],
              )
            ],
          ),
          Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                child: profile == ""
                    ? Image.asset(
                        Images.deafultUser,
                        fit: BoxFit.fill,
                        height: 50,
                        width: 40,
                      )
                    : CachedNetworkImage(
                        imageUrl: '${global.imgBaseurl}$profile',
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 48, backgroundImage: imageProvider),
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.asset(
                          Images.deafultUser,
                          fit: BoxFit.fill,
                          height: 50,
                          width: 40,
                        ),
                      ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                astrologerName == "" ? 'Astrologer' : astrologerName ?? "",
                style: Get.textTheme.headlineSmall,
              ).tr(),
            ],
          ),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await chatController.acceptedChat(chatId);
                  global.callOnFcmApiSendPushNotifications(
                      fcmTokem: [fcmToken], title: 'Start simple chat timer');
                  chatController.isInchat = true;
                  chatController.isEndChat = false;
                  TimerController timerController = Get.find<TimerController>();
                  timerController.startTimer();
                  chatController.update();
                  Get.to(() => AcceptChatScreen(
                        flagId: 1,
                        astrologerName: astrologerName ?? "Astrologer",
                        profileImage: '$profile',
                        fireBasechatId: fireBasechatId,
                        astrologerId: astrologerId,
                        chatId: chatId,
                        fcmToken: fcmToken,
                        duration: duration.toString(),
                      ));
                },
                icon: Icon(Icons.chat),
                label: Text("Start chat").tr(),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                  padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_chatdataAvailable', false);
                  await prefs.setString('chatdata', '');
                  global.showOnlyLoaderDialog(context);
                  await chatController.rejectedChat(chatId.toString());
                  global.hideLoader();
                  global.callOnFcmApiSendPushNotifications(
                      fcmTokem: [fcmToken], title: 'End chat from customer');
                  BottomNavigationController bottomNavigationController =
                  Get.find<BottomNavigationController>();
                  bottomNavigationController.setIndex(0, 0);
                  Get.to(() => BottomNavigationBarScreen(
                    index: 0,
                  ));
                },
                child: Text(
                  "Reject Chat Request",
                  style: Get.textTheme.bodyMedium!
                      .copyWith(color: Colors.red, fontSize: 12),
                ).tr(),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
