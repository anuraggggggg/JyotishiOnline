// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/views/addMoneyToWallet.dart';
import 'package:AstrowayCustomer/views/chat/endDialog.dart';
import 'package:AstrowayCustomer/views/chat/pdfviewerpage.dart';
import 'package:AstrowayCustomer/views/chat/zoomimagewidget.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../controllers/bottomNavigationController.dart';
import '../../controllers/callController.dart';
import '../../controllers/chatController.dart';
import '../../controllers/reviewController.dart';
import '../../controllers/splashController.dart';
import '../../controllers/timer_controller.dart';
import '../../controllers/walletController.dart';

import '../../model/chat_message_model.dart';
import '../../utils/images.dart';
import '../astrologerProfile/astrologerProfile.dart';
import '../bottomNavigationBarScreen.dart';
import '../customDialog.dart';

class AcceptChatScreen extends StatefulWidget {
  final int flagId;
  final String profileImage;
  final String astrologerName;
  final String fireBasechatId;
  final int chatId;
  final int astrologerId;
  final String? fcmToken;
  String duration;
  AcceptChatScreen({
    super.key,
    required this.flagId,
    required this.profileImage,
    required this.astrologerName,
    required this.fireBasechatId,
    required this.astrologerId,
    required this.chatId,
    this.fcmToken,
    required this.duration,
  });

  @override
  State<AcceptChatScreen> createState() => _AcceptChatScreenState();
}

