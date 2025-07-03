// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/model/astrologerCategoryModel.dart';
import 'package:AstrowayCustomer/model/astrologer_model.dart';
import 'package:AstrowayCustomer/model/reviewModel.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/message_model.dart';

import '../model/chat_message_model.dart';
import 'package:pdf/widgets.dart' as pw;

class ChatController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var categoryList = <AstrologerCategoryModel>[];
  int isSelected = 0.obs();
  TabController? categoryTab;
  var astroList = <AstrologerModel>[];
  var reviewData = <ReviewModel>[];
  bool isEndChat = false;

  int? astrologerId;
  APIHelper apiHelper = APIHelper();
  //agora chat channnelName for current user and current astrologer
  String channelId = "";
  // agora current user id
  String agorauserId = "";
  //  agora current astrologer user id
  double? rating;
  bool isPublic = true;
  TextEditingController reviewController = TextEditingController();

  String agoraAstrologerUserId = "";
  ChatMessageModel chatmessage = ChatMessageModel();
  CollectionReference userChatCollectionRef =
      FirebaseFirestore.instance.collection("chats");
  bool showBottomAcceptChat = false;
  int? bottomAstrologerId;
  String bottomAstrologerName = "Astrologer";
  String? bottomAstrologerProfile;
  String? bottomFirebaseChatId;
  int? bottomChatId;
  String? bottomFcmToken;
  bool? isAstrologerEndedChat;
  bool chatBottom = false;
  bool isInchat = false;
  var pdf = pw.Document();
  String? duration;
  CollectionReference userChatCollectionRefRTM =
      FirebaseFirestore.instance.collection("LiveChats");
  bool isTimerEnded = false;
  ChatMessageModel? replymessage = ChatMessageModel();
  bool isUploading = false;

  @override
  void onInit() async {
    await _init();
    super.onInit();
    categoryTab = TabController(
        vsync: this, length: categoryList.length, initialIndex: isSelected);
  }

  @override
  void dispose() {
    categoryTab?.dispose();
    super.dispose();
  }

  _init() async {
    await getAstrologerCategorys();
  }

  Future<void> sendReplyMessage(String message, String chatId, int partnerId,
      bool isEndMessage, String replymsg) async {
    debugPrint('chatID $chatId partnerId $partnerId');
    try {
      if (message.trim() != '') {
        ChatMessageModel chatMessage = ChatMessageModel(
          message: message,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDelete: false,
          isRead: true,
          userId1: '${global.currentUserId}',
          userId2: '$partnerId',
          isEndMessage: isEndMessage,
          replymsg: replymsg,
        );
        update();
        await uploadMessage(chatId, '$partnerId', chatMessage);
      } else {}
    } catch (e) {
      print('Exception in sendMessage ${e.toString()}');
    }
  }

  // Update Profile Image on Firebase
  Future<void> updateProfileImage(
      String partnerId, String chatId, String imageUrl) async {
    ChatMessageModel chatMessageModel = ChatMessageModel(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDelete: false,
      isRead: true,
      userId1: '${global.currentUserId}',
      userId2: '$partnerId',
      attachementPath: imageUrl,
      isEndMessage: false,
    );
    // global.hideLoader();
    // Upload the message to Firestore
    await uploadMessage(chatId, '$partnerId', chatMessageModel);
  }

  Future<void> uploadImage(
      File imageFile, String partnerId, String chatId) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child(
          '$chatId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}');
      final uploadTask = await storageReference.putFile(imageFile);
      if (uploadTask.state == TaskState.success) {
        debugPrint('image uploaded');
      }
      String downloadURL = await storageReference.getDownloadURL();
      debugPrint('File Uploaded: $downloadURL');
      updateProfileImage(partnerId, chatId, downloadURL);
    } catch (e) {
      log("Upload image exception:- $e");
    }
  }

