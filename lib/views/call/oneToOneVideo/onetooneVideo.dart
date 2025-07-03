// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/views/chat/endDialog.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../bottomNavigationBarScreen.dart';
import 'AgoraEventHandler.dart';
import 'Agrommanager.dart';
import 'cohost_screen.dart';
import 'host_screen.dart';

class OneToOneLiveScreen extends StatefulWidget {
  final String channelname;
  final int callId;
  final String fcmToken;
  String end_time;
  OneToOneLiveScreen({
    super.key,
    required this.channelname,
    required this.callId,
    required this.fcmToken,
    required this.end_time,
  });
  @override
  State<OneToOneLiveScreen> createState() => OneToOneLiveScreenState();
}

class OneToOneLiveScreenState extends State<OneToOneLiveScreen> {
  late RtcEngine agoraEngine; // Agora engine instance
  int conneId = 0;
  late AgoraEventHandler agoraEventHandler;
  ValueNotifier<bool> isMuted = ValueNotifier(false);
  ValueNotifier<bool> isImHost = ValueNotifier(false);
  final dragController = DragController();
  ValueNotifier<bool> isJoined = ValueNotifier(false);
  ValueNotifier<int?> remoteUid = ValueNotifier(null);
  var uid = 0;
  ValueNotifier<bool> isSpeaker = ValueNotifier(true);
  CallController callController = Get.put(CallController());
  final historyController = Get.find<HistoryController>();

  @override
  void initState() {
    super.initState();
    initagora();
  }

