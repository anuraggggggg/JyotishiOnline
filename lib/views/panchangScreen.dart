import 'dart:io';

import 'package:AstrowayCustomer/controllers/advancedPanchangController.dart';
import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/utils/AppColors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/images.dart';

// ignore: must_be_immutable
class PanchangScreen extends StatefulWidget {
  PanchangScreen({Key? key}) : super(key: key);

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen> {
  final ReviewController reviewController = Get.find<ReviewController>();

  PanchangController panchangController = Get.find<PanchangController>();

  KundliController kundliController = Get.find<KundliController>();

  SplashController splashController = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
          title: Text(
            'Panchang',
            style: Get.theme.primaryTextTheme.titleLarge!.copyWith(fontSize: 18, fontWeight: FontWeight.normal,
            color: Colors.white),
          ).tr(),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
            kIsWeb? Icons.arrow_back:    Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.white//Get.theme.iconTheme.color,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                splashController.createAstrologerShareLink();
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
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Share', style: Get.textTheme.titleMedium!.copyWith(fontSize: 12,
                        color: Colors.white)).tr(),
                      )
                    ],
                  ),
                ),
              ),
            )
          ]),
      body: GetBuilder<PanchangController>(
          builder: (panchangController) {
          return  SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    margin: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h
                    ),
                    width: 100.w,
                    padding: EdgeInsets.symmetric(
                        vertical: 1.h
                    ),
                    child: Column(
                      children: [
                        Text( "${panchangController.vedicPanchangModel!.recordList!.response!.date}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 18.sp,
                          ),
                          ),
                        SizedBox(height: 1.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: ()async{
                               await panchangController.nextDate(false);

                              },
                              child: Icon(Icons.keyboard_double_arrow_left,
                                color: Colors.white,
                                size: 24.sp,),
                            ),
                            SizedBox(width: 10.w),
                            Text( "${panchangController.vedicPanchangModel!.recordList!.response!.day!.name}",
                              style:TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 17.sp,
                              ),
                             ),
                            SizedBox(width: 4.w,),
                            InkWell(
                              onTap: ()async{
                               await panchangController.nextDate(true);

                                // panchangController.getPanchangVedic(DateTime.now().add(Duration(days: panchangController.nextDate(true))));
                              },
                              child: Icon(Icons.keyboard_double_arrow_right,
                                color: Colors.white,
                                size: 24.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                      ],
                    )
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 2.w
                  ),
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h
                          ),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3.w),
                              topRight: Radius.circular(3.w),
                            ),
                          ),
                          alignment: Alignment.center,
                          width: 100.w,
                          child: Text( "Panchang",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                              fontSize:18.sp,)
                            ).tr(),
                            ),

                      ///tithi
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Tithi",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5)
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.tithi!.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //nakshatra
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Nakshatra",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                              border: Border(
                                right:
                                BorderSide(
                                    color: Get.theme.primaryColor.withOpacity(0.5)
                                ),
                              ),
                            ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.nakshatra!.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///karana
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Karana",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5)
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.karana!.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///Yoga
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Yoga",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5)
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.yoga!.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///Rasi
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                      right: BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5)
                                      ),
                                      bottom:BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5))
                                  )
                              ),
                              child: Text("Rasi",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                               decoration: BoxDecoration(
                                 border: Border(
                                   right:
                                    BorderSide(
                                       color: Get.theme.primaryColor.withOpacity(0.5),

                                   ),
                                   bottom:BorderSide(
                                       color: Get.theme.primaryColor.withOpacity(0.5))
                                 ),
                               ),

                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.rasi!.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h,),
                //additional Information
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 2.w
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h
                        ),
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3.w),
                            topRight: Radius.circular(3.w),
                          ),
                        ),
                        alignment: Alignment.center,
                        width: 100.w,
                        child: Text( "Additional Info",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                              fontSize:18.sp,)
                        ).tr(),
                      ),

                      ///sunrise
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Sun Rise",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5)
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.sunRise}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //sunset
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Sun Set",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5)
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.sunSet}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///moonrise
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Moon Rise",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5)
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.moonRise}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///Moon set
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Moon Set",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5)
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.moonSet}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///next full moon
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5)
                                      ),
                                      right: BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5)
                                      ),
                                    )
                              ),
                              child: Text("Next Full Moon",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                    right:
                                    BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5),

                                    ),
                                ),
                              ),

                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.nextFullMoon}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///next new moon
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5)
                                      ),
                                      right: BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5)
                                      ),
                                  )
                              ),
                              child: Text("Next New Moon",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                    right:
                                    BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5),

                                    ),
                                ),
                              ),

                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.nextNewMoon}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      ///Amanta Month
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                    right: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Amanta Month",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ).tr(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                    color: Get.theme.primaryColor.withOpacity(0.5),

                                  ),
                                ),
                              ),

                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.masa!.amantaName}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      ///Paksha
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                    right: BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5)
                                    ),
                                  )
                              ),
                              child: Text("Paksha",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                  BorderSide(
                                    color: Get.theme.primaryColor.withOpacity(0.5),

                                  ),
                                ),
                              ),

                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.masa!.paksha}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///Purnimanta
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5)
                                      ),
                                      right: BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5)
                                      ),
                                      bottom:BorderSide(
                                          color: Get.theme.primaryColor.withOpacity(0.5))
                                  )
                              ),
                              child: Text("Purnimanta",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize:16.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 2.w
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                    right:
                                    BorderSide(
                                      color: Get.theme.primaryColor.withOpacity(0.5),

                                    ),
                                    bottom:BorderSide(
                                        color: Get.theme.primaryColor.withOpacity(0.5))
                                ),
                              ),

                              child: Text("${panchangController.vedicPanchangModel!.recordList!.response!.advancedDetails!.masa!.purnimantaName}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget panchangTime(String title, Color borderColors, IconData icon, String timeText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
          textAlign: TextAlign.left,
        ).tr(),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: borderColors),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: borderColors,
                size: 15,
              ),
              SizedBox(
                width: 10,
              ),
              Text(timeText).tr()
            ],
          ),
        )
      ],
    );
  }

  dialogForDate() {
    BuildContext context = Get.context!;
    showDialog(
        context: context,
        // barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            title: Column(
                children: [
              Center(
                child: Text(
                  "You're all set!",
                  style: Get.theme.textTheme.displayLarge!.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal),
                ).tr(),
              ),
              DatePickerDialog(
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                cancelText: '',
                confirmText: '',
              ),
            ]),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          );
        });
  }
}
