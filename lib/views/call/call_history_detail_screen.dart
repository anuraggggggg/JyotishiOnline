// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/views/call/player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/bottomNavigationController.dart';
import '../../controllers/reviewController.dart';
import '../../utils/images.dart';
import '../astrologerProfile/astrologerProfile.dart';

class CallHistoryDetailScreen extends StatefulWidget {
  final int astrologerId;
  final String astrologerProfile;
  final int index;
  final int callType;
  CallHistoryDetailScreen(
      {a,
      o,
      required this.astrologerId,
      required this.astrologerProfile,
      required this.index,
      required this.callType})
      : super();

  @override
  State<CallHistoryDetailScreen> createState() =>
      _CallHistoryDetailScreenState();
}

class _CallHistoryDetailScreenState extends State<CallHistoryDetailScreen> {
  final HistoryController historyController = Get.find<HistoryController>();

  final BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();

  @override
  void initState() {
    historyController.inIt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await historyController.disposeAudioPlayer();
        await historyController.disposeAudioPlayer2();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor:
              Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
          title: GestureDetector(
            onTap: () async {
              Get.find<ReviewController>().getReviewData(widget.astrologerId);
              global.showOnlyLoaderDialog(context);
              await bottomNavigationController
                  .getAstrologerbyId(widget.astrologerId);
              global.hideLoader();
              Get.to(() => AstrologerProfile(
                    index: 0,
                  ));
            },
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: widget.astrologerProfile == "" ||
                          historyController.callHistoryListById.isEmpty
                      ? Image.asset(
                          Images.deafultUser,
                          height: 40,
                          width: 30,
                        )
                      : CachedNetworkImage(
                          imageUrl:
                              '${global.imgBaseurl}${widget.astrologerProfile}',
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Image.asset(
                            Images.deafultUser,
                            height: 40,
                            width: 30,
                          ),
                        ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  historyController.callHistoryListById.isEmpty
                      ? ""
                      : historyController
                          .callHistoryListById[0].astrologerName!,
                  style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          leading: IconButton(
            onPressed: () async {
              await historyController.disposeAudioPlayer();
              await historyController.disposeAudioPlayer2();
              Get.back();
            },
            icon: Icon(
                kIsWeb
                    ? Icons.arrow_back
                    : Platform.isIOS
                        ? Icons.arrow_back_ios
                        : Icons.arrow_back,
                color: Colors.white //Get.theme.iconTheme.color,
                ),
          ),
        ),
        body: historyController.callHistoryListById.isEmpty
            ? Center(
                child: Text('No Details Found').tr(),
              )
            : Container(
                width: Get.width,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white),
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appoinment Schedule:',
                              style: Get.textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ).tr(),
                            Text(
                                '${tr("Expert Name:")} ${historyController.callHistoryListById[0].astrologerName}'),
                            Text(
                              "${DateFormat("dd MMM yy, hh:mm a").format(DateTime.parse(historyController.callHistoryListById[0].createdAt.toString()))}",
                            ),
                            Text(
                                '${tr("Duration:")} ${historyController.callHistoryListById[0].totalMin ?? 0} ${tr("Minutes")}'),
                            Text(
                                '${tr("Price")}: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.callHistoryListById[0].callRate}'),
                            Text(
                                '${tr("Deduction")}: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.callHistoryListById[0].deduction}')
                          ],
                        ),
                      ),
                    ),
                    // Card(
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(6.0),
                    //     child: GetBuilder<HistoryController>(
                    //         builder: (historyController) {
                    //       return Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //         children: [
                    //           CircleAvatar(
                    //             child: IconButton(
                    //               onPressed: () async {
                    //                 try {
                    //                   print("${historyController.isPlay}");
                    //                   if (historyController.isPlay) {
                    //                     await historyController.audioPlayer
                    //                         .pause();
                    //                     await historyController.audioPlayer2
                    //                         .pause();
                    //                     historyController.update();
                    //                   } else {
                    //                     print('startPlay');
                    //                     await historyController.audioPlayer
                    //                         .play(UrlSource(
                    //                             "https://s3-ap-south-1.amazonaws.com/astroway/${historyController.callHistoryListById[0].sId1}_${historyController.callHistoryListById[0].channelName}.m3u8"));
                    //                     //     await historyController.audioPlayer.play(UrlSource("https://file-examples.com/storage/fe3269a6ea65d68689ae021/2017/11/file_example_WAV_1MG.wav"));
                    //                     if (historyController
                    //                                 .callHistoryListById[
                    //                                     widget.index]
                    //                                 .sId1 !=
                    //                             null &&
                    //                         historyController
                    //                                 .callHistoryListById[
                    //                                     widget.index]
                    //                                 .sId1 !=
                    //                             "") {
                    //                       await historyController.audioPlayer2
                    //                           .play(UrlSource(
                    //                               "https://s3-ap-south-1.amazonaws.com/astroway/${historyController.callHistoryListById[0].sId}_${historyController.callHistoryListById[0].channelName}.m3u8"));
                    //                     }
                    //                   }
                    //
                    //                   historyController.isPlay =
                    //                       !historyController.isPlay;
                    //                   historyController.update();
                    //                 } catch (e) {
                    //                   print('audio Exception :- $e');
                    //                 }
                    //               },
                    //               icon: Icon(
                    //                 historyController.isPlay
                    //                     ? Icons.pause
                    //                     : Icons.play_arrow,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //           ),
                    //           Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Slider(
                    //                 value: historyController.position.inSeconds
                    //                     .toDouble(),
                    //                 max: historyController.duration.inSeconds
                    //                     .toDouble(),
                    //                 min: 0,
                    //                 onChanged: (_) {},
                    //               ),
                    //               Container(
                    //                 width: Get.width - 180,
                    //                 child: Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceBetween,
                    //                   children: [
                    //                     Text(
                    //                       '${Duration(
                    //                         seconds: historyController
                    //                             .position.inSeconds
                    //                             .toInt(),
                    //                       ).toString().split(".")[0]}',
                    //                       style: TextStyle(fontSize: 10),
                    //                     ),
                    //                     Text(
                    //                       '${Duration(seconds: historyController.duration.inSeconds.toInt()).toString().split(".")[0]}',
                    //                       style: TextStyle(fontSize: 10),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               )
                    //             ],
                    //           ),
                    //           GestureDetector(
                    //             onTap: () {
                    //               global.createAndShareLinkForHistoryChatCall();
                    //             },
                    //             child: Container(
                    //               margin: const EdgeInsets.only(left: 5),
                    //               padding: const EdgeInsets.symmetric(
                    //                   horizontal: 8, vertical: 6),
                    //               decoration: BoxDecoration(
                    //                 color: Get.theme.primaryColor,
                    //                 borderRadius: BorderRadius.circular(15),
                    //               ),
                    //               child: Icon(Icons.share,
                    //               color: Colors.white,),
                    //             ),
                    //           )
                    //         ],
                    //       );
                    //     }),
                    //   ),
                    // ),
                    widget.callType == 10
                        ? GestureDetector(
                            onTap: () {
                              log("ssid ${historyController.callHistoryListById[0].sId}");
                              log("ssid1  ${historyController.callHistoryListById[0].sId1}");

                              Get.to(() => Player(
                                  sid: historyController
                                      .callHistoryListById[0].sId
                                      .toString()));
                            },
                            child: Container(
                              height: 6.h,
                              width: 40.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.h),
                                border:
                                    Border.all(color: Colors.pink, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  'Play',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),

                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        Get.dialog(AlertDialog(
                            backgroundColor: Colors.white,
                            scrollable: true,
                            title: Container(
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Icon(Icons.close),
                                  )),
                            ),
                            titlePadding: const EdgeInsets.all(0),
                            content: addReviewWidget(
                                historyController.callHistoryListById.isEmpty
                                    ? ""
                                    : historyController
                                        .callHistoryListById[0].astrologerName!,
                                "astrologerProfile",
                                context)));
                        // addReviewWidget(historyController.callHistoryListById.isEmpty
                        //     ? ""
                        //     : historyController
                        //     .callHistoryListById[0].astrologerName!,widget.astrologerProfile,context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Text("Add your Review"),
                        )),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget addReviewWidget(
      String astrologerName, String astrologerProfile, BuildContext context) {
    SplashController splashController = Get.find<SplashController>();
    return GetBuilder<ChatController>(builder: (chatController) {
      return SizedBox(
        height: Get.height * 0.6,
        child: Column(
          children: [
            Center(child: Text(astrologerName).tr()),
            widget.astrologerProfile == ""
                ? Center(
                    child: CircleAvatar(
                      radius: 33,
                      child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            Images.deafultUser,
                            fit: BoxFit.fill,
                            height: 40,
                          )),
                    ),
                  )
                : Center(
                    child: CachedNetworkImage(
                      imageUrl:
                          "${global.imgBaseurl}${widget.astrologerProfile}",
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: imageProvider,
                        );
                      },
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              Images.deafultUser,
                              fit: BoxFit.fill,
                              height: 40,
                            ));
                      },
                    ),
                  ),
            Row(
              children: [
                !chatController.isPublic
                    ? splashController.currentUser?.profile == ""
                        ? CircleAvatar(
                            radius: 22,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(Images.deafultUser),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl:
                                "${global.imgBaseurl}${splashController.currentUser?.profile}",
                            imageBuilder: (context, imageProvider) {
                              return CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                    "${global.imgBaseurl}${splashController.currentUser?.profile}"),
                              );
                            },
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              return CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    Images.deafultUser,
                                    fit: BoxFit.fill,
                                    height: 50,
                                  ));
                            },
                          )
                    : CircleAvatar(
                        radius: 22,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(Images.deafultUser),
                        ),
                      ),
                const SizedBox(
                  width: 10,
                ),
                !chatController.isPublic
                    ? Text(splashController.currentUser!.name ?? "Anonymous")
                        .tr()
                    : Text("Anonymous").tr(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                    value: chatController.isPublic,
                    activeColor: Get.theme.primaryColor,
                    onChanged: (bool? value) {
                      chatController.isPublic = value!;
                      chatController.update();
                    }),
                SizedBox(
                  width: Get.width * 0.5,
                  child: Text('Hide my name from all public reviews',
                      style: Get.textTheme.titleMedium!.copyWith(
                        fontSize: 12,
                      )).tr(),
                )
              ],
            ),
            Center(
              child: RatingBar(
                initialRating: chatController.rating ?? 0,
                itemCount: 5,
                allowHalfRating: true,
                ratingWidget: RatingWidget(
                  full: const Icon(Icons.grade, color: Colors.yellow),
                  half: const Icon(Icons.star_half, color: Colors.yellow),
                  empty: const Icon(Icons.grade, color: Colors.grey),
                ),
                onRatingUpdate: (rating) {
                  chatController.rating = rating;
                  chatController.update();
                },
              ),
            ),
            TextField(
              controller: chatController.reviewController,
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                hintStyle: TextStyle(fontSize: 12),
                hintText: "Describe your experience(optional)",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                    backgroundColor:
                        MaterialStateProperty.all(Get.theme.primaryColor),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    print('submit');
                    if (chatController.rating == 0) {
                      global.showToast(
                        message: 'Rate Astrologer',
                        textColor: global.textColor,
                        bgColor: global.toastBackGoundColor,
                      );
                    } else if (chatController.reviewController.text == "") {
                      global.showToast(
                        message: 'Enter Review',
                        textColor: global.textColor,
                        bgColor: global.toastBackGoundColor,
                      );
                    } else {
                      if (chatController.reviewData.isNotEmpty) {
                        global.showOnlyLoaderDialog(context);
                        await chatController.updateReview(
                            chatController.reviewData[0].id!,
                            widget.astrologerId);
                        global.hideLoader();
                      } else {
                        global.showOnlyLoaderDialog(context);
                        await chatController.addReview(widget.astrologerId);
                        global.hideLoader();
                      }
                    }
                  },
                  child: Text(
                    'Submit',
                    textAlign: TextAlign.center,
                    style: Get.theme.primaryTextTheme.titleMedium!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ).tr(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