  CallController _callController = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool) async {
        global.showToast(
          message: 'Please leave the call by pressing leave button',
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          // bottomNavigationBar: SizedBox(
          //   height: 20.h,
          //   width: 100.w,
          //   child: Row(children: [
          //     Expanded(
          //       child: SizedBox(
          //         height: 10.h,
          //         child: Center(
          //           child: InkWell(
          //             onTap: () {
          //               isMuted.value = !isMuted.value;
          //
          //             },
          //             child: ValueListenableBuilder(
          //               valueListenable: isMuted,
          //               builder:
          //                   (BuildContext context, bool meMuted, Widget? child) =>
          //                   CircleAvatar(
          //                     radius: 5.h,
          //                     backgroundColor:
          //                     meMuted ? Colors.black12 : Colors.black38,
          //                     child: FaIcon(
          //                       meMuted
          //                           ? FontAwesomeIcons.microphoneSlash
          //                           : FontAwesomeIcons.microphone,
          //                       color: meMuted ? Colors.blue : Colors.white,
          //                       size: 20.sp,
          //                     ),
          //                   ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       child: Padding(
          //         padding: EdgeInsets.only(bottom: 2.h),
          //         child: SizedBox(
          //           height: 10.h,
          //           child: InkWell(
          //             onTap: () {
          //               AgoraManager().leave(
          //                 agoraEngine,
          //                 onchannelLeaveCallback: (isLiveEnded) {
          //                   if (isLiveEnded) {
          //                     //LIVE SESSION ENDED GOTO PREVIOUS SCREEN
          //                     Future.delayed(
          //                       Duration.zero,
          //                           () {
          //                             Get.to(() => BottomNavigationBarScreen(
          //                               index: 0,
          //                             ));
          //                       },
          //                     );
          //                   } else {
          //                     log('live not ended');
          //                   }
          //                 },
          //               );
          //             },
          //             child: Center(
          //               child: CircleAvatar(
          //                 radius: 5.h,
          //                 backgroundColor: Colors.red,
          //                 child: Icon(
          //                   Icons.phone,
          //                   color: Colors.white,
          //                   size: 20.sp,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       child: SizedBox(
          //         height: 10.h,
          //         child: Center(
          //           child: Padding(
          //             padding: EdgeInsets.only(bottom: 2.h),
          //             child: CircleAvatar(
          //               radius: 5.h,
          //               backgroundColor: Colors.black38,
          //               child: Icon(
          //                 Icons.volume_up,
          //                 color: Colors.white,
          //                 size: 20.sp,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ]),
          // ),
          body: ValueListenableBuilder(
            valueListenable: isJoined,
            builder: (BuildContext context, bool isJoin, Widget? child) =>
                ValueListenableBuilder(
              valueListenable: isImHost,
              builder: (BuildContext context, bool meHost, Widget? child) =>
                  Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  //BOTTOM BAR MUTE CALL DISCONNECT SPEAKER
                  SizedBox(
                    //height: 98.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //IS USER JOINED LAYOUT
                        isJoin
                            ? SizedBox(
                                width: double.infinity,
                                height: 100.h,
                                child: CoHostWidget(
                                  remoteUid: remoteUid.value,
                                  agoraEngine: agoraEngine,
                                  channelId: widget.channelname,
                                ),
                                //CO-HOST VIDEO
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.amberAccent,
                                ),
                              )
                      ],
                    ),
                  ),
                  //IS IM HOST YES
                  meHost
                      ? DraggableWidget(
                          bottomMargin: 10.h,
                          topMargin: 10.h,
                          intialVisibility: true,
                          horizontalSpace: 5.h,
                          shadowBorderRadius: 10.h,
                          initialPosition: AnchoringPosition.topLeft,
                          dragController: dragController,
                          child: SizedBox(
                            height: 25.h,
                            width: 35.w,
                            //HOST CHILD
                            child: HostWidget(agoraEngine: agoraEngine),
                          ))
                      : Center(
                          child: Text('Joining...'),
                        ),

                  Positioned(
                    top: 40,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6)),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: status(),
                    ),
                  ),

                  SizedBox(
                    height: 20.h,
                    width: 100.w,
                    child: Row(children: [
                      Expanded(
                        child: SizedBox(
                          height: 10.h,
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                isMuted.value = !isMuted.value;
                                AgoraManager()
                                    .muteVideoCall(isMuted.value, agoraEngine);
                              },
                              child: ValueListenableBuilder(
                                valueListenable: isMuted,
                                builder: (BuildContext context, bool meMuted,
                                        Widget? child) =>
                                    CircleAvatar(
                                  radius: 3.h,
                                  backgroundColor:
                                      meMuted ? Colors.black12 : Colors.black38,
                                  child: FaIcon(
                                    meMuted
                                        ? FontAwesomeIcons.microphoneSlash
                                        : FontAwesomeIcons.microphone,
                                    color: meMuted ? Colors.blue : Colors.white,
                                    size: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: SizedBox(
                            height: 10.h,
                            child: InkWell(
                              onTap: () {
                                if (_callController.totalSeconds < 60 &&
                                    remoteUid.value != null) {
                                  Get.dialog(
                                    EndDialog(),
                                  );
                                  // Get.dialog(
                                  //   AlertDialog(
                                  //     backgroundColor: Colors.white,
                                  //     contentPadding: const EdgeInsets.all(0),
                                  //     titlePadding: const EdgeInsets.symmetric(
                                  //         vertical: 8, horizontal: 10),
                                  //     title: Text(
                                  //       "You can end chat after one minute",
                                  //       style: Get.textTheme.titleMedium,
                                  //     ).tr(),
                                  //     content: TextButton(
                                  //       onPressed: () {
                                  //         Get.back();
                                  //       },
                                  //       child: Text('Ok',
                                  //               style: TextStyle(
                                  //                   color:
                                  //                       Get.theme.primaryColor))
                                  //           .tr(),
                                  //     ),
                                  //   ),
                                  // );
                                } else {
                                  AgoraManager().leave(
                                    agoraEngine,
                                    onchannelLeaveCallback:
                                        (isLiveEnded) async {
                                      if (isLiveEnded) {
                                        //LIVE SESSION ENDED GOTO PREVIOUS SCREEN
                                        // callController.update();
                                        //  await   stopRecord();
                                        // await  stopRecord2();
                                        global.showOnlyLoaderDialog(context);
                                        if (timer2 != null) {
                                          timer2?.cancel();
                                          timer2 = null;
                                        }
                                        await callController.endCall(
                                            widget.callId,
                                            _callController.totalSeconds,
                                            global.agoraSid1,
                                            global.agoraSid2);
                                        await global.splashController
                                            .getCurrentUserData();
                                        // await historyController.getChatHistory(
                                        //     global.currentUserId!, false);
                                        BottomNavigationController
                                            bottomNavigationController =
                                            Get.find<
                                                BottomNavigationController>();
                                        bottomNavigationController.setIndex(
                                            0, 0);
                                        global.hideLoader();
                                        Get.back();
                                        Get.back();
                                        Get.to(() => BottomNavigationBarScreen(
                                              index: 0,
                                            ));
                                      } else {
                                        log('live not ended');
                                      }
                                    },
                                  );
                                }
                              },
                              child: Center(
                                child: CircleAvatar(
                                  radius: 4.h,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.call_end,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 10.h,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: InkWell(
                                onTap: () {
                                  isSpeaker.value = !isSpeaker.value;
                                  AgoraManager()
                                      .onVolume(isSpeaker.value, agoraEngine);
                                },
                                child: ValueListenableBuilder(
                                  valueListenable: isSpeaker,
                                  builder: (BuildContext context,
                                          bool meSpeaker, Widget? child) =>
                                      CircleAvatar(
                                    radius: 3.h,
                                    backgroundColor: meSpeaker
                                        ? Colors.black12
                                        : Colors.black38,
                                    child: Icon(
                                      meSpeaker
                                          ? FontAwesomeIcons.volumeHigh
                                          : FontAwesomeIcons.volumeLow,
                                      color: meSpeaker
                                          ? Colors.blue
                                          : Colors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
          )),
    );
  }

  void handler() {
    agoraEventHandler.handleEvent(agoraEngine);
  }

  Timer? timer2;

  // Future startRecord() async {
  //   CallController callController = Get.find<CallController>();
  //   await callController.agoraStartRecording(widget.channelname, conneId, widget.fcmToken);
  // }
  //
  // Future startRecord2() async {
  //   CallController callController = Get.find<CallController>();
  //   //print('stop1 audio recording in live astrologer $remoteIdForStop');
  //   await callController.agoraStartRecording2(widget.channelname, remoteUid.value!, widget.fcmToken);
  // }
  // Future stopRecord2() async {
  //   CallController callController = Get.find<CallController>();
  //   //print('stop2 audio recording in live astrologer $remoteIdForStop');
  //   await callController.agoraStopRecording2(widget.callId, widget.channelname, remoteUid.value!);
  // }
  //
  // Future stopRecord() async {
  //   CallController callController = Get.find<CallController>();
  //   await callController.agoraStopRecording(widget.callId, widget.channelname, conneId);
  // }

  void initagora() async {
    //FIRST GENERATE TOKEN THEN USE IT FOR VIDEO
    agoraEngine = await AgoraManager().initializeAgora(
        global.getSystemFlagValue(global.systemFlagNameList.agoraAppId));
    AgoraManager()
        .joinChannel(widget.fcmToken, widget.channelname, agoraEngine);
    agoraEventHandler = AgoraEventHandler(
      onJoinChannelSuccessCallback: (isHost, localUid) {
        isImHost.value = isHost;
        conneId = localUid!;
        setState(() {});
        log('Local ID-> $conneId');
      },
      onUserJoinedCallback: (remoteId, isJoin) async {
        isJoined.value = isJoin!;
        remoteUid.value = remoteId;
        endTime = DateTime.now().millisecondsSinceEpoch +
            1000 * int.parse(widget.end_time);
        _callController.totalSeconds = 0;
        _callController.update();
        timer2 = Timer.periodic(Duration(seconds: 1), (timer) async {
          _callController.totalSeconds = _callController.totalSeconds + 1;
          _callController.update();
          print('totalsecons ${_callController.totalSeconds}');
        });
        callController.isLeaveCall = false;
        callController.update();
      },
      onUserMutedCallback: (remoteUid3, muted) {
        log('Is muted->  $muted');
        if (remoteUid.value == remoteUid3) {
          if (muted == true) {
            isImHost.value = true;
            log('isimHost in onUserMuteVideo muted $isImHost');
          } else {
            isImHost.value = true;
            log('isimHost in onUserMuteVideo mutede else $isImHost');
          }
        }
      },
      onUserOfflineCallback: (id, reason) {
        debugPrint("User is Offiline reasion is -> $reason");
        remoteUid.value = null;
        if (reason == UserOfflineReasonType.userOfflineQuit) {
          print("userOfflineQuit");
          AgoraManager().leave(agoraEngine,
              onchannelLeaveCallback: (isLiveEnded) async {
            // stopRecord();
            // stopRecord2();
            if (isLiveEnded) {
              global.showOnlyLoaderDialog(context);
              if (timer2 != null) {
                timer2?.cancel();
                timer2 = null;
              }
              await callController
                  .endCall(widget.callId, _callController.totalSeconds,
                      global.agoraSid1, global.agoraSid2)
                  .then((value) async {
                await global.splashController.getCurrentUserData();

                BottomNavigationController bottomNavigationController =
                    Get.find<BottomNavigationController>();
                global.hideLoader();
                bottomNavigationController.setIndex(0, 0);
                Get.back();
                Get.back();
                Get.to(() => BottomNavigationBarScreen(
                      index: 0,
                    ));
              });
            }
          });
        } else if (reason == UserOfflineReasonType.userOfflineDropped) {
          print("userOfflineDropped");
          AgoraManager().leave(agoraEngine,
              onchannelLeaveCallback: (isLiveEnded) async {
            //  await   stopRecord();
            // await  stopRecord2();

            if (isLiveEnded) {
              global.showOnlyLoaderDialog(context);
              if (timer2 != null) {
                timer2?.cancel();
                timer2 = null;
              }
              await callController
                  .endCall(widget.callId, _callController.totalSeconds,
                      global.agoraSid1, global.agoraSid2)
                  .then((value) async {
                global.hideLoader();

                await global.splashController.getCurrentUserData();

                BottomNavigationController bottomNavigationController =
                    Get.find<BottomNavigationController>();
                global.hideLoader();
                bottomNavigationController.setIndex(0, 0);
                Get.back();
                Get.back();
                Get.to(() => BottomNavigationBarScreen(
                      index: 0,
                    ));
              });
            }
          });
        }
      },
      onUserLeaveChannelCallback: (con, sc) async {
        debugPrint("onLeaveChannel called id- >${con.localUid}");
        isJoined.value = false;
        remoteUid.value = null;
        agoraEngine.leaveChannel();
        agoraEngine.release();
        await global.splashController.getCurrentUserData();
        BottomNavigationController bottomNavigationController =
            Get.find<BottomNavigationController>();
        //global.hideLoader();
        bottomNavigationController.setIndex(0, 0);
        Get.back();
        Get.back();
        Get.to(() => BottomNavigationBarScreen(
              index: 0,
            ));
      },
      onAgoraError: (err, msg) {
        log('error agora - $err  and msg is - $msg');
      },
    );
    handler();
  }

  int? endTime;
  Widget status() {
    return endTime == null
        ? Text("Joining..",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ))
        : CountdownTimer(
            endTime: endTime,
            widgetBuilder: (_, CurrentRemainingTime? time) {
              if (time == null) {
                return const Text('Joining..',
                    style: const TextStyle(fontWeight: FontWeight.w500));
              }
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: time.hours != null && time.hours != 0
                    ? Text(
                        '${time.hours ?? '00'} :${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      )
                    : time.min != null
                        ? Text(
                            '${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )
                        : Text(
                            '${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                // child: time.min != null || time.hours!=null
                //     ? Text('${time.hours??"00"} :${time.min! <= 9 ? '0${time.min}': time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}': time.sec ?? '00'}',
                //         style: const TextStyle(fontWeight: FontWeight.w500))
                //     : Text(
                //         '${time.sec}',
                //         style: const TextStyle(fontWeight: FontWeight.w500),
                //       ),
              );
            },
            onEnd: () async {
              log('in onEnd ${callController.isLeaveCall}');
              if (callController.isLeaveCall == false) {
                global.showOnlyLoaderDialog(Get.context);
                // await   stopRecord();
                // await  stopRecord2();
                remoteUid.value = null;
                if (timer2 != null) {
                  timer2?.cancel();
                  timer2 = null;
                }
                AgoraManager().leave(agoraEngine,
                    onchannelLeaveCallback: (isLiveEnded) async {
                  if (isLiveEnded) {
                    global.showOnlyLoaderDialog(context);
                    if (timer2 != null) {
                      timer2?.cancel();
                      timer2 = null;
                    }
                    await callController
                        .endCall(widget.callId, _callController.totalSeconds,
                            global.agoraSid1, global.agoraSid2)
                        .then((value) async {
                      global.hideLoader();
                      await global.splashController.getCurrentUserData();
                      BottomNavigationController bottomNavigationController =
                          Get.find<BottomNavigationController>();
                      global.hideLoader();
                      bottomNavigationController.setIndex(0, 0);
                      Get.back();
                      Get.back();
                      Get.to(() => BottomNavigationBarScreen(
                            index: 0,
                          ));
                    });
                  }
                });
                callController.isLeaveCall = true;
                log('totalSeconds ${callController.totalSeconds}');
                global.hideLoader();

              }
            },
          );
  }
}