class _AcceptChatScreenState extends State<AcceptChatScreen> {
  final messageController = TextEditingController();
  final splashController = Get.find<SplashController>();
  final walletController = Get.find<WalletController>();
  final bottomNavigationController = Get.find<BottomNavigationController>();
  final timerController = Get.find<TimerController>();
  final sendtextfocusnode = FocusNode();
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final historyController = Get.find<HistoryController>();
  @override
  void dispose() {
    timerController.secTimer!.cancel();
    log('ondispose called acceptchat screen');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    chatController.isTimerEnded = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.flagId == 0) {
          return true;
        } else {
          if (chatController.isAstrologerEndedChat != true) {
            if (timerController.totalSeconds <= 60) {
              Get.dialog(
                EndDialog(),
              );
            } else {
              Get.dialog(
                CupertinoAlertDialog(
                  title: Text(
                    "Are you sure you want to end chat?",
                    style: Get.textTheme.titleMedium,
                  ).tr(),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () async {
                        global.showOnlyLoaderDialog(context);

                        chatController.sendMessage(
                            '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
                            widget.fireBasechatId,
                            widget.astrologerId,
                            true);
                        chatController.showBottomAcceptChat = false;
                        global.sp = await SharedPreferences.getInstance();
                        chatController.isEndChat = true;
                        chatController.chatBottom = false;
                        chatController.isInchat = false;
                        chatController.isAstrologerEndedChat = false;
                        global.callOnFcmApiSendPushNotifications(
                            fcmTokem: [widget.fcmToken],
                            title: 'End chat from customer');
                        chatController.update();
                        await timerController.endChatTime(
                            timerController.totalSeconds, widget.chatId);
                        timerController.secTimer!.cancel();
                        await global.splashController.getCurrentUserData();
                        // await historyController.getChatHistory(
                        //     global.currentUserId!, false);
                        timerController.endChat = true;
                        timerController.update();
                        bottomNavigationController.astrologerList.clear();
                        bottomNavigationController.isAllDataLoaded = false;
                        if (bottomNavigationController.genderFilterList !=
                            null) {
                          bottomNavigationController.genderFilterList!.clear();
                        }
                        if (bottomNavigationController.languageFilter != null) {
                          bottomNavigationController.languageFilter!.clear();
                        }
                        if (bottomNavigationController.skillFilterList !=
                            null) {
                          bottomNavigationController.skillFilterList!.clear();
                        }
                        bottomNavigationController.applyFilter = false;
                        bottomNavigationController.update();
                        await bottomNavigationController.getAstrologerList(
                            isLazyLoading: false);
                        global.hideLoader();
                        bottomNavigationController.setIndex(0, 0);
                        Get.back();
                        Get.back();
                        Get.to(() => BottomNavigationBarScreen(
                          index: 0,
                        ));
                      },
                      child: Text('Exit', style: TextStyle(color: Colors.blue))
                          .tr(),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Get.back();
                        timerController.endChat = false;
                        timerController.update();
                      },
                      child:
                      Text('No', style: TextStyle(color: Colors.blue)).tr(),
                    ),
                  ],
                ),
              );
            }
            return timerController.endChat;
          } else {
            Get.dialog(
              CupertinoAlertDialog(
                title: Text(
                  "Are you sure you want to end chat?",
                  style: Get.textTheme.titleMedium,
                ).tr(),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () async {
                      global.showOnlyLoaderDialog(context);

                      chatController.sendMessage(
                          '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
                          widget.fireBasechatId,
                          widget.astrologerId,
                          true);
                      chatController.showBottomAcceptChat = false;
                      global.sp = await SharedPreferences.getInstance();
                      global.sp!.remove('chatBottom');
                      global.sp!.setInt('chatBottom', 0);
                      chatController.isEndChat = true;
                      chatController.chatBottom = false;
                      chatController.isInchat = false;
                      chatController.isAstrologerEndedChat = false;
                      global.callOnFcmApiSendPushNotifications(
                          fcmTokem: [widget.fcmToken],
                          title: 'End chat from customer');
                      chatController.update();
                      await timerController.endChatTime(
                          timerController.totalSeconds, widget.chatId);

                      await global.splashController.getCurrentUserData();
                      // await historyController.getChatHistory(
                      //     global.currentUserId!, false);

                      timerController.secTimer!.cancel();
                      timerController.endChat = true;
                      timerController.update();
                      bottomNavigationController.astrologerList.clear();
                      bottomNavigationController.isAllDataLoaded = false;
                      if (bottomNavigationController.genderFilterList != null) {
                        bottomNavigationController.genderFilterList!.clear();
                      }
                      if (bottomNavigationController.languageFilter != null) {
                        bottomNavigationController.languageFilter!.clear();
                      }
                      if (bottomNavigationController.skillFilterList != null) {
                        bottomNavigationController.skillFilterList!.clear();
                      }
                      bottomNavigationController.applyFilter = false;
                      bottomNavigationController.update();
                      await bottomNavigationController.getAstrologerList(
                          isLazyLoading: false);
                      global.hideLoader();
                      bottomNavigationController.setIndex(0, 0);
                      Get.back();
                      Get.back();
                      Get.to(() => BottomNavigationBarScreen(
                        index: 0,
                      ));
                    },
                    child:
                    Text('Exit', style: TextStyle(color: Colors.blue)).tr(),
                  ),
                  CupertinoDialogAction(
                    onPressed: () {
                      Get.back();
                      timerController.endChat = false;
                      timerController.update();
                    },
                    child:
                    Text('No', style: TextStyle(color: Colors.blue)).tr(),
                  ),
                ],
              ),
            );
            return timerController.endChat;
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xffef5350),
            title: GestureDetector(
              onTap: () async {
                print('appbar tapped');
                if (widget.flagId == 0) {
                  Get.find<ReviewController>()
                      .getReviewData(widget.astrologerId);
                  global.showOnlyLoaderDialog(context);
                  await bottomNavigationController
                      .getAstrologerbyId(widget.astrologerId);
                  global.hideLoader();
                  Get.to(() => AstrologerProfile(
                    index: 0,
                  ));
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: '${global.imgBaseurl}${widget.profileImage}',
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 6.h,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Image.asset(
                        Images.deafultUser,
                        height: 6.h,
                        width: 6.h,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.astrologerName.isEmpty ||
                            widget.astrologerName == ''
                            ? 'User'
                            : widget.astrologerName,
                        style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ).tr(),
                    ],
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () async {
                await Future.delayed(Duration.zero);
                if (widget.flagId == 0) {
                  Get.back();
                } else {
                  if (chatController.isAstrologerEndedChat != true) {
                    if (timerController.totalSeconds <= 60) {
                      Get.dialog(
                        EndDialog(),
                      );
                    } else {
                      //end chat cupertino dialog
                      Get.dialog(
                        CupertinoAlertDialog(
                          title: Text(
                            "Are you sure you want to end chat?",
                            style: Get.textTheme.titleMedium,
                          ).tr(),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () async {
                                global.showOnlyLoaderDialog(context);

                                chatController.sendMessage(
                                    '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
                                    widget.fireBasechatId,
                                    widget.astrologerId,
                                    true);
                                chatController.showBottomAcceptChat = false;
                                global.sp =
                                await SharedPreferences.getInstance();
                                chatController.isEndChat = true;
                                global.sp!.remove('chatBottom');
                                global.sp!.setInt('chatBottom', 0);
                                chatController.chatBottom = false;
                                chatController.isInchat = false;
                                chatController.isAstrologerEndedChat = false;
                                global.callOnFcmApiSendPushNotifications(
                                    fcmTokem: [widget.fcmToken],
                                    title: 'End chat from customer');
                                chatController.update();
                                await timerController.endChatTime(
                                    timerController.totalSeconds,
                                    widget.chatId);

                                timerController.secTimer!.cancel();
                                timerController.update();
                                bottomNavigationController.astrologerList
                                    .clear();
                                bottomNavigationController.isAllDataLoaded =
                                false;
                                if (bottomNavigationController
                                    .genderFilterList !=
                                    null) {
                                  bottomNavigationController.genderFilterList!
                                      .clear();
                                }
                                if (bottomNavigationController.languageFilter !=
                                    null) {
                                  bottomNavigationController.languageFilter!
                                      .clear();
                                }
                                if (bottomNavigationController
                                    .skillFilterList !=
                                    null) {
                                  bottomNavigationController.skillFilterList!
                                      .clear();
                                }
                                bottomNavigationController.applyFilter = false;
                                await global.splashController
                                    .getCurrentUserData();
                                // await historyController.getChatHistory(
                                //     global.currentUserId!, false);
                                bottomNavigationController.update();
                                await bottomNavigationController
                                    .getAstrologerList(isLazyLoading: false);
                                global.hideLoader();
                                bottomNavigationController.setIndex(0, 0);
                                Get.back();
                                Get.back();
                                Get.to(() => BottomNavigationBarScreen(
                                  index: 0,
                                ));
                              },
                              child: Text('Exit',
                                  style: TextStyle(color: Colors.blue))
                                  .tr(),
                            ),
                            CupertinoDialogAction(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('No',
                                  style: TextStyle(color: Colors.blue))
                                  .tr(),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    Get.dialog(
                      CupertinoAlertDialog(
                        title: Text(
                          "Are you sure you want to end chat?",
                          style: Get.textTheme.titleMedium,
                        ).tr(),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () async {
                              global.showOnlyLoaderDialog(context);

                              chatController.sendMessage(
                                  '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
                                  widget.fireBasechatId,
                                  widget.astrologerId,
                                  true);
                              chatController.showBottomAcceptChat = false;
                              global.sp = await SharedPreferences.getInstance();
                              chatController.isEndChat = true;
                              global.sp!.remove('chatBottom');
                              global.sp!.setInt('chatBottom', 0);
                              chatController.chatBottom = false;
                              chatController.isInchat = false;
                              chatController.isAstrologerEndedChat = false;
                              global.callOnFcmApiSendPushNotifications(
                                  fcmTokem: [widget.fcmToken],
                                  title: 'End chat from customer');
                              chatController.update();
                              await timerController.endChatTime(
                                  timerController.totalSeconds, widget.chatId);

                              timerController.secTimer!.cancel();
                              timerController.update();
                              bottomNavigationController.astrologerList.clear();
                              bottomNavigationController.isAllDataLoaded =
                              false;
                              if (bottomNavigationController.genderFilterList !=
                                  null) {
                                bottomNavigationController.genderFilterList!
                                    .clear();
                              }
                              if (bottomNavigationController.languageFilter !=
                                  null) {
                                bottomNavigationController.languageFilter!
                                    .clear();
                              }
                              if (bottomNavigationController.skillFilterList !=
                                  null) {
                                bottomNavigationController.skillFilterList!
                                    .clear();
                              }
                              bottomNavigationController.applyFilter = false;
                              bottomNavigationController.update();
                              await bottomNavigationController
                                  .getAstrologerList(isLazyLoading: false);
                              await global.splashController
                                  .getCurrentUserData();
                              // await historyController.getChatHistory(
                              //     global.currentUserId!, false);
                              global.hideLoader();
                              bottomNavigationController.setIndex(0, 0);
                              Get.back();
                              Get.back();
                              Get.to(() => BottomNavigationBarScreen(
                                index: 0,
                              ));
                            },
                            child: Text('Exit',
                                style: TextStyle(color: Colors.blue))
                                .tr(),
                          ),
                          CupertinoDialogAction(
                            onPressed: () {
                              Get.back();
                            },
                            child:
                            Text('No', style: TextStyle(color: Colors.blue))
                                .tr(),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                  color: Colors.white),
            ),
            actions: [
              widget.flagId == 0
                  ? IconButton(
                onPressed: () async {
                  global.showOnlyLoaderDialog(context);
                  await chatController.shareChat(
                      widget.fireBasechatId, widget.astrologerName);
                  global.hideLoader();
                },
                icon: Icon(Icons.share, color: Colors.white),
              )
                  : Builder(builder: (BuildContext context) {
                if (widget.flagId == 1) {
                  timerController.chatId = widget.chatId;
                  timerController.update();
                }
                return GestureDetector(
                  onTap: () async {
                    if (chatController.isAstrologerEndedChat != true) {
                      if (timerController.totalSeconds <= 60) {
                        Get.dialog(
                          EndDialog(),
                        );
                      } else {
                        Get.dialog(
                          CupertinoAlertDialog(
                            title: Text(
                              "Are you sure you want to end chat?",
                              style: Get.textTheme.titleMedium,
                            ).tr(),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () async {
                                  global.showOnlyLoaderDialog(context);

                                  chatController.sendMessage(
                                      '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
                                      widget.fireBasechatId,
                                      widget.astrologerId,
                                      true);
                                  chatController.showBottomAcceptChat =
                                  false;
                                  global.sp = await SharedPreferences
                                      .getInstance();
                                  chatController.isEndChat = true;
                                  global.sp!.remove('chatBottom');
                                  global.sp!.setInt('chatBottom', 0);
                                  chatController.chatBottom = false;
                                  chatController.isInchat = false;
                                  chatController.isAstrologerEndedChat =
                                  false;
                                  global
                                      .callOnFcmApiSendPushNotifications(
                                      fcmTokem: [widget.fcmToken],
                                      title:
                                      'End chat from customer');
                                  chatController.update();
                                  await timerController.endChatTime(
                                      timerController.totalSeconds,
                                      widget.chatId);

                                  timerController.secTimer!.cancel();
                                  timerController.update();
                                  bottomNavigationController
                                      .astrologerList
                                      .clear();
                                  bottomNavigationController
                                      .isAllDataLoaded = false;
                                  if (bottomNavigationController
                                      .genderFilterList !=
                                      null) {
                                    bottomNavigationController
                                        .genderFilterList!
                                        .clear();
                                  }
                                  if (bottomNavigationController
                                      .languageFilter !=
                                      null) {
                                    bottomNavigationController
                                        .languageFilter!
                                        .clear();
                                  }
                                  if (bottomNavigationController
                                      .skillFilterList !=
                                      null) {
                                    bottomNavigationController
                                        .skillFilterList!
                                        .clear();
                                  }
                                  bottomNavigationController.applyFilter =
                                  false;
                                  bottomNavigationController.update();
                                  await bottomNavigationController
                                      .getAstrologerList(
                                      isLazyLoading: false);
                                  await global.splashController
                                      .getCurrentUserData();

                                  global.hideLoader();
                                  bottomNavigationController.setIndex(
                                      0, 0);
                                  Get.back();
                                  Get.back();
                                  Get.to(() => BottomNavigationBarScreen(
                                    index: 0,
                                  ));
                                },
                                child: Text('Exit',
                                    style:
                                    TextStyle(color: Colors.blue))
                                    .tr(),
                              ),
                              CupertinoDialogAction(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('No',
                                    style:
                                    TextStyle(color: Colors.blue))
                                    .tr(),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      endchatDialog(context);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    height: 35,
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Text(
                      'End chat',
                      style:
                      TextStyle(fontSize: 15.sp, color: Colors.white),
                    ).tr(),
                  ),
                );
              })
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            // height: 100.h,
            child: Stack(
              children: [
                GetBuilder<ChatController>(builder: (chatController) {
                  return Column(
                    children: [
                      Expanded(
                        child:
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: chatController.getChatMessages(
                                widget.fireBasechatId,
                                widget.astrologerId
                                //global.currentUserId,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState.name ==
                                  "waiting") {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else {
                                if (snapshot.hasError) {
                                  return Text(
                                      'snapShotError :- ${snapshot.error}');
                                } else {
                                  List<ChatMessageModel> messageList = [];
                                  for (var res in snapshot.data!.docs) {
                                    messageList.add(
                                        ChatMessageModel.fromJson(
                                            res.data()));
                                  }

                                  log("data from chat");
                                  log("${messageList}");
                                  return ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      padding:
                                      const EdgeInsets.only(bottom: 50),
                                      itemCount: messageList.length,
                                      shrinkWrap: true,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        print('aksdnksn');
                                        print(messageList[index].message);
                                        ChatMessageModel message =
                                        messageList[index];
                                        chatController.isMe =
                                            message.userId1 ==
                                                '${global.currentUserId}';
                                        log('reply msg is ${messageList[index].replymsg}');
                                        log('reply msg createdat ${messageList[index].createdAt}');

                                        log('attachements path is ${messageList[index].attachementPath}');

                                        return messageList[index]
                                            .isEndMessage ==
                                            true
                                            ? Container(
                                          margin:
                                          const EdgeInsets.only(
                                              bottom: 10),
                                          color: const Color.fromARGB(
                                              255, 247, 244, 211),
                                          padding:
                                          const EdgeInsets.all(8),
                                          alignment: Alignment.center,
                                          child: Text(
                                            messageList[index]
                                                .message!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            textAlign:
                                            TextAlign.center,
                                          ),
                                        )
                                            : Row(
                                          mainAxisAlignment:
                                          chatController.isMe
                                              ? MainAxisAlignment
                                              .end
                                              : MainAxisAlignment
                                              .start,
                                          children: [
                                            //Swipe Feature
                                            SwipeTo(
                                              key: UniqueKey(),
                                              iconOnLeftSwipe:
                                              Icons.arrow_forward,
                                              iconOnRightSwipe:
                                              Icons.reply,
                                              onRightSwipe:
                                                  (details) {
                                                // log("\n Left Swipe Data --> $details");
                                                log(" data Swipe Data --> ${messageList[index].toJson()}");

                                                sendtextfocusnode
                                                    .requestFocus();
                                                chatController
                                                    .replymessage =
                                                messageList[
                                                index];
                                                chatController
                                                    .update();
                                                log(" Swipe details --> ${chatController.replymessage!.toJson()}");
                                              },
                                              swipeSensitivity: 5,
                                              child: Column(
                                                crossAxisAlignment:
                                                chatController
                                                    .isMe
                                                    ? CrossAxisAlignment
                                                    .end
                                                    : CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Container(
                                                    decoration:
                                                    BoxDecoration(
                                                      color: chatController
                                                          .isMe
                                                          ? messageList[index].attachementPath ==
                                                          ""
                                                          ? Color(
                                                          0xFFfbf1f2)
                                                          : Colors
                                                          .white
                                                          : messageList[index].attachementPath ==
                                                          ""
                                                          ? Colors
                                                          .grey
                                                          .shade100
                                                          : Colors
                                                          .white,
                                                      borderRadius:
                                                      BorderRadius
                                                          .only(
                                                        topLeft:
                                                        const Radius
                                                            .circular(
                                                            12),
                                                        topRight:
                                                        const Radius
                                                            .circular(
                                                            12),
                                                        bottomLeft: chatController
                                                            .isMe
                                                            ? const Radius
                                                            .circular(
                                                            0)
                                                            : const Radius
                                                            .circular(
                                                            12),
                                                        bottomRight: chatController
                                                            .isMe
                                                            ? const Radius
                                                            .circular(
                                                            0)
                                                            : const Radius
                                                            .circular(
                                                            12),
                                                      ),
                                                    ),
                                                    padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        vertical:
                                                        10,
                                                        horizontal:
                                                        16),
                                                    margin:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        vertical:
                                                        16,
                                                        horizontal:
                                                        8),
                                                    child: messageList[
                                                    index]
                                                        .replymsg !=
                                                        ""
                                                        ? Column(
                                                      children: [
                                                        IntrinsicHeight(
                                                          child:
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                color: Colors.green,
                                                                width: 1.w,
                                                              ),
                                                              SizedBox(width: 3.w), //ssd
                                                              messageList[index].replymsg != null && messageList[index].replymsg!.contains('.png') || messageList[index].replymsg != null && messageList[index].replymsg!.contains('.jpg') || messageList[index].replymsg != null && messageList[index].replymsg!.contains('.jpeg')
                                                                  ? CachedNetworkImage(
                                                                height: 10.h,
                                                                width: 30.w,
                                                                imageUrl: messageList[index].replymsg!,
                                                                imageBuilder: (context, imageProvider) => Image.network(
                                                                  messageList[index].replymsg!,
                                                                  width: MediaQuery.of(context).size.width,
                                                                  fit: BoxFit.fill,
                                                                ),
                                                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                errorWidget: (context, url, error) => Image.asset(
                                                                  'assets/images/close.png',
                                                                  height: 10.h,
                                                                  width: 30.w,
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              )
                                                                  : messageList[index].replymsg!.contains('.pdf')
                                                                  ? SizedBox(
                                                                height: 9.h,
                                                                width: 9.h,
                                                                child: const Image(image: AssetImage('assets/images/pdf.png')),
                                                              )
                                                                  : messageList[index].replymsg != "" || messageList[index].replymsg != null
                                                                  ? SizedBox(
                                                                  width: 70.w,
                                                                  child: Text(
                                                                    '${messageList[index].replymsg}',
                                                                    style: TextStyle(
                                                                      color: Colors.grey,
                                                                      fontSize: 15.sp,
                                                                    ),
                                                                  ))
                                                                  : SizedBox(
                                                                width: 70.w,
                                                                child: Text(
                                                                  '${messageList[index].message}',
                                                                  style: TextStyle(
                                                                    color: Colors.grey,
                                                                    fontSize: 15.sp,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                          70.w,
                                                          child: Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: [
                                                                  Text(
                                                                    '${messageList[index].message}',
                                                                    style: TextStyle(fontSize: 15.sp, color: Colors.black),
                                                                  ),
                                                                  SizedBox(height: 2.w),
                                                                  Text(DateFormat().add_jm().format(messageList[index].createdAt!),
                                                                      style: const TextStyle(
                                                                        color: Colors.grey,
                                                                        fontSize: 9.5,
                                                                      )),
                                                                ],
                                                              )),
                                                        ),
                                                      ],
                                                    )
                                                        : messageList[index]
                                                        .attachementPath !=
                                                        ""
                                                        ? messageList[index]
                                                        .attachementPath!
                                                        .toLowerCase()
                                                        .contains('.pdf')
                                                        ? InkWell(
                                                      onTap: () {
                                                        debugPrint('pdf onclicked');
                                                        Get.to(() => PdfViewerPage(url: messageList[index].attachementPath!));
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          SizedBox(
                                                            height: 9.h,
                                                            width: 9.h,
                                                            child: const Image(image: AssetImage('assets/images/pdf.png')),
                                                          ),
                                                          Text(DateFormat().add_jm().format(messageList[index].createdAt!),
                                                              style: const TextStyle(
                                                                color: Colors.grey,
                                                                fontSize: 9.5,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                        : messageList[index].attachementPath!.toLowerCase().contains('.png') || messageList[index].attachementPath!.toLowerCase().contains('.jpg') || messageList[index].attachementPath!.toLowerCase().contains('.jpeg')
                                                        ? InkWell(
                                                      onTap: () {
                                                        Get.to(() => zoomImageWidget(url: messageList[index].attachementPath!));
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          CachedNetworkImage(
                                                            height: 10.h,
                                                            width: 30.w,
                                                            imageUrl: messageList[index].attachementPath!,
                                                            imageBuilder: (context, imageProvider) => Image.network(
                                                              messageList[index].attachementPath!,
                                                              width: MediaQuery.of(context).size.width,
                                                              fit: BoxFit.fill,
                                                            ),
                                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                            errorWidget: (context, url, error) => Image.asset(
                                                              'assets/images/close.png',
                                                              height: 10.h,
                                                              width: 30.w,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                          Text(DateFormat().add_jm().format(messageList[index].createdAt!),
                                                              style: const TextStyle(
                                                                color: Colors.grey,
                                                                fontSize: 9.5,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                        : const SizedBox(
                                                      child: Icon(Icons.not_interested_outlined),
                                                    )
                                                        : Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          constraints: BoxConstraints(maxWidth: Get.width - 100),
                                                          child: Text(
                                                            messageList[index].message!,
                                                            style: TextStyle(
                                                              color: chatController.isMe ? Colors.black : Colors.black,
                                                            ),
                                                            textAlign: chatController.isMe ? TextAlign.start : TextAlign.start,
                                                          ),
                                                        ),
                                                        messageList[index].createdAt != null
                                                            ? Container(
                                                          padding: EdgeInsets.only(top: 1, left: 1.w, right: 1),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text(DateFormat().add_jm().format(messageList[index].createdAt!),
                                                                  style: const TextStyle(
                                                                    color: Colors.grey,
                                                                    fontSize: 9.5,
                                                                  )),
                                                            ],
                                                          ),
                                                        )
                                                            : const SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                }
                              }
                            }),
                      ),
                    ],
                  );
                }),
                widget.flagId == 2
                    ? const SizedBox()
                    : Align(
                  alignment: Alignment.bottomCenter,
                  child: widget.flagId == 0
                      ? GestureDetector(
                    onTap: () {
                      debugPrint('clicked');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                                astrologerName:
                                widget.astrologerName,
                                astrologerProfile:
                                widget.profileImage,
                                astrologerId: widget.astrologerId);
                          });
                    },
                    child: GetBuilder<ChatController>(
                        builder: (chatController) {
                          return Card(
                            elevation: 1,
                            child: Container(
                              width: Get.width,
                              color: Color.fromARGB(255, 228, 224, 193),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      chatController.reviewData.isEmpty
                                          ? 'Add Your Review'
                                          : 'Your Review',
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    chatController.reviewData.isEmpty
                                        ? const SizedBox()
                                        : Row(
                                      children: [
                                        splashController
                                            .currentUser
                                            ?.profile ==
                                            ""
                                            ? CircleAvatar(
                                          radius: 22,
                                          child:
                                          CircleAvatar(
                                            backgroundColor:
                                            Colors
                                                .white,
                                            backgroundImage:
                                            AssetImage(
                                                Images
                                                    .deafultUser),
                                          ),
                                        )
                                            : CachedNetworkImage(
                                          imageUrl:
                                          "${global.imgBaseurl}${splashController.currentUser?.profile}",
                                          imageBuilder:
                                              (context,
                                              imageProvider) {
                                            return CircleAvatar(
                                              radius: 22,
                                              backgroundColor:
                                              Colors
                                                  .white,
                                              backgroundImage:
                                              NetworkImage(
                                                  "${global.imgBaseurl}${splashController.currentUser?.profile}"),
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
                                                radius: 22,
                                                backgroundColor:
                                                Colors
                                                    .white,
                                                child: Image
                                                    .asset(
                                                  Images
                                                      .deafultUser,
                                                  fit: BoxFit
                                                      .fill,
                                                  height:
                                                  50,
                                                ));
                                          },
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  splashController
                                                      .currentUser!
                                                      .name!
                                                      .isEmpty
                                                      ? 'User'
                                                      : splashController
                                                      .currentUser!
                                                      .name ??
                                                      'User',
                                                  style:
                                                  TextStyle(
                                                    color: Colors
                                                        .black,
                                                    fontSize:
                                                    17.sp,
                                                    fontWeight:
                                                    FontWeight
                                                        .w500,
                                                  ),
                                                ).tr(),
                                                RatingBar(
                                                  initialRating:
                                                  chatController
                                                      .reviewData[0]
                                                      .rating,
                                                  itemCount: 5,
                                                  allowHalfRating:
                                                  true,
                                                  itemSize: 15,
                                                  ignoreGestures:
                                                  true,
                                                  ratingWidget:
                                                  RatingWidget(
                                                    full: const Icon(
                                                        Icons
                                                            .grade,
                                                        color: Colors
                                                            .yellow),
                                                    half: const Icon(
                                                        Icons
                                                            .star_half,
                                                        color: Colors
                                                            .yellow),
                                                    empty: const Icon(
                                                        Icons
                                                            .grade,
                                                        color: Colors
                                                            .grey),
                                                  ),
                                                  onRatingUpdate:
                                                      (rating) {},
                                                ),
                                                chatController
                                                    .reviewData[
                                                0]
                                                    .review !=
                                                    ""
                                                    ? Container(
                                                  child:
                                                  Text(
                                                    chatController
                                                        .reviewData[0]
                                                        .review,
                                                    style:
                                                    TextStyle(
                                                      color:
                                                      Colors.black,
                                                      fontSize:
                                                      14.sp,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                    ),
                                                  ),
                                                )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 6.w,
                                          child: PopupMenuButton(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            itemBuilder:
                                                (context) => [
                                              PopupMenuItem(
                                                value: "delete",
                                                child: Text(
                                                  'Delete Review',
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      color: Colors
                                                          .red),
                                                ).tr(),
                                              )
                                            ],
                                            onSelected:
                                                (value) async {
                                              if (value ==
                                                  "Edit") {
                                                CustomDialog(
                                                    astrologerName:
                                                    widget
                                                        .astrologerName,
                                                    astrologerProfile:
                                                    widget
                                                        .profileImage,
                                                    astrologerId:
                                                    widget
                                                        .astrologerId);
                                              } else if (value ==
                                                  "delete") {
                                                global
                                                    .showOnlyLoaderDialog(
                                                    context);
                                                await chatController
                                                    .deleteReview(
                                                    chatController
                                                        .reviewData[
                                                    0]
                                                        .id!);
                                                await chatController
                                                    .getuserReview(
                                                    widget
                                                        .astrologerId);
                                                global
                                                    .hideLoader();
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )

                  //SEND MSG LAYOUT
                      : GetBuilder<ChatController>(
                    builder: (cllcontroller) => Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (cllcontroller.replymessage?.message
                            ?.isNotEmpty ==
                            true ||
                            cllcontroller
                                .replymessage
                                ?.attachementPath
                                ?.isNotEmpty ==
                                true)
                            ? _replywidget()
                            : const SizedBox.shrink(),
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 0, 8, 1.h),
                          child: GetBuilder<ChatController>(
                              builder: (chatController) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.only(
                                              bottomLeft:
                                              Radius.circular(2.w),
                                              bottomRight:
                                              Radius.circular(2.w),
                                            )),
                                        child: TextFormField(
                                          focusNode: sendtextfocusnode,
                                          controller: messageController,
                                          onChanged: (value) {},
                                          cursorColor: Colors.black,
                                          onFieldSubmitted: (value) {
                                            debugPrint(
                                                'enter value is $value');
                                            sendmessageOnTaporEnter();
                                          },
                                          style: TextStyle(
                                              color: Colors.black),
                                          decoration: InputDecoration(
                                            hintText:
                                            'Enter message here',
                                            hintStyle: TextStyle(
                                                color: Colors
                                                    .grey.shade600),
                                            contentPadding:
                                            EdgeInsets.only(
                                                left: 2.w),
                                            focusedBorder:
                                            OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.only(
                                                bottomLeft:
                                                Radius.circular(
                                                    2.w),
                                                bottomRight:
                                                Radius.circular(
                                                    2.w),
                                              ),
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            enabledBorder:
                                            OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.only(
                                                  bottomLeft: Radius
                                                      .circular(
                                                      2.w),
                                                  bottomRight:
                                                  Radius
                                                      .circular(
                                                      2.w)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                      EdgeInsets.only(bottom: 1.h),
                                      padding: const EdgeInsets.only(
                                          left: 8.0),
                                      child: Material(
                                        elevation: 3,
                                        color: Colors.transparent,
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                        child: Container(
                                            height: 6.h,
                                            width: 6.h,
                                            decoration: BoxDecoration(
                                              color:
                                              Colors.grey.shade700,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                //! Attachement work
                                                String? filepicked =
                                                await pickFiles();
                                                log('onclick file is ${filepicked}');
                                                chatController
                                                    .sendFiletoFirebase(
                                                  widget.fireBasechatId,
                                                  widget.astrologerId,
                                                  File(
                                                    filepicked!,
                                                  ),
                                                  context,
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                EdgeInsets.only(
                                                    left: 5.0),
                                                child: Icon(
                                                  Icons.file_copy_sharp,
                                                  size: 18.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 3.0),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: 1.h),
                                        height: 6.h,
                                        width: 6.h,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade700,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            sendmessageOnTaporEnter();
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 5.0),
                                            child: Icon(
                                              Icons.send,
                                              size: 18.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.flagId == 0
                    ? SizedBox()
                    : Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    height: 7.h,
                    child: Column(
                      children: [
                        Container(
                          height: 6.h,
                          width: 100.w,
                          color: Color(0xFFf46771),
                          child: Center(
                              child: widget.flagId == 1
                                  ? CountdownTimer(
                                endTime: DateTime.now()
                                    .millisecondsSinceEpoch +
                                    1000 *
                                        int.parse(widget.duration
                                            .toString()),
                                widgetBuilder: (_,
                                    CurrentRemainingTime? time) {
                                  if (time == null) {
                                    return Text(
                                        'Paid minutes: 00:00',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ));
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 1),
                                    child: time.hours != null &&
                                        time.hours != 0
                                        ? Text(
                                      'Paid minutes: ${time.hours! <= 9 ? '0${time.hours}' : time.hours ?? '00'} :${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.w400,
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                      ),
                                    )
                                        : time.min != null
                                        ? Text(
                                      'Paid minutes: ${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w400,
                                        fontSize: 16.sp,
                                        color:
                                        Colors.white,
                                      ),
                                    )
                                        : Text(
                                      'Paid minutes: ${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w400,
                                        fontSize: 16.sp,
                                        color:
                                        Colors.white,
                                      ),
                                    ),
                                  );
                                  //  time.min != null ||
                                  //         time.hours != null
                                  //     ? Text(
                                  //         'Paid minutes: ${time.hours ?? '00'} :${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                                  //         style: TextStyle(
                                  //           fontSize: 16.sp,
                                  //           color: Colors.white,
                                  //         ))
                                  //     : Text(
                                  //         'Paid minutes: ${time.sec! <= 9 ? '00:00:0${time.sec}' : '00:${time.min ?? '00'} :${time.sec}'}',
                                  //         style: TextStyle(
                                  //           fontSize: 16.sp,
                                  //           color: Colors.white,
                                  //         )),
                                  // );
                                },
                                onEnd: () async {
                                  log('in onEnd chat:- ${chatController.isEndChat} :- controller_seconds ${timerController.totalSeconds}');
                                  log('in onEnd widget_pass_second:- ${timerController.totalSeconds}');

                                  if (chatController.isTimerEnded ==
                                      false) {
                                    openDialogRecharge(
                                        context, chatController);
                                  } else {
                                    debugPrint(
                                        'dialog alreayd exited');
                                  }
                                },
                              )
                                  : SizedBox()),
                        ),
                        GetBuilder<ChatController>(
                          builder: (chatController) =>
                          chatController.isUploading
                              ? Container(
                            height: 1.h,
                            width: 100.w,
                            child: LinearProgressIndicator(
                              color: Colors.green,
                              backgroundColor: Colors.pink,
                            ),
                          )
                              : SizedBox.shrink(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openBottomSheetRechrage(BuildContext context, String minBalance,
      String type, String astrologer, String min) {
    log('minBalance $minBalance astrologer $astrologer  type $type  min $min');
    Get.bottomSheet(
      Container(
        height: 250,
        width: 100.w,
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
                                        ? Text('Minimum balance of 5 minutes(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency )} $minBalance) is required to start $type with $astrologer ',
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
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.red,
                                      ),
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
                        onTap: () async {
                          global.showOnlyLoaderDialog(context);
                          await walletController.getAmount();
                          global.hideLoader();
                          Get.to(() => AddmoneyToWallet());
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
                                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency )} ${walletController.rechrage[index]}',
                                  style: TextStyle(fontSize: 13),
                                )),
                          ),
                        ),
                      );
                    })),
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

  Widget _replywidget() {
    return Container(
      width: 67.w,
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2.w),
            topRight: Radius.circular(2.w),
          )),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.green,
              width: 1.w,
            ),
            SizedBox(width: 1.w),
            GetBuilder<ChatController>(
              builder: (cllcontroller) => Stack(
                children: [
                  Container(
                      width: 64.w,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(2.w),
                          topRight: Radius.circular(2.w),
                        ),
                      ),
                      //CHECKC WHAT IS YOU SWIPING
                      child: cllcontroller.replymessage!.message != "" &&
                          cllcontroller.replymessage!.message != null
                          ? Text(
                        '${cllcontroller.replymessage!.message}',
                        style: TextStyle(
                            fontSize: 15.sp, color: Colors.black),
                      )
                          : cllcontroller.replymessage?.attachementPath != null &&
                          cllcontroller.replymessage!.attachementPath!
                              .contains('pdf')
                          ? SizedBox(
                        height: 9.h,
                        width: 9.h,
                        child: const Image(
                            image:
                            AssetImage('assets/images/pdf.png')),
                      )
                          : cllcontroller.replymessage?.attachementPath !=
                          null &&
                          cllcontroller
                              .replymessage!.attachementPath!
                              .toLowerCase()
                              .contains('.png') ||
                          cllcontroller.replymessage?.attachementPath !=
                              null &&
                              cllcontroller
                                  .replymessage!.attachementPath!
                                  .toLowerCase()
                                  .contains('.jpg') ||
                          cllcontroller.replymessage?.attachementPath !=
                              null &&
                              cllcontroller
                                  .replymessage!.attachementPath!
                                  .toLowerCase()
                                  .contains('.jpeg')
                          ? CachedNetworkImage(
                        height: 10.h,
                        width: 30.w,
                        imageUrl: cllcontroller
                            .replymessage!.attachementPath!,
                        imageBuilder: (context, imageProvider) =>
                            Image.network(
                              cllcontroller
                                  .replymessage!.attachementPath!,
                              width:
                              MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            ),
                        placeholder: (context, url) =>
                        const Center(
                            child:
                            CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            Image.asset(
                              'assets/images/close.png',
                              height: 10.h,
                              width: 30.w,
                              fit: BoxFit.fill,
                            ),
                      )
                          : const SizedBox.shrink()),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: GestureDetector(
                      onTap: () {
                        cllcontroller.replymessage!.reset();
                        cllcontroller.update();
                      },
                      child: const Icon(Icons.close),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void endchatDialog(context) {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          "Are you sure you want to end chat?",
          style: Get.textTheme.titleMedium,
        ).tr(),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              global.showOnlyLoaderDialog(context);
              final ChatController chatController = Get.find<ChatController>();
              chatController.sendMessage(
                  '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
                  widget.fireBasechatId,
                  widget.astrologerId,
                  true);
              chatController.showBottomAcceptChat = false;
              global.sp = await SharedPreferences.getInstance();
              global.sp!.remove('chatBottom');
              global.sp!.setInt('chatBottom', 0);
              chatController.chatBottom = false;
              chatController.isInchat = false;
              chatController.isAstrologerEndedChat = false;
              chatController.isEndChat = true;
              global.callOnFcmApiSendPushNotifications(
                  fcmTokem: [widget.fcmToken], title: 'End chat from customer');
              chatController.update();
              await timerController.endChatTime(
                  timerController.totalSeconds, widget.chatId);
              await global.splashController.getCurrentUserData();
              // await historyController.getChatHistory(
              //     global.currentUserId!, false);
              timerController.secTimer!.cancel();
              timerController.update();
              bottomNavigationController.astrologerList = [];
              bottomNavigationController.astrologerList.clear();
              bottomNavigationController.isAllDataLoaded = false;
              if (bottomNavigationController.genderFilterList != null) {
                bottomNavigationController.genderFilterList!.clear();
              }
              if (bottomNavigationController.languageFilter != null) {
                bottomNavigationController.languageFilter!.clear();
              }
              if (bottomNavigationController.skillFilterList != null) {
                bottomNavigationController.skillFilterList!.clear();
              }
              bottomNavigationController.applyFilter = false;
              bottomNavigationController.update();
              await bottomNavigationController.getAstrologerList(
                  isLazyLoading: false);
              global.hideLoader();
              bottomNavigationController.setIndex(0, 0);
              Get.back();
              Get.back();
              Get.to(() => BottomNavigationBarScreen(
                index: 0,
              ));
            },
            child: Text('Exit', style: TextStyle(color: Colors.blue)).tr(),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Get.back();
            },
            child: Text('No', style: TextStyle(color: Colors.blue)).tr(),
          ),
        ],
      ),
    );
  }

  Future<String?> pickFiles() async {
    // Define the allowed file extensions
    List<String> allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

    // Prompt the user to pick files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    try {
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        log('file is ${files[0].path}');
        return files[0].path;
      } else {
        log('selecting file error');
        return '';
      }
    } on Exception catch (e) {
      log('file error $e');
      return '';
    }
  }

  void openDialogRecharge(BuildContext context, ChatController chatController) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Your Balance is Exhausted"),
          content:
          Text("Recharge your wallet to continue chat with Astrologer"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Top Up"),
              onPressed: () async {
                {
                  global.showOnlyLoaderDialog(context);

                  chatController.sendMessage(
                      '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
                      widget.fireBasechatId,
                      widget.astrologerId,
                      true);
                  chatController.showBottomAcceptChat = false;
                  global.sp = await SharedPreferences.getInstance();
                  chatController.isEndChat = true;
                  chatController.chatBottom = false;
                  chatController.isInchat = false;
                  chatController.isAstrologerEndedChat = false;
                  global.callOnFcmApiSendPushNotifications(
                      fcmTokem: [widget.fcmToken],
                      title: 'End chat from customer');
                  chatController.update();
                  await timerController.endChatTime(
                      timerController.totalSeconds, widget.chatId);
                  timerController.secTimer!.cancel();
                  await global.splashController.getCurrentUserData();
                  // await historyController.getChatHistory(
                  //     global.currentUserId!, false);
                  timerController.endChat = true;
                  timerController.update();
                  bottomNavigationController.astrologerList.clear();
                  bottomNavigationController.isAllDataLoaded = false;
                  if (bottomNavigationController.genderFilterList != null) {
                    bottomNavigationController.genderFilterList!.clear();
                  }
                  if (bottomNavigationController.languageFilter != null) {
                    bottomNavigationController.languageFilter!.clear();
                  }
                  if (bottomNavigationController.skillFilterList != null) {
                    bottomNavigationController.skillFilterList!.clear();
                  }
                  bottomNavigationController.applyFilter = false;
                  bottomNavigationController.update();
                  await bottomNavigationController.getAstrologerList(
                      isLazyLoading: false);
                  global.hideLoader();
                  bottomNavigationController.setIndex(0, 0);
                  Get.back();
                  Get.back();
                  Get.to(() => BottomNavigationBarScreen(
                    index: 0,
                  ));
                  openBottomSheetRechrage(
                    context,
                    (int.parse(bottomNavigationController
                        .astrologerbyId[0].charge
                        .toString()) *
                        5)
                        .toString(),
                    "Chat",
                    '${bottomNavigationController.astrologerbyId[0].name}',
                    bottomNavigationController.astrologerbyId[0].charge
                        .toString(),
                  );
                }
              },
            ),
            CupertinoDialogAction(
              child: Text("Exit"),
              onPressed: () async {
                chatController.isTimerEnded = true;
                chatController.update();
                exitChat(chatController, true);
              },
            ),
          ],
        );
      },
    );
  }

  exitChat(ChatController chatController, bool isback) async {
    if (chatController.isEndChat == false) {
      // global.showOnlyLoaderDialog(Get.context);
      chatController.sendMessage(
          '${global.user.name == '' ? 'user' : global.user.name} -> ended chat',
          widget.fireBasechatId,
          widget.astrologerId,
          true);
      chatController.showBottomAcceptChat = false;
      global.sp = await SharedPreferences.getInstance();
      global.sp!.remove('chatBottom');
      global.sp!.setInt('chatBottom', 0);
      chatController.chatBottom = false;
      chatController.isInchat = false;
      chatController.isAstrologerEndedChat = false;
      global.callOnFcmApiSendPushNotifications(
          fcmTokem: [widget.fcmToken], title: 'End chat from customer');
      chatController.update();
      await timerController.endChatTime(
          int.parse(widget.duration), widget.chatId);
      // global.hideLoader();
      timerController.secTimer!.cancel();
      timerController.endChat = true;
      timerController.update();
      bottomNavigationController.astrologerList.clear();
      bottomNavigationController.isAllDataLoaded = false;
      if (bottomNavigationController.genderFilterList != null) {
        bottomNavigationController.genderFilterList!.clear();
      }
      if (bottomNavigationController.languageFilter != null) {
        bottomNavigationController.languageFilter!.clear();
      }
      if (bottomNavigationController.skillFilterList != null) {
        bottomNavigationController.skillFilterList!.clear();
      }
      bottomNavigationController.applyFilter = false;
      bottomNavigationController.update();
      await bottomNavigationController.getAstrologerList(isLazyLoading: false);
      await global.splashController.getCurrentUserData();
      await historyController.getChatHistory(global.currentUserId!, false);
      Get.back();
      isback
          ? Get.offAll(() => BottomNavigationBarScreen(
        index: 0,
      ))
          : Get.back();
    } else {
      debugPrint('ischatcontroller ${chatController.isEndChat}');
    }
  }

  void sendmessageOnTaporEnter() {
    // sendtextfocusnode.unfocus();
    if (chatController.replymessage!.message != null ||
        chatController.replymessage!.attachementPath != "") {
      log('user replyying msg is ${chatController.replymessage!.message}');
      chatController.sendReplyMessage(
        messageController.text, //what we are replying
        widget.fireBasechatId,
        widget.astrologerId,
        false,
        chatController.replymessage?.attachementPath != ""
            ? chatController.replymessage!.attachementPath ?? ''
            : chatController.replymessage?.message ?? 'N/A',
      );

      messageController.clear();
    } else {
      if (messageController.text != "") {
        chatController.sendMessage(messageController.text,
            widget.fireBasechatId, widget.astrologerId, false);
        messageController.clear();
      }
    }
    chatController.replymessage!.reset(); //clear reply field too
    chatController.update();
  }
}