//UPload Files to firebase
  Future<void> sendFiletoFirebase(
    // String message,
    String chatId,
    int partnerId,
    File? file,
    BuildContext context,
  ) async {
    try {
      if (file != null) {
        isUploading = true;
        update();
        // global.showOnlyLoaderDialogLinear(context);
        uploadImage(file, partnerId.toString(), chatId);
      } else {
        debugPrint('no file to upload on firebase');
      }
    } catch (e) {
      print('Exception in sendMessage ${e.toString()}');
    }
  }

  bool isMeForShare = false;
  shareChat(String chatId, String astrologer) async {
    try {
      await FlutterShare.share(
              title:
                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)}',
              text:
                  "Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)} to get predictions related to marriage/career.Check my chat with $astrologer.You should also try and see your future first chat is Free!")
          .then((value) {})
          .catchError((e) {
        print(e);
      });
    } catch (e) {
      log('Exception in shareChat $e');
    }
  }

  Future<List<ChatMessageModel?>?> getShareMessages({String? chatId}) async {
    try {
      Stream<List<ChatMessageModel>> m = FirebaseFirestore.instance
          .collection('chats/$chatId/userschat')
          .doc('${global.currentUserId}')
          .collection('messages')
          .orderBy("createdAt", descending: false)
          .snapshots()
          .map((reviews) => reviews.docs
              .map((review) => ChatMessageModel.fromJson(review.data()))
              .toList());
      print(m.length);
      List<ChatMessageModel> mm = await m.first;
      return mm.isNotEmpty ? mm : [];
    } catch (err) {
      print(
          "Exception - apiHelper.dart - getShareMessages() ${err.toString()}");
      return null;
    }
  }

  showBottomAcceptChatRequest(
      {required int astrologerId,
      required int chatId,
      required String astroName,
      required String fcmToken,
      required String astroProfile,
      required String firebaseChatId,
      required String duration}) async {
    log("check");
    showBottomAcceptChat = true;
    bottomAstrologerId = astrologerId;
    bottomAstrologerName = astroName;
    bottomAstrologerProfile = astroProfile;
    bottomFirebaseChatId = firebaseChatId;
    bottomChatId = chatId;
    bottomFcmToken = fcmToken;
    duration = duration;
    update();
    print('showBottomAcceptChat:- $showBottomAcceptChat');
    global.sp = await SharedPreferences.getInstance();
    global.sp!.remove('chatBottom');
    // global.sp!.remove('chatBottom');
    await global.sp!.setInt('chatBottom', 1);
    await global.sp!.setInt('bottomAstrologerId', astrologerId);
    await global.sp!.setString('bottomAstrologerName', astroName);
    await global.sp!.setString('bottomAstrologerProfile', astroProfile);
    await global.sp!.setString('bottomFirebaseChatId', firebaseChatId);
    await global.sp!.setInt('bottomChatId', chatId);
    await global.sp!.setString('bottomFcmToken', fcmToken);
    await global.sp!.setString('bottomduration', duration);
  }

  getAstrologerCategorys() async {
    try {
      await global.checkBody().then((result) async {
        categoryList = [];
        if (result) {
          await apiHelper.getAstrologerCategory().then((result) {
            if (result.status == "200") {
              categoryList.add(AstrologerCategoryModel(
                image: '',
                name: 'All',
                id: 1,
              ));
              categoryList.addAll(result.recordList);
              update();
            } else {
              global.showToast(
                message: 'Failed to get Category',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
            update();
          });
        }
      });
    } catch (e) {
      print('Exception in getAstrologerCategory():' + e.toString());
    }
  }

  sendChatRequest(int astrologerId, bool isFreeSession, String time) async {
    try {
      await apiHelper
          .sendAstrologerChatRequest(astrologerId, isFreeSession, time)
          .then((result) {
        if (result.status == "200") {
          global.showToast(
            message: 'Sending chat request..',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        } else {
          global.showToast(
            message: 'Failed to send chat request',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
    } catch (e) {
      print('Exception in sendCallRequest : - ${e.toString()}');
    }
  }

  bool isMe = true;
  Stream<QuerySnapshot<Map<String, dynamic>>>? getChatMessages(
      String firebaseChatId, int? currentUserId) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> data = FirebaseFirestore
          .instance
          .collection('chats/$firebaseChatId/userschat')
          .doc('$currentUserId')
          .collection('messages')
          .orderBy("createdAt", descending: true)
          .snapshots(); //orderBy("createdAt", descending: true)
      return data;
    } catch (err) {
      print("Exception - apiHelper.dart - getChatMessages()" + err.toString());
      return null;
    }
  }

  Future<void> sendMessage(
      String message, String chatId, int partnerId, bool isEndMessage) async {
    try {
      if (message.trim() != '') {
        ChatMessageModel chatMessage = ChatMessageModel(
          message: message,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDelete: false,
          isRead: true,
          userId1: '${global.currentUserId}',
          userId2: '$partnerId',
          isEndMessage: isEndMessage,
        );
        update();
        await uploadMessage(chatId, '$partnerId', chatMessage);
      } else {}
    } catch (e) {
      print('Exception in sendMessage ${e.toString()}');
    }
  }

  uploadMessage(
      String idUser, String partnerId, ChatMessageModel msgModel) async {
    try {
      final String globalId = global.currentUserId.toString();

      final refMessages = userChatCollectionRef
          .doc(idUser)
          .collection('userschat')
          .doc(globalId)
          .collection('messages');

      final refMessages1 = userChatCollectionRef
          .doc(idUser)
          .collection('userschat')
          .doc(partnerId)
          .collection('messages');

      final newMessage1 = msgModel;
      final newMessage2 = msgModel;

      newMessage2.isRead = false;

      final batch = FirebaseFirestore.instance.batch();

      final messageResult = refMessages.doc();
      batch.set(messageResult, newMessage1.toJson());

      final message1Result1 = refMessages1.doc();
      batch.set(message1Result1, newMessage2.toJson());
      isUploading = false;
      update();
      await batch.commit();
    } catch (err) {
      isUploading = false;
      update();
      log('uploadMessage err $err');
      return {};
    }
  }

  rejectedChat(String cid) async {
    try {
      await apiHelper.rejectChat(cid).then((result) {
        if (result.status == "200") {
          global.showToast(
            message: 'Chat Rejected',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        } else {
          global.showToast(
            message: 'Chat Reject fail',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
    } catch (e) {
      print("Exception rejectedChat:-" + e.toString());
    }
  }

  acceptedChat(int chatId) async {
    try {
      await apiHelper.acceptChat(chatId).then((result) {
        if (result.status == "200") {
          global.showToast(
            message: 'Chat Accepted',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        } else {
          global.showToast(
            message: 'Chat Accepet fail',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
    } catch (e) {
      print("Exception acceptedChat:-" + e.toString());
    }
  }

  addReview(int astrologerId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .addAstrologerReview(
            astrologerId,
            rating,
            reviewController.text,
            !isPublic,
          )
              .then((result) async {
            if (result.status == "200") {
              global.showToast(
                message: 'Thank you!',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
              await getuserReview(astrologerId);
              Get.back();
            } else {
              global.showToast(
                message: 'Failed to add review',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print('Exception in addReview : - ${e.toString()}');
    }
  }

  getuserReview(int astrologerId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .getuserReview(global.currentUserId!, astrologerId)
              .then((result) {
            if (result.status == "200") {
              reviewData = result.recordList;
              reviewController.text = reviewData[0].review;
              rating = reviewData[0].rating;
              isPublic = reviewData[0].isPublic == 1 ? false : false;
              update();
            } else {
              global.showToast(
                message: 'Chat Accepet fail',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception acceptedChat:-" + e.toString());
    }
  }

  deleteReview(int reviewId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.deleteReview(reviewId).then((result) async {
            if (result.status == "200") {
              global.showToast(
                message: 'Your review has been deleted',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
              reviewData.clear();
              rating = 0;
              reviewController.clear();
              update();
            } else {
              global.showToast(
                message: 'Delete review failed!',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception deleteReview:-" + e.toString());
    }
  }

  updateReview(int reviewId, int astrologerId) async {
    try {
      var basicDetails = {
        "rating": rating,
        "review": reviewController.text == "" ? "" : reviewController.text,
        "astrologerId": astrologerId,
        "isPublic": !isPublic,
      };
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .updateAstrologerReview(reviewId, basicDetails)
              .then((result) async {
            if (result.status == "200") {
              global.showToast(
                message: 'Your review has been updated',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
              await getuserReview(astrologerId);
              Get.back();
            } else {
              global.showToast(
                message: 'Failed to update review',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print('Exception in addReview : - ${e.toString()}');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getMessageRTM(String channelID) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> data =
          userChatCollectionRefRTM
              .doc(channelID)
              .collection('messages')
              .orderBy('createdAt')
              .snapshots();
      return data;
    } catch (err) {
      print("Exception - chatcontroller.dart - firebase" + err.toString());
      return null;
    }
  }

  Future uploadMessageRTM(String idUser, MessageModel anonymous) async {
    log('messga sending ${anonymous.toJson()}');
    try {
      final refMessages = userChatCollectionRefRTM //SEND BY CURRENT USER
          .doc(idUser)
          .collection('messages');
      var messageResult =
          await refMessages.add(anonymous.toJson()).catchError((e) {
        log('send mess exception' + e);
      });

      return {
        'user1': messageResult.id,
      };
    } catch (err) {
      log('uploadMessage err $err');
    }
  }
}
