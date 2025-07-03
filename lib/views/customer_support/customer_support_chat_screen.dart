// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:AstrowayCustomer/controllers/customer_support_controller.dart';
import 'package:AstrowayCustomer/model/chat_message_model.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class CustomerSupportChatScreen extends StatelessWidget {
  final int flagId;
  final String ticketNo;
  final String fireBasechatId;
  final int ticketId;
  final String ticketStatus;
  CustomerSupportChatScreen(
      {super.key,
      required this.flagId,
      required this.ticketNo,
      required this.fireBasechatId,
      required this.ticketId,
      required this.ticketStatus});
  final TextEditingController messageController = TextEditingController();
  CustomerSupportController customerSupportController =
      Get.find<CustomerSupportController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        customerSupportController.isIn = false;
        customerSupportController.update();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor:
                Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
            title: GestureDetector(
              onTap: () async {},
              child: Text(
                '${tr("Ticket No")}: $ticketNo',
                style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ),
            leading: IconButton(
              onPressed: () async {
                customerSupportController.isIn = false;
                customerSupportController.update();
                Get.back();
              },
              icon: Icon(
                  kIsWeb
                      ? Icons.arrow_back
                      : Platform.isIOS
                          ? Icons.arrow_back_ios
                          : Icons.arrow_back,
                  color: Colors.white),
            ),
            actions: [],
          ),
          body: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                GetBuilder<CustomerSupportController>(
                    builder: (customerSupportController) {
                  return Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                            stream: customerSupportController.getChatMessages(
                                fireBasechatId, global.currentUserId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState.name == "waiting") {
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
                                        ChatMessageModel.fromJson(res.data()));
                                  }
                                  print(messageList.length);
                                  return ListView.builder(
                                      padding:
                                          const EdgeInsets.only(bottom: 50),
                                      itemCount: messageList.length,
                                      shrinkWrap: true,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        ChatMessageModel message =
                                            messageList[index];
                                        customerSupportController.isMe =
                                            message.userId1 ==
                                                '${global.currentUserId}';
                                        print(
                                            'isIn? ${customerSupportController.isIn}');

                                        return Row(
                                          mainAxisAlignment:
                                              customerSupportController.isMe
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: customerSupportController
                                                        .isMe
                                                    ? Colors.grey[300]
                                                    : Get.theme.primaryColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      const Radius.circular(12),
                                                  topRight:
                                                      const Radius.circular(12),
                                                  bottomLeft:
                                                      customerSupportController
                                                              .isMe
                                                          ? const Radius
                                                              .circular(0)
                                                          : const Radius
                                                              .circular(12),
                                                  bottomRight:
                                                      customerSupportController
                                                              .isMe
                                                          ? const Radius
                                                              .circular(0)
                                                          : const Radius
                                                              .circular(12),
                                                ),
                                              ),
                                              width: Get.width * 0.6,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 16),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    customerSupportController
                                                            .isMe
                                                        ? CrossAxisAlignment.end
                                                        : CrossAxisAlignment
                                                            .start,
                                                children: [
                                                  Text(
                                                    messageList[index].message!,
                                                    style: TextStyle(
                                                      color:
                                                          customerSupportController
                                                                  .isMe
                                                              ? Colors.black
                                                              : Colors.white,
                                                    ),
                                                    textAlign:
                                                        customerSupportController
                                                                .isMe
                                                            ? TextAlign.end
                                                            : TextAlign.start,
                                                  ),
                                                  messageList[index]
                                                              .createdAt !=
                                                          null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                  DateFormat()
                                                                      .add_jm()
                                                                      .format(messageList[
                                                                              index]
                                                                          .createdAt!),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        9.5,
                                                                  )),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox()
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
                      customerSupportController.status.toUpperCase() == "OPEN"
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(8),
                                child: GetBuilder<CustomerSupportController>(
                                    builder: (customerSupportController) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30.0)),
                                          ),
                                          height: 50,
                                          child: TextField(
                                            controller: messageController,
                                            onChanged: (value) {},
                                            cursorColor: Colors.black,
                                            style:
                                                TextStyle(color: Colors.black),
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(30.0)),
                                                borderSide: BorderSide(
                                                    color:
                                                        Get.theme.primaryColor),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(30.0)),
                                                borderSide: BorderSide(
                                                    color:
                                                        Get.theme.primaryColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Material(
                                          elevation: 3,
                                          color: Colors.transparent,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(100),
                                          ),
                                          child: Container(
                                            height: 49,
                                            width: 49,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Get.theme.primaryColor,
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                if (messageController.text !=
                                                    "") {
                                                  customerSupportController
                                                      .sendMessage(
                                                          messageController
                                                              .text,
                                                          fireBasechatId,
                                                          ticketId);
                                                  messageController.clear();
                                                }
                                              },
                                              child: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: Icon(
                                                  Icons.send,
                                                  size: 25,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            )
                          : const SizedBox(),
                      customerSupportController.status.toUpperCase() == "PAUSED"
                          ? GetBuilder<CustomerSupportController>(
                              builder: (customerSupportController) {
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: Card(
                                  elevation: 1,
                                  child: Container(
                                    width: Get.width,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 228, 224, 193),
                                      border: Border.all(
                                          color: Get.theme.primaryColor),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('uh oh! It seems like you were away.Don\'t worry our support manager will join soon to resume your ticket.')
                                            .tr(),
                                        ElevatedButton(
                                          onPressed: () async {
                                            global
                                                .showOnlyLoaderDialog(context);
                                            await customerSupportController
                                                .restartSupportChat(ticketId);
                                            global.hideLoader();
                                            Get.back();
                                          },
                                          child: Text('Restart Chat').tr(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                          : const SizedBox(),
                      customerSupportController.status.toUpperCase() ==
                              "WAITING"
                          ? GetBuilder<CustomerSupportController>(builder: (c) {
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: Card(
                                  elevation: 1,
                                  child: Container(
                                    width: Get.width,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 228, 224, 193),
                                      border: Border.all(
                                          color: Get.theme.primaryColor),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Please wait while our support manager joins the chat.It might take up to 20 minutes for the chat to initiate.We will notify you once the chat initiates.')
                                            .tr(),
                                        Text(
                                          'wait Time ~ 20m',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ).tr(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                          : const SizedBox(),
                      customerSupportController.status.toUpperCase() == "CLOSED"
                          ? GetBuilder<CustomerSupportController>(builder: (c) {
                              return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GetBuilder<CustomerSupportController>(
                                      builder: (customerSupportController) {
                                    return customerSupportController.isAddEdit
                                        ? Card(
                                            elevation: 1,
                                            child: Container(
                                              width: Get.width,
                                              color: Color.fromARGB(
                                                  255, 228, 224, 193),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Your Review').tr(),
                                                    RatingBar(
                                                      initialRating:
                                                          customerSupportController
                                                              .rating,
                                                      itemCount: 5,
                                                      allowHalfRating: true,
                                                      itemSize: 35,
                                                      ratingWidget:
                                                          RatingWidget(
                                                        full: const Icon(
                                                            Icons.grade,
                                                            color:
                                                                Colors.yellow),
                                                        half: const Icon(
                                                            Icons.star_half,
                                                            color:
                                                                Colors.yellow),
                                                        empty: const Icon(
                                                            Icons.grade,
                                                            color: Colors.grey),
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        customerSupportController
                                                            .rating = rating;
                                                        customerSupportController
                                                            .update();
                                                      },
                                                    ),
                                                    TextField(
                                                      controller:
                                                          customerSupportController
                                                              .reviewController,
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
                                                      minLines: 5,
                                                      maxLines: 5,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        hintStyle: TextStyle(
                                                            fontSize: 12),
                                                        hintText: tr(
                                                            "Describe your experience(optional)"),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5.0)),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5.0)),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5.0)),
                                                        ),
                                                      ),
                                                      maxLength: 160,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        if (customerSupportController
                                                                .reviewId !=
                                                            null) {
                                                          print(
                                                              'update review');
                                                          global
                                                              .showOnlyLoaderDialog(
                                                                  context);
                                                          await customerSupportController
                                                              .updateCustomerReview(
                                                                  customerSupportController
                                                                      .reviewId!);
                                                          global.hideLoader();
                                                        } else {
                                                          global
                                                              .showOnlyLoaderDialog(
                                                                  context);
                                                          await customerSupportController
                                                              .addCustomerReview(
                                                                  ticketId);
                                                          global.hideLoader();
                                                        }
                                                      },
                                                      child:
                                                          Text('Submit').tr(),
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Get.theme
                                                                    .primaryColor),
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Card(
                                            elevation: 1,
                                            child: Container(
                                              width: Get.width,
                                              color: Color.fromARGB(
                                                  255, 228, 224, 193),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Your Review').tr(),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                CachedNetworkImage(
                                                                  imageUrl:
                                                                      "${global.imgBaseurl}${global.splashController.currentUser?.profile}",
                                                                  imageBuilder:
                                                                      (context,
                                                                          imageProvider) {
                                                                    return CircleAvatar(
                                                                      radius:
                                                                          22,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                              "${global.imgBaseurl}${global.splashController.currentUser?.profile}"),
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
                                                                    return CircleAvatar(
                                                                        radius:
                                                                            22,
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
                                                                  width: 10,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(global
                                                                            .splashController
                                                                            .currentUser!
                                                                            .name ??
                                                                        'User'),
                                                                    RatingBar(
                                                                      initialRating:
                                                                          customerSupportController
                                                                              .rating,
                                                                      itemCount:
                                                                          5,
                                                                      allowHalfRating:
                                                                          true,
                                                                      itemSize:
                                                                          15,
                                                                      ignoreGestures:
                                                                          true,
                                                                      ratingWidget:
                                                                          RatingWidget(
                                                                        full: const Icon(
                                                                            Icons
                                                                                .grade,
                                                                            color:
                                                                                Colors.yellow),
                                                                        half: const Icon(
                                                                            Icons
                                                                                .star_half,
                                                                            color:
                                                                                Colors.yellow),
                                                                        empty: const Icon(
                                                                            Icons
                                                                                .grade,
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                      onRatingUpdate:
                                                                          (rating) {},
                                                                    ),
                                                                    Text(customerSupportController
                                                                        .reviewController
                                                                        .text),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            customerSupportController
                                                                    .isAddEdit =
                                                                true;
                                                            customerSupportController
                                                                .update();
                                                          },
                                                          child: Center(
                                                              child: Text(
                                                            'Edit your review',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ).tr()),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                  }));
                            })
                          : const SizedBox()
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
