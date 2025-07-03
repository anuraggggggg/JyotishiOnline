import 'dart:io';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/settings_controller.dart';
import 'package:AstrowayCustomer/utils/date_converter.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/astrologerProfile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/reviewController.dart';
import '../call/incoming_call_request.dart';
import '../call/oneToOneVideo/onetooneVideo.dart';
import '../chat/incoming_chat_request.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor:
              Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
          title: Text(
            'Notifications',
            style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          ).tr(),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
                kIsWeb
                    ? Icons.arrow_back
                    : Platform.isIOS
                        ? Icons.arrow_back_ios
                        : Icons.arrow_back,
                color: Colors.white //Get.theme.iconTheme.color,
                ),
          ),
          actions: [
            GetBuilder<SettingsController>(builder: (settingsController) {
              return settingsController.notification.isEmpty
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () {
                        Get.defaultDialog(
                            backgroundColor: Colors.white,
                            title: '',
                            titlePadding: EdgeInsets.all(0),
                            content: Text(
                                    'Are you sure you want to delete all notifications?')
                                .tr(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            cancel: TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text(
                                  'CANCEL',
                                  style:
                                      TextStyle(color: Get.theme.primaryColor),
                                ).tr()),
                            confirm: TextButton(
                                onPressed: () {
                                  global.showOnlyLoaderDialog(context);
                                  settingsController.deleteAllNotifications();
                                  global.hideLoader();
                                  Get.back();
                                },
                                child: Text(
                                  'OK',
                                  style:
                                      TextStyle(color: Get.theme.primaryColor),
                                ).tr()));
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 18,
                      ));
            })
          ]),
      body: GetBuilder<SettingsController>(builder: (settingsController) {
        return settingsController.notification.isEmpty
            ? Center(
                child: Text('No Notifications Available').tr(),
              )
            : ListView.builder(
                itemCount: settingsController.notification.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      if (settingsController
                              .notification[index].notificationType ==
                          1) {
                        settingsController.notification[index].callStatus
                                        .toString() ==
                                    "Accepted" &&
                                settingsController.notification[index].callType
                                        .toString() !=
                                    "null"
                            ? (settingsController.notification[index].callType
                                        .toString() ==
                                    "11"
                                ? Get.to(() => OneToOneLiveScreen(
                                      channelname: settingsController
                                          .notification[index].channelName
                                          .toString(),
                                      callId: settingsController
                                              .notification[index].callId ??
                                          0,
                                      fcmToken: settingsController
                                          .notification[index].token
                                          .toString(),
                                      end_time: settingsController
                                          .notification[index].callDuration
                                          .toString(),
                                    ))
                                : Get.to(() => IncomingCallRequest(
                                      astrologerId: settingsController
                                              .notification[index]
                                              .astrologerId ??
                                          0,
                                      astrologerName: settingsController
                                                  .notification[index]
                                                  .astrologerName ==
                                              null
                                          ? "Astrologer"
                                          : settingsController
                                              .notification[index]
                                              .astrologerName,
                                      astrologerProfile: settingsController
                                                  .notification[index]
                                                  .astroprofileImage ==
                                              null
                                          ? ""
                                          : settingsController
                                              .notification[index]
                                              .astroprofileImage,
                                      token: settingsController
                                          .notification[index].token
                                          .toString(),
                                      channel: settingsController
                                          .notification[index].channelName
                                          .toString(),
                                      callId: settingsController
                                              .notification[index].callId ??
                                          0,
                                      fcmToken: settingsController
                                              .notification[index].fcmToken ??
                                          "",
                                      duration: settingsController
                                          .notification[index].callDuration
                                          .toString(),
                                    )))
                            : global.showToast(
                                message: 'You have talked to Astrologer',
                                textColor: global.textColor,
                                bgColor: global.toastBackGoundColor,
                              );
                      } else if (settingsController
                              .notification[index].notificationType ==
                          3) {
                        settingsController.notification[index].chatStatus.toString() ==
                                "Accepted"
                            ? Get.to(() => IncomingChatRequest(
                                astrologerName: settingsController
                                            .notification[index]
                                            .astrologerName ==
                                        null
                                    ? "Astrologer"
                                    : settingsController
                                        .notification[index].astrologerName,
                                profile: settingsController.notification[index]
                                            .astroprofileImage ==
                                        null
                                    ? ""
                                    : settingsController
                                        .notification[index].astroprofileImage,
                                fireBasechatId: settingsController
                                    .notification[index].firebaseChatId
                                    .toString(),
                                chatId: int.parse(settingsController.notification[index].chatId.toString()),
                                astrologerId: settingsController.notification[index].astrologerId ?? 0,
                                fcmToken: settingsController.notification[index].fcmToken.toString(),
                                duration: settingsController.notification[index].chatDuration.toString()))
                            : global.showToast(
                                message: 'You have talked to Astrologer',
                                textColor: global.textColor,
                                bgColor: global.toastBackGoundColor,
                              );
                      } else if (settingsController
                              .notification[index].notificationType ==
                          4) {
                        print('live astrologer');
                        Get.find<ReviewController>().getReviewData(
                            settingsController
                                    .notification[index].astrologerId ??
                                0);
                        await Get.find<BottomNavigationController>()
                            .getAstrologerbyId(settingsController
                                    .notification[index].astrologerId ??
                                0);
                        Get.to(() => AstrologerProfile(index: 0));
                      } else {
                        print('other notification');
                      }
                    },
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 83.w,
                                        child: Text(
                                          settingsController
                                              .notification[index].title!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Get.textTheme.bodyLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                  color: settingsController
                                                                  .notification[
                                                                      index]
                                                                  .callStatus
                                                                  .toString() ==
                                                              "Accepted" ||
                                                          settingsController
                                                                  .notification[
                                                                      index]
                                                                  .chatStatus
                                                                  .toString() ==
                                                              "Accepted"
                                                      ? Colors.black
                                                      : Colors.grey),
                                        ).tr(),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.defaultDialog(
                                          backgroundColor: Colors.white,
                                          title: '',
                                          titlePadding: EdgeInsets.all(0),
                                          content: Text(
                                                  'Are you sure you want to delete  notifications?')
                                              .tr(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 8),
                                          cancel: TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text(
                                                'CANCEL',
                                                style: TextStyle(
                                                    color:
                                                        Get.theme.primaryColor),
                                              ).tr()),
                                          confirm: TextButton(
                                              onPressed: () {
                                                global.showOnlyLoaderDialog(
                                                    context);
                                                settingsController
                                                    .deleteNotifications(
                                                        settingsController
                                                            .notification[index]
                                                            .id!);
                                                global.hideLoader();
                                                Get.back();
                                              },
                                              child: Text(
                                                'OK',
                                                style: TextStyle(
                                                    color:
                                                        Get.theme.primaryColor),
                                              ).tr()));
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                width: 83.w,
                                child: Text(
                                  settingsController
                                      .notification[index].description!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Get.textTheme.bodySmall!.copyWith(
                                      color: settingsController
                                                      .notification[index]
                                                      .callStatus
                                                      .toString() ==
                                                  "Accepted" ||
                                              settingsController
                                                      .notification[index]
                                                      .chatStatus
                                                      .toString() ==
                                                  "Accepted"
                                          ? Colors.black
                                          : Colors.grey),
                                ).tr(),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                    DateConverter.dateTimeStringToDateOnly(
                                        '${settingsController.notification[index].createdAt!}'),
                                    style: Get.textTheme.bodySmall!.copyWith(
                                        fontSize: 10, color: Colors.grey)),
                              )
                            ]),
                      ),
                    ),
                  );
                });
      }),
    );
  }
}
