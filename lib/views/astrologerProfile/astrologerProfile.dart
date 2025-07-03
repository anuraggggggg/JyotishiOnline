// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/controllers/astrologer_assistant_controller.dart';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/follow_astrologer_controller.dart';
import 'package:AstrowayCustomer/controllers/gift_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/controllers/settings_controller.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/userProfileController.dart';
import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/main.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/availabilityScreen.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/chat_with_assistant_screen.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
import 'package:AstrowayCustomer/views/stories/viewStories.dart';
import 'package:AstrowayCustomer/widget/showReviewWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../utils/images.dart';
import '../callIntakeFormScreen.dart';

class AstrologerProfile extends StatefulWidget {
  final int index;
  AstrologerProfile({a, o, required this.index})
      : super();

  @override
  State<AstrologerProfile> createState() => _AstrologerProfileState();
}

class _AstrologerProfileState extends State<AstrologerProfile> {
  BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();

  final ReviewController reviewController = Get.find<ReviewController>();

  WalletController walletController = Get.find<WalletController>();


  SplashController splashController = Get.find<SplashController>();


  HomeController homeController = Get.find<HomeController>();

  BottomNavigationController bottomNavigationController2 =
      Get.find<BottomNavigationController>();


  Future<void> dialogForJoinInWaitList(
      context, String astrologerName, bool forChat,String status) async {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.white,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Get.theme.primaryColor,
                child: CachedNetworkImage(
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  imageUrl:
                  "${global.imgBaseurl}${bottomNavigationController2.astrologerbyId[0].profileImage}",
                  imageBuilder: (context, imageProvider) {
                    return CircleAvatar(
                      radius: 35,
                      backgroundColor: Get.theme.primaryColor,
                      backgroundImage: imageProvider,
                    );
                  },
                  placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) {
                    return Container(
                      child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Get.theme.primaryColor,
                          child: Image.asset(
                            Images.deafultUser,
                            fit: BoxFit.fill,
                            height: 50,
                          )),
                    );
                  },
                ),
              ),
              Container(
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "$astrologerName",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ).tr(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  status.toString()=="Offline"? 'You can not talk to astrologer because astrologer is Currently Offline':(status.toString()=="Busy"?
                  'You can not talk to astrologer because astrologer is Currently Busy':"You can not talk to astrologer because astrologer is Currently in Break"),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15.sp,
                  ),
                  textAlign: TextAlign.center,
                ).tr(),
              ),
              Container(
                width: Get.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.w),
                              side: BorderSide(color: Colors.pink.shade200),
                            ),
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ).tr(),
                        ),
                      ),
                    ),

                    // GestureDetector(
                    //   onTap: () {
                    //     Get.back();
                    //   },
                    //   child: Container(
                    //     padding: EdgeInsets.only(
                    //       left: 20,
                    //       bottom: 10,
                    //       top: 10,
                    //       right: 20,
                    //     ),
                    //     decoration: BoxDecoration(
                    //         color: Colors.grey[300],
                    //         borderRadius:
                    //             BorderRadius.all(Radius.circular(10))),
                    //     child: Text(
                    //       "Cancel",
                    //       style: TextStyle(color: Colors.black),
                    //     ).tr(),
                    //   ),
                    // ),
                    // GestureDetector(
                    //   onTap: () async {
                    //     Get.back();
                    //     if (forChat == true) {
                    //       await bottomNavigationController.checkAlreadyInReq(
                    //           bottomNavigationController.astrologerbyId[0].id!);
                    //       if (bottomNavigationController
                    //               .isUserAlreadyInChatReq ==
                    //           false) {
                    //         global.showOnlyLoaderDialog(Get.context);
                    //         if (bottomNavigationController
                    //                 .astrologerbyId[0].chatWaitTime !=
                    //             null) {
                    //           if (bottomNavigationController
                    //                   .astrologerbyId[0].chatWaitTime!
                    //                   .difference(DateTime.now())
                    //                   .inMinutes <
                    //               0) {
                    //             await bottomNavigationController
                    //                 .changeOfflineStatus(
                    //                     bottomNavigationController
                    //                         .astrologerbyId[0].id!,
                    //                     "Online");
                    //           }
                    //         }
                    //         double charge = double.parse(
                    //             bottomNavigationController
                    //                 .astrologerbyId[0].charge!
                    //                 .toString());
                    //         if (charge * 5 <=
                    //                 global.splashController.currentUser!
                    //                     .walletAmount! ||
                    //             bottomNavigationController
                    //                     .astrologerbyId[0].isFreeAvailable ==
                    //                 true) {
                    //           await Get.to(() => CallIntakeFormScreen(
                    //                 type: "Chat",
                    //                 astrologerId: bottomNavigationController
                    //                     .astrologerbyId[0].id!,
                    //                 astrologerName: bottomNavigationController
                    //                     .astrologerbyId[0].name!,
                    //                 astrologerProfile:
                    //                     bottomNavigationController
                    //                         .astrologerbyId[0].profileImage!,
                    //                 isFreeAvailable: bottomNavigationController
                    //                     .astrologerbyId[0].isFreeAvailable!,
                    //               ));
                    //         }
                    //         global.hideLoader();
                    //       } else {
                    //         bottomNavigationController
                    //             .dialogForNotCreatingSession(Get.context);
                    //       }
                    //     } else {
                    //       await bottomNavigationController
                    //           .checkAlreadyInReqForCall(
                    //               bottomNavigationController
                    //                   .astrologerbyId[0].id!);
                    //       if (bottomNavigationController
                    //               .isUserAlreadyInCallReq ==
                    //           false) {
                    //         global.showOnlyLoaderDialog(context);
                    //         //need to check for already in req list
                    //         if (bottomNavigationController
                    //                 .astrologerbyId[0].callWaitTime !=
                    //             null) {
                    //           if (bottomNavigationController
                    //                   .astrologerbyId[0].callWaitTime!
                    //                   .difference(DateTime.now())
                    //                   .inMinutes <
                    //               0) {
                    //             await bottomNavigationController
                    //                 .changeOfflineCallStatus(
                    //                     bottomNavigationController
                    //                         .astrologerbyId[0].id!,
                    //                     "Online");
                    //           }
                    //         }
                    //         double charge = double.parse(
                    //             bottomNavigationController
                    //                 .astrologerbyId[0].charge!
                    //                 .toString());
                    //         if (charge * 5 <=
                    //                 global.splashController.currentUser!
                    //                     .walletAmount! ||
                    //             bottomNavigationController
                    //                     .astrologerbyId[0].isFreeAvailable! ==
                    //                 true) {
                    //           await Get.to(() => CallIntakeFormScreen(
                    //                 astrologerProfile:
                    //                     bottomNavigationController
                    //                         .astrologerbyId[0].profileImage!,
                    //                 type: "Call",
                    //                 astrologerId: bottomNavigationController
                    //                     .astrologerbyId[0].id!,
                    //                 astrologerName: bottomNavigationController
                    //                     .astrologerbyId[0].name!,
                    //                 isFreeAvailable: bottomNavigationController
                    //                     .astrologerbyId[0].isFreeAvailable!,
                    //               ));
                    //         }
                    //         global.hideLoader();
                    //       } else {
                    //         bottomNavigationController
                    //             .dialogForNotCreatingSession(Get.context);
                    //       }
                    //     }
                    //   },
                    //   child: Container(
                    //     padding: EdgeInsets.all(10),
                    //     decoration: BoxDecoration(
                    //         color: Get.theme.primaryColor,
                    //         borderRadius:
                    //             BorderRadius.all(Radius.circular(10))),
                    //     child: Text(
                    //       "Join Waitlist",
                    //       style: TextStyle(color: Colors.white),
                    //     ).tr(),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          );
        });
  }

  @override
  void initState() {

    homeController.getAstroStory(bottomController.astrologerbyId[0].id.toString());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor:
                Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
            title: Text(
              'Profile',
              style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ).tr(),
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                  kIsWeb
                      ? Icons.arrow_back
                      : Platform.isIOS
                          ? Icons.arrow_back_ios
                          : Icons.arrow_back,
                  color: Colors.black //Get.theme.iconTheme.color,
                  ),
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  await FlutterShare.share(
                      title:
                      '${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)}',
                      text:
                      "Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)} to get predictions related to marriage/career. I would recommend you to connect with best Astrologer at ${global.getSystemFlagValue(global.systemFlagNameList.appName)}. ");

                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          Images.whatsapp,
                          height: 40,
                          width: 40,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 9),
                          child: Text('Share',
                                  style: Get.textTheme.titleMedium!.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black))
                              .tr(),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ]),
        body: SingleChildScrollView(
          child: GetBuilder<BottomNavigationController>(builder: (bController) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bottomNavigationController.astrologerbyId[0].isBlock!
                    ? const SizedBox()
                    : SizedBox(
                        height: 10,
                      ),

                GetBuilder<BottomNavigationController>(
                    builder: (bottomNavigationController) {
                  return bottomNavigationController.astrologerbyId[0].isBlock!
                      ? Container(
                          decoration: BoxDecoration(color: Colors.red),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You have blocked the astrologer',
                                style: TextStyle(color: Colors.white),
                              ).tr(),
                              GetBuilder<SettingsController>(
                                  builder: (settingsController) {
                                return TextButton(
                                  onPressed: () async {
                                    global.showOnlyLoaderDialog(context);
                                    await settingsController.unblockAstrologer(
                                        bottomNavigationController
                                            .astrologerbyId[0].id!);
                                    global.hideLoader();
                                  },
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(0)),
                                    fixedSize: MaterialStateProperty.all(
                                        Size.fromWidth(90)),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Unblock',
                                    style: Get.theme.primaryTextTheme.bodySmall,
                                  ).tr(),
                                );
                              })
                            ],
                          ),
                        )
                      : SizedBox();
                }),

                GetBuilder<BottomNavigationController>(
                    builder: (bottomController) {
                  return SizedBox(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child:   GetBuilder<HomeController>(builder: (homeController) {
                                          return InkWell(
                                            onTap: (){
                                              homeController.viewSingleStory.length==0?null:
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (context) => ViewStoriesScreen(profile: "${global.imgBaseurl}${bottomController.astrologerbyId[0].profileImage}",
                                                  name: bottomController.astrologerbyId[0].name.toString(),isprofile: true,
                                                astroId:int.parse(bottomController.astrologerbyId[0].id.toString()) ,)),
                                              );
                                            },
                                            child: Container(
                                                height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(36),
                                                  border: Border.all(

                                                      width: 4,
                                                      color:homeController.viewSingleStory.length==0?Colors.grey: Get.theme.primaryColor)),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(36),
                                               // backgroundColor: Colors.white,
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      "${global.imgBaseurl}${bottomController.astrologerbyId[0].profileImage}",
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget: (context, url, error) {
                                                    return CircleAvatar(
                                                        radius: 35,
                                                        backgroundColor: Colors.white,
                                                        child: Image.asset(
                                                          Images.deafultUser,
                                                          fit: BoxFit.fill,
                                                          height: 50,
                                                        ));
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      ),
                                    ),
                                    bottomController.astrologerbyId[0].isFollow!
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .blue, //Get.theme.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                'Following',
                                                style: Get.textTheme.bodyMedium!
                                                    .copyWith(
                                                        fontSize: 10,
                                                        color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ).tr(),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: GetBuilder<
                                                      FollowAstrologerController>(
                                                  builder:
                                                      (followAstrologerController) {
                                                return InkWell(
                                                  onTap: () async {
                                                    log('message');
                                                    bool isLogin =
                                                        await global.isLogin();
                                                    if (isLogin) {
                                                      global
                                                          .showOnlyLoaderDialog(
                                                              context);
                                                      await followAstrologerController
                                                          .addFollowers(
                                                              bottomNavigationController
                                                                  .astrologerbyId[
                                                                      0]
                                                                  .id!);
                                                      global.hideLoader();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .blue, //Get.theme.primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Text(
                                                      'Follow',
                                                      style: Get
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.white),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ).tr(),
                                                  ),
                                                );
                                              }),
                                            )),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              bottomController
                                                  .astrologerbyId[0].name!,
                                            ).tr(),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Image.asset(
                                              Images.right,
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                        bottomController.astrologerbyId[0]
                                                    .primarySkill ==
                                                ""
                                            ? const SizedBox()
                                            : Text(
                                                '${bottomController.astrologerbyId[0].primarySkill!}',
                                                style: Get.theme
                                                    .primaryTextTheme.bodySmall!
                                                    .copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.grey[600],
                                                ),
                                              ).tr(),
                                        bottomController.astrologerbyId[0]
                                                    .currentCity ==
                                                ""
                                            ? const SizedBox()
                                            : Text(
                                                bottomController
                                                    .astrologerbyId[0]
                                                    .currentCity!,
                                                style: Get.theme
                                                    .primaryTextTheme.bodySmall!
                                                    .copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.grey[600],
                                                ),
                                              ).tr(),
                                        bottomController.astrologerbyId[0]
                                                    .languageKnown ==
                                                ""
                                            ? const SizedBox()
                                            : Text(
                                                bottomController
                                                    .astrologerbyId[0]
                                                    .languageKnown!,
                                                style: Get.theme
                                                    .primaryTextTheme.bodySmall!
                                                    .copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.grey[600],
                                                ),
                                              ).tr(),
                                        Text(
                                          'Experience : ${bottomController.astrologerbyId[0].experienceInYears} Years',
                                          style: Get
                                              .theme.primaryTextTheme.bodySmall!
                                              .copyWith(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.grey[600],
                                          ),
                                        ).tr(),
                                        Row(
                                          children: [
                                            bottomController.astrologerbyId[0]
                                                        .isFreeAvailable ==
                                                    true
                                                ? Text(
                                                    'FREE',
                                                    style: Get.theme.textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0,
                                                      color: Color.fromARGB(
                                                          255, 167, 1, 1),
                                                    ),
                                                  ).tr()
                                                : const SizedBox(),
                                            SizedBox(
                                              width: bottomController
                                                          .astrologerbyId[0]
                                                          .isFreeAvailable ==
                                                      true
                                                  ? 10
                                                  : 0,
                                            ),
                                            Text(
                                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)}${bottomController.astrologerbyId[0].charge}/min',
                                              style: Get
                                                  .theme.textTheme.titleMedium!
                                                  .copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: 0,
                                                decoration: bottomController
                                                            .astrologerbyId[0]
                                                            .isFreeAvailable ==
                                                        true
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: bottomController
                                                            .astrologerbyId[0]
                                                            .isFreeAvailable ==
                                                        true
                                                    ? Colors.grey
                                                    : Color.fromARGB(
                                                        255, 167, 1, 1),
                                              ),
                                            ).tr(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.grey,
                                    ),
                                    onSelected: (value) async {
                                      if (value == "block") {
                                        bottomController
                                            .blockAstrologerController
                                            .clear();
                                        bool isLogin = await global.isLogin();
                                        if (isLogin) {
                                          Get.dialog(AlertDialog(
                                            backgroundColor: Colors.white,
                                            scrollable: true,
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: GestureDetector(
                                                      onTap: () async {
                                                        Get.back();
                                                      },
                                                      child: Image.asset(
                                                        Images.closeRound,
                                                        height: 25,
                                                        width: 25,
                                                      )),
                                                ),
                                                Text(
                                                  'Report & Block',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ).tr(),
                                              ],
                                            ),
                                            content: SizedBox(
                                              height: Get.height * 0.5,
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 36,
                                                    backgroundColor:
                                                        Get.theme.primaryColor,
                                                    child: CircleAvatar(
                                                      radius: 36,
                                                      backgroundColor:
                                                          Colors.yellow,
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            "${global.imgBaseurl}${bottomController.astrologerbyId[0].profileImage}",
                                                        imageBuilder: (context,
                                                            imageProvider) {
                                                          return CircleAvatar(
                                                            radius: 35,
                                                            backgroundColor:
                                                                Colors.white,
                                                            backgroundImage:
                                                                imageProvider,
                                                          );
                                                        },
                                                        placeholder: (context,
                                                                url) =>
                                                            const Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return CircleAvatar(
                                                              radius: 35,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child:
                                                                  Image.asset(
                                                                Images
                                                                    .deafultUser,
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 50,
                                                              ));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      '${bottomController.astrologerbyId[0].name}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ).tr(),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Center(
                                                      child: Text(
                                                              'Reason for blocking*')
                                                          .tr()),
                                                  TextField(
                                                    controller: bottomController
                                                        .blockAstrologerController,
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    minLines: 3,
                                                    maxLines: 3,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText:
                                                          "Write your reason...",
                                                      helperStyle: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5.0)),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5.0)),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5.0)),
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      global
                                                          .showOnlyLoaderDialog(
                                                              context);
                                                      await bottomController
                                                          .astrologerReportAndBlock(
                                                              bottomController
                                                                  .astrologerbyId[
                                                                      0]
                                                                  .id!);
                                                      global.hideLoader();
                                                      Get.back();
                                                    },
                                                    child: Text('Submit').tr(),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Get.theme
                                                                  .primaryColor),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.black),
                                                    ),
                                                  ),
                                                  Text(
                                                    '*You can unblock the astrologer from settings section.',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ).tr(),
                                                ],
                                              ),
                                            ),
                                          ));
                                        }
                                      }

                                      if (value == "unblock") {
                                        SettingsController settingsController =
                                            Get.find<SettingsController>();
                                        global.showOnlyLoaderDialog(context);
                                        await settingsController
                                            .unblockAstrologer(
                                                bottomNavigationController
                                                    .astrologerbyId[0].id!);
                                        global.hideLoader();
                                      }
                                    },
                                    itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: bottomNavigationController
                                                    .astrologerbyId[0].isBlock!
                                                ? Text('Unblock').tr()
                                                : Text('Report & Block').tr(),
                                            value: bottomNavigationController
                                                    .astrologerbyId[0].isBlock!
                                                ? "unblock"
                                                : "block",
                                          ),
                                        ]),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                            ),
                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      bool isLogin = await global.isLogin();
                                      if (isLogin) {
                                        double charge = double.parse(
                                            bottomNavigationController
                                                .astrologerbyId[0].charge!
                                                .toString());
                                        if (charge * 5 <=
                                                global
                                                    .splashController
                                                    .currentUser!
                                                    .walletAmount! ||
                                            bottomNavigationController
                                                    .astrologerbyId[0]
                                                    .isFreeAvailable ==
                                                true) {
                                          if (bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .chatStatus ==
                                                  "Online" ||
                                              bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .chatStatus ==
                                                  "Wait Time") {
                                            await bottomNavigationController
                                                .checkAlreadyInReq(
                                                    bottomNavigationController
                                                        .astrologerbyId[0].id!);

                                            if (bottomNavigationController
                                                    .isUserAlreadyInChatReq ==
                                                false) {
                                              global.showOnlyLoaderDialog(
                                                  context);
                                              if (bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .chatWaitTime !=
                                                  null) {
                                                if (bottomNavigationController
                                                        .astrologerbyId[0]
                                                        .chatWaitTime!
                                                        .difference(
                                                            DateTime.now())
                                                        .inMinutes <
                                                    0) {
                                                  await bottomNavigationController
                                                      .changeOfflineStatus(
                                                          bottomNavigationController
                                                              .astrologerbyId[0]
                                                              .id!,
                                                          "Online");
                                                }
                                              }

                                              await Get.to(() =>
                                                  CallIntakeFormScreen(
                                                    type: "Chat",
                                                    astrologerId:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .id!,
                                                    astrologerName:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .name!,
                                                    astrologerProfile:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .profileImage!,
                                                    isFreeAvailable:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .isFreeAvailable!,
                                                      rate:bottomNavigationController
                                                          .astrologerbyId[0]
                                                          .charge!.toString()
                                                  ));
                                              global.hideLoader();
                                            } else {
                                              bottomNavigationController
                                                  .dialogForNotCreatingSession(
                                                      context);
                                            }
                                          } else if (bottomNavigationController
                                                  .astrologerbyId[0]
                                                  .chatStatus ==
                                              "Offline") {
                                            dialogForJoinInWaitList(
                                                context,
                                                bottomNavigationController
                                                    .astrologerbyId[0].name!,
                                                true,
                                                bottomNavigationController
                                                    .astrologerbyId[0].chatStatus.toString()
                                            );
                                          }
                                        } else {
                                          global.showOnlyLoaderDialog(context);
                                          await walletController.getAmount();
                                          global.hideLoader();
                                          openBottomSheetRechrage(
                                              context,
                                              (charge * 5).toString(),
                                              'chat',
                                              '${bottomNavigationController.astrologerbyId[0].name}');
                                        }
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat,
                                          color: Colors.grey,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            "${bottomNavigationController.astrologerbyId[0].chatMin!} Mins"),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    thickness: 2,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      bool isLogin = await global.isLogin();
                                      if (isLogin) {
                                        double charge = double.parse(
                                            bottomNavigationController
                                                .astrologerbyId[0].charge!
                                                .toString());
                                        if (charge * 5 <=
                                                global
                                                    .splashController
                                                    .currentUser!
                                                    .walletAmount! ||
                                            bottomNavigationController
                                                    .astrologerbyId[0]
                                                    .isFreeAvailable ==
                                                true) {
                                          if (bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .callStatus ==
                                                  "Online" ||
                                              bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .callStatus ==
                                                  "Wait Time") {
                                            await bottomNavigationController
                                                .checkAlreadyInReqForCall(
                                                    bottomNavigationController
                                                        .astrologerbyId[0].id!);
                                            if (bottomNavigationController
                                                    .isUserAlreadyInCallReq ==
                                                false) {
                                              global.showOnlyLoaderDialog(
                                                  context);
                                              if (bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .callWaitTime !=
                                                  null) {
                                                if (bottomNavigationController
                                                        .astrologerbyId[0]
                                                        .callWaitTime!
                                                        .difference(
                                                            DateTime.now())
                                                        .inMinutes <
                                                    0) {
                                                  await bottomNavigationController
                                                      .changeOfflineCallStatus(
                                                          bottomNavigationController
                                                              .astrologerbyId[0]
                                                              .id!,
                                                          "Online");
                                                }
                                              }
                                              await Get.to(() =>
                                                  CallIntakeFormScreen(
                                                    astrologerProfile:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .profileImage!,
                                                    type: "Call",
                                                    astrologerId:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .id!,
                                                    astrologerName:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .name!,
                                                    isFreeAvailable:
                                                        bottomNavigationController
                                                            .astrologerbyId[0]
                                                            .isFreeAvailable,
                                                      rate:bottomNavigationController
                                                          .astrologerbyId[0]
                                                          .charge.toString()
                                                  ));
                                              global.hideLoader();
                                            } else {
                                              bottomNavigationController
                                                  .dialogForNotCreatingSession(
                                                      context);
                                            }
                                          } else if (bottomNavigationController
                                                  .astrologerbyId[0]
                                                  .callStatus ==
                                              "Offline") {
                                            dialogForJoinInWaitList(
                                                context,
                                                bottomNavigationController
                                                    .astrologerbyId[0].name!,
                                                true,
                                                bottomNavigationController
                                                    .astrologerbyId[0].chatStatus.toString()
                                            );
                                          }
                                        } else {
                                          global.showOnlyLoaderDialog(context);
                                          await walletController.getAmount();
                                          global.hideLoader();
                                          openBottomSheetRechrage(
                                              context,
                                              (charge * 5).toString(),
                                              'call',
                                              '${bottomNavigationController.astrologerbyId[0].name}');
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.grey,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            "${bottomNavigationController.astrologerbyId[0].callMin!} mins"),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(
                  width: Get.width,
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GetBuilder<UserProfileController>(
                          builder: (userProfileController) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bottomNavigationController
                                  .astrologerbyId[0].loginBio!,
                              maxLines:
                                  userProfileController.isShowMore ? null : 2,
                              style: Get.textTheme.titleMedium!
                                  .copyWith(fontSize: 14),
                            ).tr(),
                            InkWell(
                                onTap: () {
                                  userProfileController.showMoreText();
                                },
                                child: Text(
                                  userProfileController.isShowMore
                                      ? "Show less"
                                      : "..Show More",
                                  style: TextStyle(color: Colors.blue),
                                ).tr())
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Card(
                    margin: EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rating & Reviews').tr(),
                              GestureDetector(
                                  onTap: () {
                                    reviewController.reviewList.isNotEmpty
                                        ? showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            backgroundColor: Colors.white,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return ratingAndReview();
                                            })
                                        : global.showToast(
                                            message:
                                                'There is no user review available for this astrologer!',
                                            textColor: global.textColor,
                                            bgColor: global.toastBackGoundColor,
                                          );
                                  },
                                  child: Icon(Icons.arrow_forward,
                                      color: Colors.grey))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${bottomNavigationController.astrologerbyId[0].rating!.toStringAsFixed(2)}',
                                    style: Get.textTheme.headlineMedium,
                                  ),
                                  RatingBar.builder(
                                    initialRating: 0,
                                    itemCount: 5,
                                    allowHalfRating: false,
                                    itemSize: 15,
                                    ignoreGestures: true,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Get.theme.primaryColor,
                                    ),
                                    onRatingUpdate: (rating) {},
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.person,
                                          size: 14, color: Colors.grey),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${bottomNavigationController.astrologerbyId[0].totalOrder!} orders',
                                        style: Get
                                            .theme.primaryTextTheme.bodySmall!
                                            .copyWith(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 9,
                                        ),
                                      ).tr(),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 25,
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '5',
                                          style: Get.textTheme.titleMedium,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200,
                                          lineHeight: 16,
                                          percent: bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .fiveStarRating !=
                                                  null
                                              ? bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .fiveStarRating! *
                                                  0.01
                                              : 0,
                                          progressColor: Colors.green,
                                          barRadius: Radius.circular(20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text('4',
                                            style: Get.textTheme.titleMedium),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200,
                                          lineHeight: 16,
                                          percent: bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .fourStarRating !=
                                                  null
                                              ? bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .fourStarRating! *
                                                  0.01
                                              : 0,
                                          progressColor: Colors.blue,
                                          barRadius: Radius.circular(20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text('3',
                                            style: Get.textTheme.titleMedium),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200,
                                          lineHeight: 16,
                                          percent: bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .threeStarRating !=
                                                  null
                                              ? bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .threeStarRating! *
                                                  0.01
                                              : 0,
                                          progressColor: Color.fromARGB(
                                              255, 135, 172, 235),
                                          barRadius: Radius.circular(20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text('2',
                                            style: Get.textTheme.titleMedium),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200,
                                          lineHeight: 16,
                                          percent: bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .twoStarRating !=
                                                  null
                                              ? bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .twoStarRating! *
                                                  0.01
                                              : 0,
                                          progressColor: Colors.orange,
                                          barRadius: Radius.circular(20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text('1',
                                            style: Get.textTheme.titleMedium),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        LinearPercentIndicator(
                                          width: 200,
                                          lineHeight: 16,
                                          percent: bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .oneStarRating !=
                                                  null
                                              ? bottomNavigationController
                                                      .astrologerbyId[0]
                                                      .astrologerRating!
                                                      .oneStarRating! *
                                                  0.01
                                              : 0,
                                          progressColor: Colors.red,
                                          barRadius: Radius.circular(20),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                reviewController.reviewList.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('User Reviews').tr(),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return ratingAndReview();
                                    });
                              },
                              child: Text(
                                'View All',
                                style: Get.textTheme.bodyMedium!
                                    .copyWith(fontSize: 12, color: Colors.grey),
                              ).tr(),
                            )
                          ],
                        ),
                      )
                    : SizedBox(),

                //Rating Review Page
                GetBuilder<ReviewController>(
                  builder: (controller) {
                    return ListView.builder(
                        itemCount: reviewController.reviewList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ShowReviewWidget(
                            index: index,
                            astologername: bottomNavigationController
                                    .astrologerbyId[0].name ??
                                "Astrologer",
                            astroImage:
                                "${global.imgBaseurl}${bottomController.astrologerbyId[0].profileImage}",
                          );
                        });
                  },
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        backgroundColor: Colors.white,
                        isScrollControlled: true,
                        builder: (context) {
                          return ratingAndReview();
                        });
                  },
                  child: reviewController.reviewList.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6, right: 6),
                          child: Text(
                            'See all reviews',
                            style: Get.textTheme.titleMedium!
                                .copyWith(color: Colors.green),
                          ).tr(),
                        )
                      : SizedBox(),
                ),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        bottomNavigationController.astrologerbyId[0]
                                .similiarConsultant!.isNotEmpty
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Check Similar Astrologer').tr(),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return SimpleDialog(
                                              backgroundColor: Colors.white,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'People who spoke to this Consultant, also spoke to these Consultants. You may try them out!',
                                                    style: Get
                                                        .textTheme.bodyMedium,
                                                  ).tr(),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: Text('Ok').tr(),
                                                      style: ButtonStyle(
                                                        maximumSize:
                                                            MaterialStateProperty
                                                                .all(Size(
                                                                    80, 40)),
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all(Get.theme
                                                                    .primaryColor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Icon(Icons.info),
                                  )
                                ],
                              )
                            : SizedBox(),
                        bottomNavigationController.astrologerbyId[0]
                                .similiarConsultant!.isNotEmpty
                            ? GetBuilder<BottomNavigationController>(
                                builder: (controller) {
                                return SizedBox(
                                  height: 135,
                                  child: Center(
                                    child: ListView.builder(
                                        itemCount: bottomNavigationController
                                            .astrologerbyId[0]
                                            .similiarConsultant!
                                            .length,
                                        scrollDirection: Axis.horizontal,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () async {
                                              log('similar consultant id:- ${bottomNavigationController.astrologerbyId[0].similiarConsultant![index].id!}');
                                              Get.find<ReviewController>()
                                                  .getReviewData(
                                                      bottomNavigationController
                                                          .astrologerbyId[0]
                                                          .similiarConsultant![
                                                              index]
                                                          .id!);
                                              global.showOnlyLoaderDialog(
                                                  context);
                                              await bottomNavigationController
                                                  .getAstrologerbyId(
                                                      bottomNavigationController
                                                          .astrologerbyId[0]
                                                          .similiarConsultant![
                                                              index]
                                                          .id!);
                                              global.hideLoader();
                                            },
                                            child: Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Container(
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: CircleAvatar(
                                                        radius: 36,
                                                        backgroundColor: Get
                                                            .theme.primaryColor,
                                                        child: CircleAvatar(
                                                          radius: 36,
                                                          backgroundColor:
                                                              Colors.yellow,
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                "${global.imgBaseurl}${bottomNavigationController.astrologerbyId[0].similiarConsultant![index].profileImage}",
                                                            imageBuilder: (context,
                                                                imageProvider) {
                                                              return CircleAvatar(
                                                                radius: 35,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundImage:
                                                                    imageProvider,
                                                              );
                                                            },
                                                            placeholder: (context,
                                                                    url) =>
                                                                const Center(
                                                                    child:
                                                                        CircularProgressIndicator()),
                                                            errorWidget:
                                                                (context, url,
                                                                    error) {
                                                              return CircleAvatar(
                                                                  radius: 35,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child: Image
                                                                      .asset(
                                                                    Images
                                                                        .deafultUser,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    height: 40,
                                                                  ));
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      bottomNavigationController
                                                              .astrologerbyId[0]
                                                              .similiarConsultant![
                                                                  index]
                                                              .name ??
                                                          'Astrologer',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Get.theme.textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        letterSpacing: 0,
                                                      ),
                                                    ).tr(),
                                                    Text(
                                                      '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${bottomNavigationController.astrologerbyId[0].similiarConsultant![index].charge}/min',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Get.theme.textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        letterSpacing: 0,
                                                      ),
                                                    ).tr(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                );
                              })
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6),
                  child: Card(
                    margin: EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        InkWell(
                            onTap: () async {
                              bool isLogin = await global.isLogin();
                              if (isLogin) {
                                AstrologerAssistantController
                                    astrologerAssistantController =
                                    Get.find<AstrologerAssistantController>();
                                global.showOnlyLoaderDialog(context);
                                await astrologerAssistantController
                                    .checkPaidSession(bottomNavigationController
                                        .astrologerbyId[0].id!);
                                global.hideLoader();
                                if (astrologerAssistantController
                                    .isPaidSession) {
                                  global.showOnlyLoaderDialog(context);
                                  await astrologerAssistantController
                                      .storeChatId(bottomNavigationController
                                          .astrologerbyId[0].id!);
                                  global.hideLoader();
                                  Get.to(
                                      () => ChatWithAstrologerAssistantScreen(
                                            flagId: 1,
                                            profileImage: '',
                                            astrologerName:
                                                bottomNavigationController
                                                    .astrologerbyId[0].name!,
                                            fireBasechatId:
                                                astrologerAssistantController
                                                    .firebaseChatId,
                                            astrologerId:
                                                bottomNavigationController
                                                    .astrologerbyId[0].id!,
                                            chatId: 1,
                                          ));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(13),
                                          child: SimpleDialog(
                                            backgroundColor: Colors.white,
                                            titlePadding: EdgeInsets.all(8.0),
                                            insetPadding: EdgeInsets.all(8.0),
                                            contentPadding: EdgeInsets.all(8.0),
                                            children: [
                                              Text(
                                                'You can chat with astrologer\'s assistant only when you have taken a paid session with the atrologer',
                                                style: Get.textTheme.bodyMedium,
                                              ).tr(),
                                              Center(
                                                child: SizedBox(
                                                  width: 80,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Text('Ok').tr(),
                                                    style: ButtonStyle(
                                                      maximumSize:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Size(80, 40)),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Get.theme
                                                                  .primaryColor),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                }
                              }
                            },
                            // child: menuItem(Icons.contact_support_outlined,
                            //     "Chat With Assistant")
                                ),
                        GetBuilder<BottomNavigationController>(
                            builder: (bottomController) {
                          return InkWell(
                              onTap: () async {
                                global.showOnlyLoaderDialog(context);
                                await bottomController
                                    .getAstrologerAvailibility(
                                        bottomController.astrologerbyId[0].id!);
                                global.hideLoader();
                                Get.to(() => AvailabilityScreen(
                                      astrologerName: bottomController
                                          .astrologerbyId[0].name!,
                                      astrologerProfile: bottomController
                                          .astrologerbyId[0].profileImage!,
                                    ));
                              },
                              child: menuItem(
                                  Icons.calendar_today, "Availability"));
                        }),
                        GetBuilder<GiftController>(builder: (giftController) {
                          return InkWell(
                            onTap: () async {
                              bool isLogin = await global.isLogin();
                              if (isLogin) {
                                global.showOnlyLoaderDialog(context);
                                await giftController.getGiftData();
                                global.hideLoader();
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Get.theme.primaryColor),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Container(
                                      height: 280,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Send ${bottomNavigationController.astrologerbyId[0].name} a Gift')
                                                    .tr(),
                                                InkWell(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: Icon(Icons.close))
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: GetBuilder<GiftController>(
                                                builder: (c) {
                                              return ListView(children: [
                                                Center(
                                                  child: Wrap(
                                                    children: [
                                                      for (int index = 0;
                                                          index <
                                                              giftController
                                                                  .giftList
                                                                  .length;
                                                          index++)
                                                        SizedBox(
                                                          height: 100,
                                                          width: 110,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  giftController
                                                                      .updateOntap(
                                                                          index);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: giftController.giftList[index].isSelected ??
                                                                            false
                                                                        ? Color.fromARGB(
                                                                            255,
                                                                            196,
                                                                            192,
                                                                            192)
                                                                        : Colors
                                                                            .transparent,
                                                                  ),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl:
                                                                        '${global.imgBaseurl}${giftController.giftList[index].image}',
                                                                    imageBuilder:
                                                                        (context,
                                                                            imageProvider) {
                                                                      return Image
                                                                          .network(
                                                                        "${global.imgBaseurl}${giftController.giftList[index].image}",
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      );
                                                                    },
                                                                    placeholder: (context,
                                                                            url) =>
                                                                        const Center(
                                                                            child:
                                                                                CircularProgressIndicator()),
                                                                    errorWidget:
                                                                        (context,
                                                                            url,
                                                                            error) {
                                                                      return Image
                                                                          .asset(
                                                                        Images
                                                                            .palmistry,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                      giftController
                                                                          .giftList[
                                                                              index]
                                                                          .name,
                                                                      style: Get
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                              fontSize: 12))
                                                                  .tr(),
                                                              Text(
                                                                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${giftController.giftList[index].amount}',
                                                                  style: Get
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              10,
                                                                          color:
                                                                              Colors.grey))
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ]);
                                            }),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Wallet Balance',
                                                            style: Get.textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        12))
                                                        .tr(),
                                                    Text(
                                                        '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)}${global.splashController.currentUser?.walletAmount.toString()}'),
                                                  ],
                                                ),
                                                Container(
                                                  width: 110,
                                                  height: 40,
                                                  child: TextButton(
                                                      child: Text('Recharge',
                                                              style: TextStyle(
                                                                  fontSize: 10))
                                                          .tr(),
                                                      style: ButtonStyle(
                                                          padding: MaterialStateProperty
                                                              .all<EdgeInsets>(
                                                                  EdgeInsets.all(
                                                                      8)),
                                                          foregroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  Colors.black),
                                                          backgroundColor:
                                                              MaterialStateProperty.all(
                                                                  Colors.yellow.shade100),
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .yellow
                                                                    .shade200),
                                                          ))),
                                                      onPressed: () async {
                                                        global
                                                            .showOnlyLoaderDialog(
                                                                context);
                                                        await walletController
                                                            .getAmount();
                                                        global.hideLoader();
                                                        Get.back();
                                                        openBottomSheetRechrage(
                                                            context,
                                                            '',
                                                            '',
                                                            '');
                                                      }),
                                                ),
                                                Container(
                                                  width: 110,
                                                  height: 40,
                                                  child: TextButton(
                                                      child: Text('Send Gift',
                                                              style: TextStyle(
                                                                  fontSize: 10))
                                                          .tr(),
                                                      style: ButtonStyle(
                                                          padding:
                                                              MaterialStateProperty.all<EdgeInsets>(
                                                                  EdgeInsets.all(
                                                                      8)),
                                                          foregroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  Colors.black),
                                                          backgroundColor:
                                                              MaterialStateProperty.all(
                                                                  Colors.grey.shade100),
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.black12)))),
                                                      onPressed: () async {
                                                        if (giftController
                                                                .giftSelectIndex !=
                                                            null) {
                                                          double wallet = global
                                                                  .splashController
                                                                  .currentUser
                                                                  ?.walletAmount ??
                                                              0.0;
                                                          if (wallet <
                                                              giftController
                                                                  .giftList[
                                                                      giftController
                                                                          .giftSelectIndex!]
                                                                  .amount) {
                                                            global.showToast(
                                                              message:
                                                                  'you do not have sufficient balance',
                                                              textColor: global
                                                                  .textColor,
                                                              bgColor: global
                                                                  .toastBackGoundColor,
                                                            );
                                                          } else {
                                                            global
                                                                .showOnlyLoaderDialog(
                                                                    context);
                                                            await giftController.sendGift(
                                                                giftController
                                                                    .giftList[
                                                                        giftController
                                                                            .giftSelectIndex!]
                                                                    .id,
                                                                bottomNavigationController
                                                                    .astrologerbyId[
                                                                        0]
                                                                    .id!,
                                                                double.parse(giftController
                                                                    .giftList[
                                                                        giftController
                                                                            .giftSelectIndex!]
                                                                    .amount
                                                                    .toString()));
                                                            global.hideLoader();
                                                          }
                                                        } else {
                                                          global.showToast(
                                                            message:
                                                                'Please select gift',
                                                            textColor: global
                                                                .textColor,
                                                            bgColor: global
                                                                .toastBackGoundColor,
                                                          );
                                                        }
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            child: GetBuilder<BottomNavigationController>(
                                builder: (bottomNavigationController) {
                              return menuItem(CupertinoIcons.gift,
                                  "Send Gift To ${bottomNavigationController.astrologerbyId[0].name}");
                            }),
                          );
                        }),
                        GetBuilder<BottomNavigationController>(
                            builder: (bottomNavigationController) {
                          return bottomNavigationController
                                  .astrologerbyId[0].isFollow!
                              ? const SizedBox()
                              : Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_add,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text('Follow ${bottomNavigationController.astrologerbyId[0].name}')
                                                .tr()
                                          ],
                                        ),
                                        Text(
                                          'Follow ${bottomNavigationController.astrologerbyId[0].name} to get notifed when they go live,come online or run an offers!',
                                          style: Get.textTheme.bodyMedium!
                                              .copyWith(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                        ).tr(),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: GetBuilder<
                                                  FollowAstrologerController>(
                                              builder:
                                                  (followAstrologerController) {
                                            return InkWell(
                                              onTap: () async {
                                                log('message');
                                                bool isLogin =
                                                    await global.isLogin();
                                                if (isLogin) {
                                                  global.showOnlyLoaderDialog(
                                                      context);
                                                  await followAstrologerController
                                                      .addFollowers(
                                                          bottomNavigationController
                                                              .astrologerbyId[0]
                                                              .id!);
                                                  global.hideLoader();
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .blue, //Get.theme.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Text(
                                                  'Follow',
                                                  style: Get
                                                      .textTheme.bodyMedium!
                                                      .copyWith(
                                                          fontSize: 10,
                                                          color: Colors.white),
                                                  textAlign: TextAlign.center,
                                                ).tr(),
                                              ),
                                            );
                                          }),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ]),
                    ),
                  ),
                )
              ],
            );
          }),
        ),
        bottomNavigationBar: GetBuilder<BottomNavigationController>(
            builder: (bottomNavigationController) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child:
                    GetBuilder<ChatController>(builder: (chatController) {
                      return InkWell(
                        onTap: () async {
                          bool isLogin = await global.isLogin();
                          if (isLogin) {
                            double charge = double.parse(
                                bottomNavigationController
                                    .astrologerbyId[0].charge!
                                    .toString());
                            if (charge * 5 <=
                                global.splashController.currentUser!
                                    .walletAmount! ||
                                bottomNavigationController
                                    .astrologerbyId[0].isFreeAvailable ==
                                    true) {
                              if (bottomNavigationController
                                  .astrologerbyId[0].chatStatus ==
                                  "Online") {
                                await bottomNavigationController
                                    .checkAlreadyInReq(
                                    bottomNavigationController
                                        .astrologerbyId[0].id!);
                                if (bottomNavigationController
                                    .isUserAlreadyInChatReq ==
                                    false) {
                                  global.showOnlyLoaderDialog(context);

                                  if (bottomNavigationController
                                      .astrologerbyId[0].chatWaitTime !=
                                      null) {
                                    if (bottomNavigationController
                                        .astrologerbyId[0].chatWaitTime!
                                        .difference(DateTime.now())
                                        .inMinutes <
                                        0) {
                                      await bottomNavigationController
                                          .changeOfflineStatus(
                                          bottomNavigationController
                                              .astrologerbyId[0].id!,
                                          "Online");
                                    }
                                  }

                                  await Get.to(() => CallIntakeFormScreen(
                                    type: "Chat",
                                    astrologerId: bottomNavigationController
                                        .astrologerbyId[0].id!,
                                    astrologerName:
                                    bottomNavigationController
                                        .astrologerbyId[0].name!,
                                    astrologerProfile:
                                    bottomNavigationController
                                        .astrologerbyId[0]
                                        .profileImage!,
                                    isFreeAvailable:
                                    bottomNavigationController
                                        .astrologerbyId[0]
                                        .isFreeAvailable,
                                    rate: bottomNavigationController
                                        .astrologerbyId[0]
                                        .charge.toString(),
                                    //index: index,
                                  ));
                                  global.hideLoader();
                                } else {
                                  bottomNavigationController
                                      .dialogForNotCreatingSession(context);
                                }
                              } else if (
                              bottomNavigationController
                                  .astrologerbyId[0].chatStatus ==
                                  "Offline" || bottomNavigationController
                                  .astrologerbyId[0].chatStatus ==
                                  "Wait Time" ) {
                                dialogForJoinInWaitList(
                                    context,
                                    bottomNavigationController
                                        .astrologerbyId[0].name!,
                                    true,
                                    bottomNavigationController
                                        .astrologerbyId[0].chatStatus.toString()
                                );
                              } else if (bottomNavigationController
                                  .astrologerbyId[0].chatStatus ==
                                  "Busy") {
                                dialogForJoinInWaitList(
                                    context,
                                    bottomNavigationController
                                        .astrologerbyId[0].name!,
                                    true,
                                    bottomNavigationController
                                        .astrologerbyId[0].chatStatus.toString()
                                );
                              }
                            } else {
                              global.showOnlyLoaderDialog(context);
                              await walletController.getAmount();
                              global.hideLoader();
                              openBottomSheetRechrage(
                                  context,
                                  (charge * 5).toString(),
                                  'chat',
                                  '${bottomNavigationController.astrologerbyId[0].name}');
                            }
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: bottomNavigationController
                              .astrologerbyId[0]
                              .chatStatus ==
                              "Online"?Colors.lightBlue:Colors.orangeAccent, //Get.theme.primaryColor,
                          elevation: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                  CupertinoIcons.chat_bubble_2,
                                  color: Colors.white
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Chat",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white),
                                        ).tr(),
                                        bottomNavigationController
                                            .astrologerbyId[0]
                                            .chatStatus ==
                                            "Offline"||bottomNavigationController
                                            .astrologerbyId[0]
                                            .chatStatus ==
                                            "Busy"
                                            ? Text(
                                          bottomNavigationController
                                              .astrologerbyId[0]
                                              .chatStatus ==
                                              "Offline"? "Currently Offline":'Currently Busy',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight:
                                              FontWeight.w500),
                                        ).tr()
                                            : bottomNavigationController
                                            .astrologerbyId[0]
                                            .chatStatus ==
                                            "Online"
                                            ? SizedBox()
                                            : Text(
                                          bottomNavigationController
                                              .astrologerbyId[
                                          0]
                                              .chatWaitTime!
                                              .difference(
                                              DateTime
                                                  .now())
                                              .inMinutes >
                                              0
                                              ? "Wait till - ${bottomNavigationController.astrologerbyId[0].chatWaitTime!.difference(DateTime.now()).inMinutes} min"
                                              : "Waiting",
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight:
                                              FontWeight
                                                  .w500),
                                        ).tr(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox()
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child:
                    GetBuilder<CallController>(builder: (callController) {
                      return InkWell(
                        onTap: () async {
                          bool isLogin = await global.isLogin();
                          if (isLogin) {
                            double charge = double.parse(
                                bottomNavigationController
                                    .astrologerbyId[0].charge!
                                    .toString());
                            if (charge * 5 <=
                                global.splashController.currentUser!
                                    .walletAmount! ||
                                bottomNavigationController
                                    .astrologerbyId[0].isFreeAvailable ==
                                    true) {
                              if (bottomNavigationController
                                  .astrologerbyId[0].callStatus ==
                                  "Online" ) {
                                await bottomNavigationController
                                    .checkAlreadyInReqForCall(
                                    bottomNavigationController
                                        .astrologerbyId[0].id!);
                                if (bottomNavigationController
                                    .isUserAlreadyInCallReq ==
                                    false) {
                                  global.showOnlyLoaderDialog(context);
                                  if (bottomNavigationController
                                      .astrologerbyId[0].callWaitTime !=
                                      null) {
                                    if (bottomNavigationController
                                        .astrologerbyId[0].callWaitTime!
                                        .difference(DateTime.now())
                                        .inMinutes <
                                        0) {
                                      await bottomNavigationController
                                          .changeOfflineCallStatus(
                                          bottomNavigationController
                                              .astrologerbyId[0].id!,
                                          "Online");
                                    }
                                  }
                                  await Get.to(() => CallIntakeFormScreen(
                                    astrologerProfile:
                                    bottomNavigationController
                                        .astrologerbyId[0]
                                        .profileImage!,
                                    type: "Call",
                                    astrologerId: bottomNavigationController
                                        .astrologerbyId[0].id!,
                                    astrologerName:
                                    bottomNavigationController
                                        .astrologerbyId[0].name!,
                                    isFreeAvailable:
                                    bottomNavigationController
                                        .astrologerbyId[0]
                                        .isFreeAvailable,
                                    rate: bottomNavigationController
                                        .astrologerbyId[0]
                                        .charge.toString(),
                                  ));

                                  global.hideLoader();
                                } else {
                                  bottomNavigationController
                                      .dialogForNotCreatingSession(context);
                                }
                              } else if (bottomNavigationController
                                  .astrologerbyId[0].callStatus ==
                                  "Offline" ||
                                  bottomNavigationController
                                      .astrologerbyId[0].callStatus ==
                                      "Busy"||
                                  bottomNavigationController
                                      .astrologerbyId[0].callStatus ==
                                      "Wait Time") {
                                dialogForJoinInWaitList(
                                    context,
                                    bottomNavigationController
                                        .astrologerbyId[0].name!,
                                    true,
                                    bottomNavigationController
                                        .astrologerbyId[0].chatStatus.toString()
                                );
                              }
                            } else {
                              global.showOnlyLoaderDialog(context);
                              await walletController.getAmount();
                              global.hideLoader();
                              openBottomSheetRechrage(
                                  context,
                                  (charge * 5).toString(),
                                  'call',
                                  '${bottomNavigationController.astrologerbyId[0].name}');
                            }
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: bottomNavigationController
                              .astrologerbyId[0]
                              .callStatus=="Online"?Colors.green:Colors.orangeAccent , //Get.theme.primaryColor,
                          elevation: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.call,
                                  color:  Colors.white
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Audio",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white),
                                        ).tr(),
                                        bottomNavigationController
                                            .astrologerbyId[0]
                                            .callStatus ==
                                            "Offline" ||bottomNavigationController
                                            .astrologerbyId[0]
                                            .callStatus ==
                                            "Busy"
                                            ? Text(
                                          bottomNavigationController
                                              .astrologerbyId[0]
                                              .callStatus=="Offline"?"Currently Offline":"Currently Busy",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight:
                                              FontWeight.w500),
                                        ).tr()
                                            : bottomNavigationController
                                            .astrologerbyId[0]
                                            .callStatus ==
                                            "Online"
                                            ? SizedBox():
                                        Text(
                                          bottomNavigationController
                                              .astrologerbyId[
                                          0]
                                              .callWaitTime!
                                              .difference(
                                              DateTime
                                                  .now())
                                              .inMinutes >
                                              0
                                              ? "Wait till - ${bottomNavigationController.astrologerbyId[0].callWaitTime!.difference(DateTime.now()).inMinutes} min"
                                              : "Waiting",
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight:
                                              FontWeight
                                                  .w500),
                                        ).tr(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox()
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child:
                    GetBuilder<CallController>(builder: (callController) {
                      return InkWell(
                        onTap: () async {
                          bool isLogin = await global.isLogin();
                          if (isLogin) {
                            print("video call rate");
                            print("${bottomNavigationController
                                .astrologerbyId[0].videoCallRate!
                                .toString()}");
                            double charge = double.parse(
                                bottomNavigationController
                                    .astrologerbyId[0].videoCallRate!
                                    .toString());
                            if (charge * 5 <=
                                global.splashController.currentUser!
                                    .walletAmount! ||
                                bottomNavigationController
                                    .astrologerbyId[0].isFreeAvailable ==
                                    true) {
                              if (bottomNavigationController
                                  .astrologerbyId[0].callStatus ==
                                  "Online" ) {
                                await bottomNavigationController
                                    .checkAlreadyInReqForCall(
                                    bottomNavigationController
                                        .astrologerbyId[0].id!);
                                if (bottomNavigationController
                                    .isUserAlreadyInCallReq ==
                                    false) {
                                  global.showOnlyLoaderDialog(context);
                                  if (bottomNavigationController
                                      .astrologerbyId[0].callWaitTime !=
                                      null) {
                                    if (bottomNavigationController
                                        .astrologerbyId[0].callWaitTime!
                                        .difference(DateTime.now())
                                        .inMinutes <
                                        0) {
                                      await bottomNavigationController
                                          .changeOfflineCallStatus(
                                          bottomNavigationController
                                              .astrologerbyId[0].id!,
                                          "Online");
                                    }
                                  }
                                  await Get.to(() => CallIntakeFormScreen(
                                    astrologerProfile:
                                    bottomNavigationController
                                        .astrologerbyId[0]
                                        .profileImage!,
                                    type: "Videocall",
                                    astrologerId: bottomNavigationController
                                        .astrologerbyId[0].id!,
                                    astrologerName:
                                    bottomNavigationController
                                        .astrologerbyId[0].name!,
                                    isFreeAvailable:
                                    bottomNavigationController
                                        .astrologerbyId[0]
                                        .isFreeAvailable,
                                    rate: bottomNavigationController
                                        .astrologerbyId[0]
                                        .videoCallRate.toString(),
                                  ));

                                  global.hideLoader();
                                } else {
                                  bottomNavigationController
                                      .dialogForNotCreatingSession(context);
                                }
                              } else if (bottomNavigationController
                                  .astrologerbyId[0].callStatus ==
                                  "Offline" ||
                                  bottomNavigationController
                                      .astrologerbyId[0].callStatus ==
                                      "Busy"||
                                  bottomNavigationController
                                      .astrologerbyId[0].callStatus ==
                                      "Wait Time") {
                                dialogForJoinInWaitList(
                                    context,
                                    bottomNavigationController
                                        .astrologerbyId[0].name!,
                                    true,
                                    bottomNavigationController
                                        .astrologerbyId[0].chatStatus.toString()
                                );
                              }
                            } else {
                              global.showOnlyLoaderDialog(context);
                              await walletController.getAmount();
                              global.hideLoader();
                              openBottomSheetRechrage(
                                  context,
                                  (charge * 5).toString(),
                                  'call',
                                  '${bottomNavigationController.astrologerbyId[0].name}');
                            }
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color:
                          bottomNavigationController
                              .astrologerbyId[0].callStatus ==
                              "Online"? Colors.redAccent:Colors.orangeAccent, //Get.theme.primaryColor,
                          elevation: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.video_call,
                                  color:Colors.white),
                              Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Video",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white),
                                        ).tr(),
                                        bottomNavigationController
                                            .astrologerbyId[0]
                                            .callStatus ==
                                            "Offline"||bottomNavigationController
                                            .astrologerbyId[0]
                                            .callStatus ==
                                            "Busy"
                                            ? Text(
                                          bottomNavigationController
                                              .astrologerbyId[0]
                                              .callStatus ==
                                              "Busy"? 'Currently Busy':"Currently Offline",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight:
                                              FontWeight.w500),
                                        ).tr()
                                            : bottomNavigationController
                                            .astrologerbyId[0]
                                            .callStatus ==
                                            "Online"
                                            ? SizedBox()
                                            : Text(
                                          bottomNavigationController
                                              .astrologerbyId[
                                          0]
                                              .callWaitTime!
                                              .difference(
                                              DateTime
                                                  .now())
                                              .inMinutes >
                                              0
                                              ? "Wait till - ${bottomNavigationController.astrologerbyId[0].callWaitTime!.difference(DateTime.now()).inMinutes} min"
                                              : "Waiting",
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight:
                                              FontWeight
                                                  .w500),
                                        ).tr(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox()
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget menuItem(IconData icon, String s) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey,
                ),
                SizedBox(width: 5),
                Text(s).tr(),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Widget ratingAndReview() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: Get.height * 0.8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(kIsWeb
                            ? Icons.arrow_back
                            : Platform.isIOS
                                ? Icons.arrow_back_ios
                                : Icons.arrow_back)),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Rating and Reviews').tr(),
                  ],
                ),
              ],
            ),
            Expanded(
              child: GetBuilder<ReviewController>(builder: (r) {
                return ListView.builder(
                    itemCount: reviewController.reviewList.length,
                    itemBuilder: (context, index) {
                      return ShowReviewWidget(
                        index: index,
                        astologername:
                            bottomNavigationController.astrologerbyId[0].name ??
                                "AStrologer",
                        astroImage:
                            "${global.imgBaseurl}${bottomController.astrologerbyId[0].profileImage}",
                      );
                    });
              }),
            ),
          ],
        ),
      ),
    );
  }

  void openBottomSheetRechrage(
      BuildContext context, String minBalance, String type, String astrologer) {
    Get.bottomSheet(
      Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.85,
                                    child: minBalance != ''
                                        ? Text('Minimum balance of 5 minutes(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) is required to start $type with $astrologer ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red))
                                            .tr()
                                        : const SizedBox(),
                                  ),
                                  GestureDetector(
                                    child: Padding(
                                      padding: minBalance == ''
                                          ? const EdgeInsets.only(top: 8)
                                          : const EdgeInsets.only(top: 0),
                                      child: Icon(Icons.close, size: 18),
                                    ),
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 5),
                                child: Text('Recharge Now',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500))
                                    .tr(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Icon(Icons.lightbulb_rounded,
                                        color: Get.theme.primaryColor,
                                        size: 13),
                                  ),
                                  Expanded(
                                      child: Text(
                                              'Tip:90% users rechage for 10 mins or more.',
                                              style: TextStyle(fontSize: 12))
                                          .tr())
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 3.8 / 2.3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: walletController.rechrage.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // WalletController walletController = Get.find<WalletController>();
                          // global.showOnlyLoaderDialog(context);
                          // await walletController.getAmount();
                          // global.hideLoader();
                          // Get.to(() => AddmoneyToWallet());


                          Get.to(() => PaymentInformationScreen(
                              flag: 0,
                              amount: double.parse(
                                  walletController.payment[index])));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                                child: Text(
                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.rechrage[index]}',
                              style: TextStyle(fontSize: 13),
                            )),
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}
