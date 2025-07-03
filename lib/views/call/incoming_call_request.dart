// ignore_for_file: deprecated_member_use

import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/call/accept_call_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;


import '../../controllers/bottomNavigationController.dart';
import '../bottomNavigationBarScreen.dart';

// ignore: must_be_immutable
class IncomingCallRequest extends StatelessWidget {
  final String? astrologerName;
  final String? astrologerProfile;
  final int astrologerId;
  final int callId;
  final String token;
  final String channel;
  final String fcmToken;
  String duration;

  IncomingCallRequest({super.key, this.astrologerName, required this.fcmToken, required this.callId, this.astrologerProfile, required this.astrologerId, required this.token, required this.channel,required this.duration});
  CallController callController = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
        bottomNavigationController.setIndex(1, 0);
        Get.to(() => BottomNavigationBarScreen(index: 1));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Get.theme.primaryColor,
                          radius: 50,
                          child: astrologerProfile == ""
                              ? Image.asset(
                                  Images.deafultUser,
                                  fit: BoxFit.fill,
                                  height: 50,
                                  width: 40,
                                )
                              : CachedNetworkImage(
                                  imageUrl: '${global.imgBaseurl}$astrologerProfile',
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                    radius: 48,
                                    backgroundImage: imageProvider,
                                  ),
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
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
                          astrologerName == null || astrologerName == "" ? "Astrologer" : astrologerName ?? "Astrologer",
                          style: Get.textTheme.headlineSmall,
                        ).tr(),
                      ],
                    ),
                    Text(
                      "Please accept call request",
                      style: Get.textTheme.bodyLarge,
                    ).tr(),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Get.theme.primaryColor,
                      backgroundImage: AssetImage("assets/images/splash.png"),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      '${global.getSystemFlagValue(global.systemFlagNameList.appName)}',
                      style: Get.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () async {
                            global.showOnlyLoaderDialog(context);
                            await callController.rejectedCall(callId);
                            global.callOnFcmApiSendPushNotifications(fcmTokem: [fcmToken], title: 'Reject call request from astrologer');
                            global.hideLoader();
                            BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
                            bottomNavigationController.setIndex(0, 0);
                            Get.to(() => BottomNavigationBarScreen(
                                  index: 0,
                                ));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            global.showOnlyLoaderDialog(context);
                            await callController.acceptedCall(callId);
                            global.hideLoader();
                            Get.to(() => AcceptCallScreen(
                                  astrologerId: astrologerId,
                                  astrologerName: astrologerName == null || astrologerName == "" ? "Astrologer" : astrologerName ?? "Astrologer",
                                  astrologerProfile: astrologerProfile,
                                  token: token,
                                  callChannel: channel,
                                  callId: callId,
                                   duration: duration,
                                ));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(left: 20),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(30)),
                            child: Icon(
                              Icons.ring_volume,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
