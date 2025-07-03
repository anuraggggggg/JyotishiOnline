// ignore_for_file: must_be_immutable
import 'dart:developer';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class CustomDialog extends StatefulWidget {
  String? astrologerName;
  String? astrologerProfile;
  int? astrologerId;
  CustomDialog(
      {this.astrologerName, this.astrologerProfile, this.astrologerId});
  @override
  State<CustomDialog> createState() => _CustomDialogState();
}
class _CustomDialogState extends State<CustomDialog> {
  @override
  void initState() {
    log('init ${widget.astrologerName}');
    log('init 1${widget.astrologerId}');
    log('init2 ${widget.astrologerProfile}');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return contentBox(widget.astrologerName, widget.astrologerProfile,
        widget.astrologerId, context);
  }
  contentBox(astroname, astroProfile, astrologerID, context) {
    return Material(
      color: Colors.transparent,
      child: GetBuilder<ChatController>(
        builder: (chatController) => Center(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 40.h,
                width: 95.w,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 6.h),
                    Text(
                      astroname,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                        height: 0.2,
                        width: 95.w,
                        child: Container(
                          color: Colors.red.shade300,
                        )),
                    Container(
                      margin: EdgeInsets.all(2.w),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'How was Your session?',
                        style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                      ),
                    ),
                    // Summary
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Please take a moment to give us your feedback so we can ensure you get the best experience',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                      ),
                    ),
                    // Rating
                    RatingBar.builder(
                      initialRating: chatController.reviewData.isNotEmpty
                          ? chatController.reviewData[0].rating
                          : 0.0,
                      itemCount: 5,
                      itemSize: 30.sp,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) async {
                        chatController.rating = rating;
                        chatController.update();
                        print(rating);
                        print('submit');
                        if (chatController.rating == 0) {
                          global.showToast(
                            message: 'Rate Astrologer',
                            textColor: global.textColor,
                            bgColor: global.toastBackGoundColor,
                          );
                        } else {
                          if (chatController.reviewData.isNotEmpty) {
                            global.showOnlyLoaderDialog(context);
                            await chatController.updateReview(
                                chatController.reviewData[0].id!, astrologerID);
                            global.hideLoader();
                          } else {
                            global.showOnlyLoaderDialog(context);
                            await chatController.addReview(astrologerID);
                            global.hideLoader();
                          }
                        }
                      },
                    ),
                    SizedBox(height: 15.0),
                  ],
                ),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  elevation: 1.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                  ),
                  padding: EdgeInsets.zero,
                  shape: CircleBorder(side: BorderSide(color: Colors.grey)),
                ),
              ),
              Positioned(
                top: -4.h,
                left: 0.25 * 95.w,
                right: 0.25 * 95.w,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: "${global.imgBaseurl}$astroProfile",
                  imageBuilder: (context, imageProvider) {
                    return CircleAvatar(
                      radius: 4.h,
                      backgroundColor: Colors.white,
                      backgroundImage: imageProvider,
                    );
                  },
                  placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) {
                    return CircleAvatar(
                        radius: 4.h,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          fit: BoxFit.cover,
                          Images.deafultUser,
                        ));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}