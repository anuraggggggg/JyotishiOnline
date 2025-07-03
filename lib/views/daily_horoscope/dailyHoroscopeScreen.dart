// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/dailyHoroscopeController.dart';
import 'package:AstrowayCustomer/controllers/liveController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/liveAstrologerList.dart';
import 'package:AstrowayCustomer/views/live_astrologer/live_astrologer_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widget/contactAstrologerBottomButton.dart';
import '../../widget/timeWiseHoroscopeWidget.dart';

class DailyHoroscopeScreen extends StatefulWidget {
  DailyHoroscopeScreen({Key? key}) : super(key: key);

  @override
  State<DailyHoroscopeScreen> createState() => _DailyHoroscopeScreenState();
}

class _DailyHoroscopeScreenState extends State<DailyHoroscopeScreen> {
  final ReviewController reviewController = Get.find<ReviewController>();

  final DailyHoroscopeController controller =
      Get.find<DailyHoroscopeController>();

  SplashController splashController = Get.find<SplashController>();

  BottomNavigationController bottomController =
      Get.find<BottomNavigationController>();

  LiveController liveController = Get.find<LiveController>();

  int selectHoroscope = 1;
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   global.warningDialog(context);
    // });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: kIsWeb?AppBar(
                leading: SizedBox(),
        ):AppBar(
            backgroundColor:
                Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
            title: Text(
              'Daily Horoscope',
              style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ).tr(),
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                kIsWeb? Icons.arrow_back :    Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                  color: Colors.black //Get.theme.iconTheme.color,
                  ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  global
                      .createAndShareLinkForDailyHorscope();
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
                          padding: const EdgeInsets.all(4.0),
                          child: Text('Share',
                                  style: Get.textTheme.titleMedium!.copyWith(
                                      fontSize: 12, color: Colors.white))
                              .tr(),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ]),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: kIsWeb?
            GetBuilder<DailyHoroscopeController>(
                builder: (dailyHoroscopeController) {
              return dailyHoroscopeController.dailyhoroscopeData == null
                  ? SizedBox()
                  : SizedBox(
                      child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///rashi listing
                                    (global.hororscopeSignList.isNotEmpty)
                                        ? Container(
                                             margin: EdgeInsets.symmetric(
                                               horizontal: MediaQuery.of(context).size.width*0.08
                                             ),
                                            height: MediaQuery.of(context).size.height*0.19,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: global
                                                    .hororscopeSignList.length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () async {
                                                            global
                                                                .showOnlyLoaderDialog(
                                                                    context);
                                                            await dailyHoroscopeController
                                                                .selectZodic(
                                                                    index);
                                                            await dailyHoroscopeController
                                                                .getHoroscopeList(
                                                                    horoscopeId:
                                                                        dailyHoroscopeController
                                                                            .signId);
                                                            global.hideLoader();
                                                          },
                                                          child: Container(
                                                            width: global
                                                                    .hororscopeSignList[
                                                                        index]
                                                                    .isSelected
                                                                ? 68.0
                                                                : 54.0,
                                                            height: global
                                                                    .hororscopeSignList[
                                                                        index]
                                                                    .isSelected
                                                                ? 68.0
                                                                : 54.0,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              7)),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .transparent,
                                                                width: 1.0,
                                                              ),
                                                            ),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  '${global.imgBaseurl}${global.hororscopeSignList[index].image}',
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                      child:
                                                                          CircularProgressIndicator()),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Icon(
                                                                      Icons
                                                                          .no_accounts,
                                                                      size: 20),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                                global
                                                                    .hororscopeSignList[
                                                                        index]
                                                                    .name,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            10))
                                                            .tr()
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          )
                                        : const SizedBox(),

                                    ///daily,yearly,monthly
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width*0.15
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectHoroscope = 0;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 8, 18, 8),
                                                decoration: BoxDecoration(
                                                  color: selectHoroscope == 0
                                                      ? Color.fromARGB(
                                                          255, 247, 243, 214)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          dailyHoroscopeController
                                                                  .isWeek
                                                              ? Get.theme
                                                                  .primaryColor
                                                              : Colors.grey),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10.0),
                                                      bottomLeft:
                                                          Radius.circular(10.0)),
                                                ),
                                                child: Text("Today \n Horoscope",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 12))
                                                    .tr(),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectHoroscope = 1;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 8, 18, 8),
                                                decoration: BoxDecoration(
                                                  color: selectHoroscope == 1
                                                      ? Color.fromARGB(
                                                          255, 247, 243, 214)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          dailyHoroscopeController
                                                                  .isMonth
                                                              ? Get.theme
                                                                  .primaryColor
                                                              : Colors.grey),
                                                ),
                                                child: Text("Weekly \n Horoscope",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 12))
                                                    .tr(),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectHoroscope = 2;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 8, 18, 8),
                                                decoration: BoxDecoration(
                                                  color: selectHoroscope == 2
                                                      ? Color.fromARGB(
                                                          255, 247, 243, 214)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          dailyHoroscopeController
                                                                  .isYear
                                                              ? Get.theme
                                                                  .primaryColor
                                                              : Colors.grey),
                                                  borderRadius: BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10.0),
                                                      bottomRight:
                                                          Radius.circular(10.0)),
                                                ),
                                                child: Text("Yearly \n Horoscope",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 12))
                                                    .tr(),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    ///lucky number and color banner

                                    selectHoroscope == 0
                                        ? dailyHoroscopeController
                                                    .dailyhoroscopeData![
                                                        'vedicList']
                                                        ['todayHoroscope']
                                                    .length ==
                                                0
                                            ? Center(
                                                child:
                                                    Text("NO HOROSCOPE").tr(),
                                              )
                                            : Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width*0.16,
                                      ),
                                      child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  MediaQuery.of(context).size.width *
                                                                      0.03,
                                                              vertical:
                                                                  MediaQuery.of(context).size.height *
                                                                      0.02),
                                                      width: MediaQuery.of(context).size.width,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade400, //Get.theme.primaryColor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.centerRight,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['date'].toString().split(" ").first}",
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .white),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ).tr(),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                "Today Horoscope",
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .white),
                                                              ).tr(),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Lucky Color",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['color_code'].toString() ==
                                                                              ""
                                                                          ? SizedBox()
                                                                          : CircleAvatar(
                                                                              backgroundColor:
                                                                                  Color(int.parse(dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['color_code'])),
                                                                              radius:
                                                                                  7,
                                                                            )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Container(
                                                                    width: 1,
                                                                    height: 20,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Lucky Number",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ).tr(),
                                                                      Text(
                                                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['lucky_number'].replaceAll("[", "").replaceAll("]", "")}",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          // CircleAvatar(
                                                          //   radius: 40,
                                                          //   backgroundColor: Colors.white,
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['bot_response']}",
                                                      style: Get
                                                          .textTheme.titleMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontSize: 12),
                                                      textAlign: TextAlign.center,
                                                    ).tr(),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      "Today Horoscrope of ${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['zodiac']}",
                                                      style: Get
                                                          .textTheme.titleMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      textAlign: TextAlign.center,
                                                    ).tr(),
                                                    SizedBox(
                                                      height: 6,
                                                    ),

                                                    ///daily horoscope list
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        ///physique
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //   width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .sports_gymnastics,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Physique",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            2.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['physique'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['physique']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),    //finances
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            // width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .monetization_on_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Finances",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            2.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['finances'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['finances']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //   width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .handshake_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Relationship",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['relationship'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['relationship']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .book_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Career",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['career'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['career']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    //Relationship &  //Career

                                                    Row(
                                                      children: [
                                                        //travel
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .travel_explore,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Travel",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            3.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['travel'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['travel']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        //family
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .people_alt_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Family",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            3.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['family'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['family']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .people_alt_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Friends",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['friends'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['friends']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        //Health
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .health_and_safety_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Health",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['health'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['health']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    //friends


                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      MediaQuery.of(context).size.height *
                                                                          0.005),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .shade200),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Colors
                                                                  .red.shade50),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      MediaQuery.of(context).size.width *
                                                                          0.02,
                                                                  vertical:
                                                                      MediaQuery.of(context).size.height *
                                                                          0.02),
                                                          width: MediaQuery.of(context).size.width / 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .photo_size_select_actual_sharp,
                                                                        color: Colors
                                                                            .red,
                                                                        size: 11.sp,
                                                                      ),
                                                                      SizedBox(
                                                                        width: Get
                                                                                .width *
                                                                            0.01,
                                                                      ),
                                                                      Text(
                                                                        "Status",
                                                                        style: Get
                                                                            .textTheme
                                                                            .titleMedium!
                                                                            .copyWith(
                                                                                fontSize: 11.sp,
                                                                                fontWeight: FontWeight.bold),
                                                                      ).tr(),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    child:
                                                                        CircularPercentIndicator(
                                                                      radius:
                                                                          11.sp,
                                                                      lineWidth:
                                                                          3.0,
                                                                      percent:
                                                                          dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['status'] /
                                                                              100,
                                                                      center:
                                                                          Text(
                                                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['status']}%",
                                                                        style: Get
                                                                            .theme
                                                                            .primaryTextTheme
                                                                            .bodySmall!
                                                                            .copyWith(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          letterSpacing:
                                                                              -0.2,
                                                                          wordSpacing:
                                                                              0,
                                                                          fontSize: 11.sp,
                                                                        ),
                                                                      ),
                                                                      progressColor:
                                                                          Colors
                                                                              .green,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 60,
                                                    ),
                                                  ],
                                                ),
                                            )
                                        : SizedBox(),

                                    selectHoroscope == 1
                                        ? dailyHoroscopeController
                                                    .dailyhoroscopeData![
                                                        'vedicList']
                                                        ['weeklyHoroScope']
                                                    .length ==
                                                0
                                            ? Center(
                                                child:
                                                    Text("NO HOROSCOPE").tr(),
                                              )
                                            : Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width*0.16,
                                      ),

                                      child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.symmetric(
                                                           vertical: MediaQuery.of(context).size.height*0.01,
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                              MediaQuery.of(context).size.width *
                                                                      0.03,
                                                              vertical:
                                                              MediaQuery.of(context).size.height *
                                                                      0.02),
                                                      width: MediaQuery.of(context).size.width,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade400, //Get.theme.primaryColor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.centerRight,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['date'].toString().split(" ").first}",
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .white),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ).tr(),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                "Weekly Horoscope",
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .white),
                                                              ).tr(),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Lucky Color",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ).tr(),
                                                                      dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['color_code'].toString() ==
                                                                              ""
                                                                          ? SizedBox()
                                                                          : CircleAvatar(
                                                                              backgroundColor:
                                                                                  Color(int.parse(dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['color_code'])),
                                                                              radius:
                                                                                  7,
                                                                            )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Container(
                                                                    width: 1,
                                                                    height: 20,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Lucky Number",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ).tr(),
                                                                      Text(
                                                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['lucky_number'].replaceAll("[", "").replaceAll("]", "")}",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            color: Colors
                                                                                .white,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          // CircleAvatar(
                                                          //   radius: 40,
                                                          //   backgroundColor: Colors.white,
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['bot_response']}",
                                                      style: Get
                                                          .textTheme.titleMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontSize: 12),
                                                      textAlign: TextAlign.center,
                                                    ).tr(),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      "Weekly Horoscope of ${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['zodiac']}",
                                                      style: Get
                                                          .textTheme.titleMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      textAlign: TextAlign.center,
                                                    ).tr(),
                                                    SizedBox(
                                                      height: 6,
                                                    ),

                                                    ///daily horoscope list
                                                    ///physique
                                                    ///daily horoscope list
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        ///physique
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.01,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.01),
                                                            //   width: MediaQuery.of(context).size.width,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .sports_gymnastics,
                                                                      color: Colors
                                                                          .red,
                                                                        
                                                                        size:11.sp
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context).size.width *
                                                                          0.01,
                                                                          
                                                                    ),
                                                                    Text(
                                                                      "Physique",
                                                                      style: Get
                                                                          .textTheme
                                                                          .titleMedium!
                                                                          .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                    ).tr(),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                   width: MediaQuery.of(context).size.width *
                                                                   0.01,
                                                            ),
                                                                Container(
                                                                  child:
                                                                      CircularPercentIndicator(
                                                                    radius:
                                                                        11.sp,
                                                                    lineWidth:
                                                                        2.0,
                                                                    percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['physique'] /
                                                                            100,
                                                                    center:
                                                                        Text(
                                                                      "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['physique']}%",
                                                                      style: Get
                                                                          .theme
                                                                          .primaryTextTheme
                                                                          .bodySmall!
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        letterSpacing:
                                                                            -0.2,
                                                                        wordSpacing:
                                                                            0,
                                                                          fontSize: 11.sp
                                                                      ),
                                                                    ),
                                                                    progressColor:
                                                                        Colors
                                                                            .green,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),

                                                        //finances
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            // width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .monetization_on_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Finances",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.01,),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            2.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['finances'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['finances']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,

                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //   width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .handshake_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Relationship",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['relationship'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['relationship']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,

                                                                          ),
                                                                        ),

                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),

                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .book_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,

                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Career",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['career'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['career']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        //travel
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .travel_explore,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Travel",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            3.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['travel'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['travel']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        //family
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .people_alt_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Family",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            3.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['family'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['family']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .people_alt_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Friends",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['friends'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['friends']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,

                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        //Health
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .health_and_safety_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Health",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['health'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['health']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      MediaQuery.of(context).size.height *
                                                                          0.005),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .shade200),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Colors
                                                                  .red.shade50),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      MediaQuery.of(context).size.width *
                                                                          0.02,
                                                                  vertical:
                                                                      MediaQuery.of(context).size.height *
                                                                          0.02),
                                                          width: MediaQuery.of(context).size.width / 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .photo_size_select_actual_sharp,
                                                                        color: Colors
                                                                            .red,
                                                                        size: 11.sp,
                                                                      ),
                                                                      SizedBox(
                                                                        width: Get
                                                                                .width *
                                                                            0.01,
                                                                      ),
                                                                      Text(
                                                                        "Status",
                                                                        style: Get
                                                                            .textTheme
                                                                            .titleMedium!
                                                                            .copyWith(
                                                                                fontSize: 11.sp,
                                                                                fontWeight: FontWeight.bold),
                                                                      ).tr(),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    child:
                                                                        CircularPercentIndicator(
                                                                      radius:
                                                                          11.sp,
                                                                      lineWidth:
                                                                          3.0,
                                                                      percent:
                                                                          dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['status'] /
                                                                              100,
                                                                      center:
                                                                          Text(
                                                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['status']}%",
                                                                        style: Get
                                                                            .theme
                                                                            .primaryTextTheme
                                                                            .bodySmall!
                                                                            .copyWith(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          letterSpacing:
                                                                              -0.2,
                                                                          wordSpacing:
                                                                              0,
                                                                          fontSize: 11.sp,
                                                                        ),
                                                                      ),
                                                                      progressColor:
                                                                          Colors
                                                                              .green,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 60,
                                                    ),
                                                  ],
                                                ),
                                            )
                                        : SizedBox(),

                                    selectHoroscope == 2
                                        ? dailyHoroscopeController
                                                    .dailyhoroscopeData![
                                                        'vedicList']
                                                        ['yearlyHoroScope']
                                                    .length ==
                                                0
                                            ? Center(
                                                child:
                                                    Text("NO HOROSCOPE").tr(),
                                              )
                                            : Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width*0.16,
                                      ),
                                      child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  MediaQuery.of(context).size.width *
                                                                      0.03,
                                                              vertical:
                                                                  MediaQuery.of(context).size.height *
                                                                      0.02),
                                                      width: MediaQuery.of(context).size.width,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade400, //Get.theme.primaryColor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.centerRight,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['date'].toString().split(" ").first}",
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .white),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ).tr(),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                "Yearly Horoscope",
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .white),
                                                              ).tr(),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Lucky Color",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ).tr(),
                                                                      dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['color_code'].toString() ==
                                                                              ""
                                                                          ? SizedBox(
                                                                              height:
                                                                                  8,
                                                                            )
                                                                          : CircleAvatar(
                                                                              backgroundColor:
                                                                                  Color(int.parse(dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['color_code'])),
                                                                              radius:
                                                                                  7,
                                                                            )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Container(
                                                                    width: 1,
                                                                    height: 20,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Lucky Number",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ).tr(),
                                                                      Text(
                                                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['lucky_number'].replaceAll("[", "").replaceAll("]", "")}",
                                                                        style: Get.textTheme.titleMedium!.copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          // CircleAvatar(
                                                          //   radius: 40,
                                                          //   backgroundColor: Colors.white,
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['bot_response']}",
                                                      style: Get
                                                          .textTheme.titleMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontSize: 12),
                                                      textAlign: TextAlign.center,
                                                    ).tr(),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      "Yearly Horoscope of ${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['zodiac']}",
                                                      style: Get
                                                          .textTheme.titleMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      textAlign: TextAlign.center,
                                                    ).tr(),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                              
                                                    ///daily horoscope list
                                                    ///physique
                                                    ///daily horoscope list
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        ///physique
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //   width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .sports_gymnastics,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Physique",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            2.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['physique'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['physique']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        //finances
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            // width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .monetization_on_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,

                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Finances",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            2.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['finances'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['finances']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,

                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //   width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .handshake_outlined,
                                                                          color: Colors
                                                                              .red, size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Relationship",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['relationship'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['relationship']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .book_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,

                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Career",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['career'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['career']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),

                                                    Row(
                                                      children: [
                                                        //travel
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .travel_explore,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Travel",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            3.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['travel'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['travel']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),
                                                        //family
                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.02,
                                                                    vertical:
                                                                        MediaQuery.of(context).size.height *
                                                                            0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .people_alt_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Family",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                                  fontSize: 11.sp,
                                                                                  fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          CircularPercentIndicator(
                                                                        radius:
                                                                            11.sp,
                                                                        lineWidth:
                                                                            3.0,
                                                                        percent:
                                                                            dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['family'] /
                                                                                100,
                                                                        center:
                                                                            Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['family']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            letterSpacing:
                                                                                -0.2,
                                                                            wordSpacing:
                                                                                0,
                                                                            fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                            Colors
                                                                                .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),

                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .people_alt_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Friends",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['friends'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['friends']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                             fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        //Health
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *
                                                              0.01,
                                                        ),

                                                        Expanded(
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.005),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red
                                                                        .shade200),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                color: Colors
                                                                    .red.shade50),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                MediaQuery.of(context).size.width *
                                                                    0.02,
                                                                vertical:
                                                                MediaQuery.of(context).size.height *
                                                                    0.02),
                                                            //  width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .health_and_safety_outlined,
                                                                          color: Colors
                                                                              .red,
                                                                          size: 11.sp,
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.01,
                                                                        ),
                                                                        Text(
                                                                          "Health",
                                                                          style: Get
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.bold),
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                      CircularPercentIndicator(
                                                                        radius:
                                                                        11.sp,
                                                                        lineWidth:
                                                                        3.0,
                                                                        percent:
                                                                        dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['health'] /
                                                                            100,
                                                                        center:
                                                                        Text(
                                                                          "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['health']}%",
                                                                          style: Get
                                                                              .theme
                                                                              .primaryTextTheme
                                                                              .bodySmall!
                                                                              .copyWith(
                                                                            fontWeight:
                                                                            FontWeight.w500,
                                                                            letterSpacing:
                                                                            -0.2,
                                                                            wordSpacing:
                                                                            0,
                                                                             fontSize: 11.sp,
                                                                          ),
                                                                        ),
                                                                        progressColor:
                                                                        Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),

                                              
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      MediaQuery.of(context).size.height *
                                                                          0.005),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .shade200),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Colors
                                                                  .red.shade50),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      MediaQuery.of(context).size.width *
                                                                          0.02,
                                                                  vertical:
                                                                      MediaQuery.of(context).size.height *
                                                                          0.02),
                                                          width: MediaQuery.of(context).size.width / 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .photo_size_select_actual_sharp,
                                                                        color: Colors
                                                                            .red,
                                                                          size: 11.sp
                                                                      ),
                                                                      SizedBox(
                                                                        width: Get
                                                                                .width *
                                                                            0.01,
                                                                      ),
                                                                      Text(
                                                                        "Status",
                                                                        style: Get
                                                                            .textTheme
                                                                            .titleMedium!
                                                                            .copyWith(
                                                                                fontSize: 11.sp,
                                                                                fontWeight: FontWeight.bold),
                                                                      ).tr(),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    child:
                                                                        CircularPercentIndicator(
                                                                      radius:
                                                                          11.sp,
                                                                      lineWidth:
                                                                          3.0,
                                                                      percent:
                                                                          dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['status'] /
                                                                              100,
                                                                      center:
                                                                          Text(
                                                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['status']}%",
                                                                        style: Get
                                                                            .theme
                                                                            .primaryTextTheme
                                                                            .bodySmall!
                                                                            .copyWith(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          letterSpacing:
                                                                              -0.2,
                                                                          wordSpacing:
                                                                              0,
                                                                          fontSize: 11.sp,

                                                                        ),
                                                                      ),
                                                                      progressColor:
                                                                          Colors
                                                                              .green,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 60,
                                                    ),
                                                  ],
                                                ),
                                            )
                                        : SizedBox(),
                                  ],
                                )
                    );
            }):
            GetBuilder<DailyHoroscopeController>(
                builder: (dailyHoroscopeController) {
                  return dailyHoroscopeController.dailyhoroscopeData == null
                      ? SizedBox()
                      : SizedBox(
                    child:
                    dailyHoroscopeController
                        .dailyhoroscopeData!['astroApiCallType']
                        .toString() ==
                        "3"
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///rashi listing
                        (global.hororscopeSignList.isNotEmpty)
                            ? SizedBox(
                          height: 100,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection:
                              Axis.horizontal,
                              itemCount: global
                                  .hororscopeSignList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                  const EdgeInsets.all(
                                      8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          global
                                              .showOnlyLoaderDialog(
                                              context);
                                          await dailyHoroscopeController
                                              .selectZodic(
                                              index);
                                          await dailyHoroscopeController
                                              .getHoroscopeList(
                                              horoscopeId:
                                              dailyHoroscopeController
                                                  .signId);
                                          global.hideLoader();
                                        },
                                        child: Container(
                                          width: global
                                              .hororscopeSignList[
                                          index]
                                              .isSelected
                                              ? 68.0
                                              : 54.0,
                                          height: global
                                              .hororscopeSignList[
                                          index]
                                              .isSelected
                                              ? 68.0
                                              : 54.0,
                                          padding:
                                          EdgeInsets.all(
                                              0),
                                          decoration:
                                          BoxDecoration(
                                            color: Colors
                                                .transparent,
                                            borderRadius:
                                            BorderRadius
                                                .all(Radius
                                                .circular(
                                                7)),
                                            border:
                                            Border.all(
                                              color: Colors
                                                  .transparent,
                                              width: 1.0,
                                            ),
                                          ),
                                          child:
                                          CachedNetworkImage(
                                            imageUrl:
                                            '${global.imgBaseurl}${global.hororscopeSignList[index].image}',
                                            placeholder: (context,
                                                url) =>
                                            const Center(
                                                child:
                                                CircularProgressIndicator()),
                                            errorWidget: (context,
                                                url,
                                                error) =>
                                                Icon(
                                                    Icons
                                                        .no_accounts,
                                                    size: 20),
                                          ),
                                        ),
                                      ),
                                      Text(
                                          global
                                              .hororscopeSignList[
                                          index]
                                              .name,
                                          textAlign:
                                          TextAlign
                                              .center,
                                          style: Get
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                              fontSize:
                                              10))
                                          .tr()
                                    ],
                                  ),
                                );
                              }),
                        )
                            : const SizedBox(),

                        ///daily,yearly,monthly
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectHoroscope = 0;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      18, 8, 18, 8),
                                  decoration: BoxDecoration(
                                    color: selectHoroscope == 0
                                        ? Color.fromARGB(
                                        255, 247, 243, 214)
                                        : Colors.transparent,
                                    border: Border.all(
                                        color:
                                        dailyHoroscopeController
                                            .isWeek
                                            ? Get.theme
                                            .primaryColor
                                            : Colors.grey),
                                    borderRadius: BorderRadius.only(
                                        topLeft:
                                        Radius.circular(10.0),
                                        bottomLeft:
                                        Radius.circular(10.0)),
                                  ),
                                  child: Text("Today \n Horoscope",
                                      textAlign:
                                      TextAlign.center,
                                      style: Get.textTheme
                                          .titleMedium!
                                          .copyWith(
                                          fontSize: 12))
                                      .tr(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectHoroscope = 1;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      18, 8, 18, 8),
                                  decoration: BoxDecoration(
                                    color: selectHoroscope == 1
                                        ? Color.fromARGB(
                                        255, 247, 243, 214)
                                        : Colors.transparent,
                                    border: Border.all(
                                        color:
                                        dailyHoroscopeController
                                            .isMonth
                                            ? Get.theme
                                            .primaryColor
                                            : Colors.grey),
                                  ),
                                  child: Text("Weekly \n Horoscope",
                                      textAlign:
                                      TextAlign.center,
                                      style: Get.textTheme
                                          .titleMedium!
                                          .copyWith(
                                          fontSize: 12))
                                      .tr(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectHoroscope = 2;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      18, 8, 18, 8),
                                  decoration: BoxDecoration(
                                    color: selectHoroscope == 2
                                        ? Color.fromARGB(
                                        255, 247, 243, 214)
                                        : Colors.transparent,
                                    border: Border.all(
                                        color:
                                        dailyHoroscopeController
                                            .isYear
                                            ? Get.theme
                                            .primaryColor
                                            : Colors.grey),
                                    borderRadius: BorderRadius.only(
                                        topRight:
                                        Radius.circular(10.0),
                                        bottomRight:
                                        Radius.circular(10.0)),
                                  ),
                                  child: Text("Yearly \n Horoscope",
                                      textAlign:
                                      TextAlign.center,
                                      style: Get.textTheme
                                          .titleMedium!
                                          .copyWith(
                                          fontSize: 12))
                                      .tr(),
                                ),
                              ),
                            )
                          ],
                        ),

                        ///lucky number and color banner

                        selectHoroscope == 0
                            ? dailyHoroscopeController
                            .dailyhoroscopeData![
                        'vedicList']
                        ['todayHoroscope']
                            .length ==
                            0
                            ? Center(
                          child:
                          Text("NO HOROSCOPE").tr(),
                        )
                            : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: 10),
                              padding:
                              EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width *
                                      0.03,
                                  vertical:
                                  MediaQuery.of(context).size.height *
                                      0.02),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey
                                    .shade400, //Get.theme.primaryColor,
                                borderRadius:
                                BorderRadius.circular(
                                    10),
                              ),
                              child: Stack(
                                alignment:
                                Alignment.centerRight,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['date'].toString().split(" ").first}",
                                        style: Get
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontWeight:
                                            FontWeight
                                                .w700,
                                            color: Colors
                                                .white),
                                        textAlign:
                                        TextAlign
                                            .center,
                                      ).tr(),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "Today Horoscope",
                                        style: Get
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontSize:
                                            13,
                                            color: Colors
                                                .white),
                                      ).tr(),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                "Lucky Color",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ),
                                              dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['color_code'].toString() ==
                                                  ""
                                                  ? SizedBox()
                                                  : CircleAvatar(
                                                backgroundColor:
                                                Color(int.parse(dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['color_code'])),
                                                radius:
                                                7,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors
                                                .white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                "Lucky Number",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ).tr(),
                                              Text(
                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['lucky_number'].replaceAll("[", "").replaceAll("]", "")}",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  // CircleAvatar(
                                  //   radius: 40,
                                  //   backgroundColor: Colors.white,
                                  // )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['bot_response']}",
                              style: Get
                                  .textTheme.titleMedium!
                                  .copyWith(
                                  fontWeight:
                                  FontWeight.w500,
                                  fontSize: 12),
                              textAlign: TextAlign.center,
                            ).tr(),
                            SizedBox(
                              height: 6,
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Today Horoscrope of ${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['zodiac']}",
                              style: Get
                                  .textTheme.titleMedium!
                                  .copyWith(
                                  fontWeight:
                                  FontWeight
                                      .bold),
                              textAlign: TextAlign.center,
                            ).tr(),
                            SizedBox(
                              height: 6,
                            ),

                            ///daily horoscope list
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                              children: [
                                ///physique
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //   width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .sports_gymnastics,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Physique",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            SizedBox(
                                                width: 1),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                16.0,
                                                lineWidth:
                                                2.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['physique'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['physique']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                //finances
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    // width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .monetization_on_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Finances",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            SizedBox(
                                                width: 1),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                14.0,
                                                lineWidth:
                                                2.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['finances'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['finances']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Text("JASJKDNAKJ AJS DJ ASJD  AS DAS",
                                        //   style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                        //     fontWeight: FontWeight.w500,
                                        //     letterSpacing: -0.2,
                                        //     wordSpacing: 0,
                                        //   ),)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Relationship &  //Career

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //   width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .handshake_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Relationship",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['relationship'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['relationship']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Text("JASJKDNAKJ AJS DJ ASJD  AS DAS",
                                        //   style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                        //     fontWeight: FontWeight.w500,
                                        //     letterSpacing: -0.2,
                                        //     wordSpacing: 0,
                                        //   ),)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .book_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Career",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['career'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['career']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                //travel
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .travel_explore,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Travel",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['travel'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['travel']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),

                                //family
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .people_alt_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Family",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['family'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['family']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Text("JASJKDNAKJ AJS DJ ASJD  AS DAS",
                                        //   style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                        //     fontWeight: FontWeight.w500,
                                        //     letterSpacing: -0.2,
                                        //     wordSpacing: 0,
                                        //   ),)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //friends
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .people_alt_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Friends",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['friends'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['friends']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //Health
                                SizedBox(
                                  width: 4,
                                ),

                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .health_and_safety_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Health",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['health'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['health']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets
                                      .symmetric(
                                      vertical:
                                      MediaQuery.of(context).size.height *
                                          0.005),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors
                                              .red
                                              .shade200),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          10),
                                      color: Colors
                                          .red.shade50),
                                  padding: EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.02,
                                      vertical:
                                      MediaQuery.of(context).size.height *
                                          0.02),
                                  width: MediaQuery.of(context).size.width / 2.1,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .photo_size_select_actual_sharp,
                                                color: Colors
                                                    .red,
                                              ),
                                              SizedBox(
                                                width: Get
                                                    .width *
                                                    0.02,
                                              ),
                                              Text(
                                                "Status",
                                                style: Get
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold),
                                              ).tr(),
                                            ],
                                          ),
                                          Container(
                                            child:
                                            CircularPercentIndicator(
                                              radius:
                                              17.0,
                                              lineWidth:
                                              3.0,
                                              percent:
                                              dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['status'] /
                                                  100,
                                              center:
                                              Text(
                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['todayHoroscope'][0]['status']}%",
                                                style: Get
                                                    .theme
                                                    .primaryTextTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  letterSpacing:
                                                  -0.2,
                                                  wordSpacing:
                                                  0,
                                                ),
                                              ),
                                              progressColor:
                                              Colors
                                                  .green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 60,
                            ),
                          ],
                        )
                            : SizedBox(),

                        selectHoroscope == 1
                            ? dailyHoroscopeController
                            .dailyhoroscopeData![
                        'vedicList']
                        ['weeklyHoroScope']
                            .length ==
                            0
                            ? Center(
                          child:
                          Text("NO HOROSCOPE").tr(),
                        )
                            : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: 10),
                              padding:
                              EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width *
                                      0.03,
                                  vertical:
                                  MediaQuery.of(context).size.height *
                                      0.02),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey
                                    .shade400, //Get.theme.primaryColor,
                                borderRadius:
                                BorderRadius.circular(
                                    10),
                              ),
                              child: Stack(
                                alignment:
                                Alignment.centerRight,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['date'].toString().split(" ").first}",
                                        style: Get
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontWeight:
                                            FontWeight
                                                .w700,
                                            color: Colors
                                                .white),
                                        textAlign:
                                        TextAlign
                                            .center,
                                      ).tr(),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "Weekly Horoscope",
                                        style: Get
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontSize:
                                            13,
                                            color: Colors
                                                .white),
                                      ).tr(),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                "Lucky Color",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ).tr(),
                                              dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['color_code'].toString() ==
                                                  ""
                                                  ? SizedBox()
                                                  : CircleAvatar(
                                                backgroundColor:
                                                Color(int.parse(dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['color_code'])),
                                                radius:
                                                7,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors
                                                .white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                "Lucky Number",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ).tr(),
                                              Text(
                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['lucky_number'].replaceAll("[", "").replaceAll("]", "")}",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  // CircleAvatar(
                                  //   radius: 40,
                                  //   backgroundColor: Colors.white,
                                  // )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['bot_response']}",
                              style: Get
                                  .textTheme.titleMedium!
                                  .copyWith(
                                  fontWeight:
                                  FontWeight.w500,
                                  fontSize: 12),
                              textAlign: TextAlign.center,
                            ).tr(),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Weekly Horoscope of ${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['zodiac']}",
                              style: Get
                                  .textTheme.titleMedium!
                                  .copyWith(
                                  fontWeight:
                                  FontWeight
                                      .bold),
                              textAlign: TextAlign.center,
                            ).tr(),
                            SizedBox(
                              height: 6,
                            ),

                            ///daily horoscope list
                            ///physique
                            ///daily horoscope list
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                              children: [
                                ///physique
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //   width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .sports_gymnastics,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Physique",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            SizedBox(
                                                width: 1),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                16.0,
                                                lineWidth:
                                                2.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['physique'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['physique']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Text("JASJKDNAKJ AJS DJ ASJD  AS DAS",
                                        //   style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                        //     fontWeight: FontWeight.w500,
                                        //     letterSpacing: -0.2,
                                        //     wordSpacing: 0,
                                        //   ),)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                //finances
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    // width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .monetization_on_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Finances",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            SizedBox(
                                                width: 1),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                14.0,
                                                lineWidth:
                                                2.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['finances'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['finances']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Relationship &  //Career

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //   width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .handshake_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Relationship",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['relationship'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['relationship']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .book_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Career",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['career'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['career']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                //travel
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .travel_explore,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Travel",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['travel'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['travel']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),

                                //family
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .people_alt_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Family",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['family'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['family']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //friends
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .people_alt_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Friends",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['friends'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['friends']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //Health
                                SizedBox(
                                  width: 4,
                                ),

                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .health_and_safety_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Health",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['health'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['health']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets
                                      .symmetric(
                                      vertical:
                                      MediaQuery.of(context).size.height *
                                          0.005),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors
                                              .red
                                              .shade200),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          10),
                                      color: Colors
                                          .red.shade50),
                                  padding: EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.02,
                                      vertical:
                                      MediaQuery.of(context).size.height *
                                          0.02),
                                  width: MediaQuery.of(context).size.width / 2.1,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .photo_size_select_actual_sharp,
                                                color: Colors
                                                    .red,
                                              ),
                                              SizedBox(
                                                width: Get
                                                    .width *
                                                    0.02,
                                              ),
                                              Text(
                                                "Status",
                                                style: Get
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold),
                                              ).tr(),
                                            ],
                                          ),
                                          Container(
                                            child:
                                            CircularPercentIndicator(
                                              radius:
                                              17.0,
                                              lineWidth:
                                              3.0,
                                              percent:
                                              dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['status'] /
                                                  100,
                                              center:
                                              Text(
                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['weeklyHoroScope'][0]['status']}%",
                                                style: Get
                                                    .theme
                                                    .primaryTextTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  letterSpacing:
                                                  -0.2,
                                                  wordSpacing:
                                                  0,
                                                ),
                                              ),
                                              progressColor:
                                              Colors
                                                  .green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 60,
                            ),
                          ],
                        )
                            : SizedBox(),

                        selectHoroscope == 2
                            ? dailyHoroscopeController
                            .dailyhoroscopeData![
                        'vedicList']
                        ['yearlyHoroScope']
                            .length ==
                            0
                            ? Center(
                          child:
                          Text("NO HOROSCOPE").tr(),
                        )
                            : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: 10),
                              padding:
                              EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width *
                                      0.03,
                                  vertical:
                                  MediaQuery.of(context).size.height *
                                      0.02),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey
                                    .shade400, //Get.theme.primaryColor,
                                borderRadius:
                                BorderRadius.circular(
                                    10),
                              ),
                              child: Stack(
                                alignment:
                                Alignment.centerRight,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['date'].toString().split(" ").first}",
                                        style: Get
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontWeight:
                                            FontWeight
                                                .w700,
                                            color: Colors
                                                .white),
                                        textAlign:
                                        TextAlign
                                            .center,
                                      ).tr(),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "Yearly Horoscope",
                                        style: Get
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontSize:
                                            13,
                                            color: Colors
                                                .white),
                                      ).tr(),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                "Lucky Color",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ).tr(),
                                              dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['color_code'].toString() ==
                                                  ""
                                                  ? SizedBox(
                                                height:
                                                8,
                                              )
                                                  : CircleAvatar(
                                                backgroundColor:
                                                Color(int.parse(dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['color_code'])),
                                                radius:
                                                7,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors
                                                .white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                "Lucky Number",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ).tr(),
                                              Text(
                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['lucky_number'].replaceAll("[", "").replaceAll("]", "")}",
                                                style: Get.textTheme.titleMedium!.copyWith(
                                                    fontSize:
                                                    11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  // CircleAvatar(
                                  //   radius: 40,
                                  //   backgroundColor: Colors.white,
                                  // )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['bot_response']}",
                              style: Get
                                  .textTheme.titleMedium!
                                  .copyWith(
                                  fontWeight:
                                  FontWeight.w500,
                                  fontSize: 12),
                              textAlign: TextAlign.center,
                            ).tr(),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Yearly Horoscope of ${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['zodiac']}",
                              style: Get
                                  .textTheme.titleMedium!
                                  .copyWith(
                                  fontWeight:
                                  FontWeight
                                      .bold),
                              textAlign: TextAlign.center,
                            ).tr(),
                            SizedBox(
                              height: 6,
                            ),

                            ///daily horoscope list
                            ///physique
                            ///daily horoscope list
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                              children: [
                                ///physique
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //   width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .sports_gymnastics,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Physique",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            SizedBox(
                                                width: 1),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                16.0,
                                                lineWidth:
                                                2.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['physique'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['physique']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                //finances
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    // width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .monetization_on_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Finances",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            SizedBox(
                                                width: 1),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                14.0,
                                                lineWidth:
                                                2.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['finances'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['finances']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Relationship &  //Career

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //   width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .handshake_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Relationship",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['relationship'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['relationship']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .book_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Career",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['career'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['career']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                //travel
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .travel_explore,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Travel",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['travel'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['travel']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),

                                //family
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .people_alt_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Family",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['family'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['family']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //friends
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .people_alt_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Friends",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['friends'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['friends']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //Health
                                SizedBox(
                                  width: 4,
                                ),

                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets
                                        .symmetric(
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .red
                                                .shade200),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10),
                                        color: Colors
                                            .red.shade50),
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                        vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                    //  width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .health_and_safety_outlined,
                                                  color: Colors
                                                      .red,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width *
                                                      0.02,
                                                ),
                                                Text(
                                                  "Health",
                                                  style: Get
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ).tr(),
                                              ],
                                            ),
                                            Container(
                                              child:
                                              CircularPercentIndicator(
                                                radius:
                                                17.0,
                                                lineWidth:
                                                3.0,
                                                percent:
                                                dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['health'] /
                                                    100,
                                                center:
                                                Text(
                                                  "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['health']}%",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    letterSpacing:
                                                    -0.2,
                                                    wordSpacing:
                                                    0,
                                                  ),
                                                ),
                                                progressColor:
                                                Colors
                                                    .green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets
                                      .symmetric(
                                      vertical:
                                      MediaQuery.of(context).size.height *
                                          0.005),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors
                                              .red
                                              .shade200),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          10),
                                      color: Colors
                                          .red.shade50),
                                  padding: EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.02,
                                      vertical:
                                      MediaQuery.of(context).size.height *
                                          0.02),
                                  width: MediaQuery.of(context).size.width / 2.1,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .photo_size_select_actual_sharp,
                                                color: Colors
                                                    .red,
                                              ),
                                              SizedBox(
                                                width: Get
                                                    .width *
                                                    0.02,
                                              ),
                                              Text(
                                                "Status",
                                                style: Get
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold),
                                              ).tr(),
                                            ],
                                          ),
                                          Container(
                                            child:
                                            CircularPercentIndicator(
                                              radius:
                                              17.0,
                                              lineWidth:
                                              3.0,
                                              percent:
                                              dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['status'] /
                                                  100,
                                              center:
                                              Text(
                                                "${dailyHoroscopeController.dailyhoroscopeData!['vedicList']['yearlyHoroScope'][0]['status']}%",
                                                style: Get
                                                    .theme
                                                    .primaryTextTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  letterSpacing:
                                                  -0.2,
                                                  wordSpacing:
                                                  0,
                                                ),
                                              ),
                                              progressColor:
                                              Colors
                                                  .green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 60,
                            ),
                          ],
                        )
                            : SizedBox(),
                      ],
                    )
                        : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          (global.hororscopeSignList.isNotEmpty)
                              ? SizedBox(
                            height: 100,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection:
                                Axis.horizontal,
                                itemCount: global
                                    .hororscopeSignList
                                    .length,
                                itemBuilder:
                                    (context, index) {
                                  return Padding(
                                    padding:
                                    const EdgeInsets.all(
                                        8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center,
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            global
                                                .showOnlyLoaderDialog(
                                                context);
                                            await dailyHoroscopeController
                                                .selectZodic(
                                                index);
                                            await dailyHoroscopeController
                                                .getHoroscopeList(
                                                horoscopeId:
                                                dailyHoroscopeController
                                                    .signId);
                                            global
                                                .hideLoader();
                                          },
                                          child: Container(
                                            width: global
                                                .hororscopeSignList[
                                            index]
                                                .isSelected
                                                ? 68.0
                                                : 54.0,
                                            height: global
                                                .hororscopeSignList[
                                            index]
                                                .isSelected
                                                ? 68.0
                                                : 54.0,
                                            padding:
                                            EdgeInsets
                                                .all(0),
                                            decoration:
                                            BoxDecoration(
                                              color: Colors
                                                  .transparent,
                                              borderRadius: BorderRadius
                                                  .all(Radius
                                                  .circular(
                                                  7)),
                                              border:
                                              Border.all(
                                                color: Colors
                                                    .transparent,
                                                width: 1.0,
                                              ),
                                            ),
                                            child:
                                            CachedNetworkImage(
                                              imageUrl:
                                              '${global.imgBaseurl}${global.hororscopeSignList[index].image}',
                                              placeholder: (context,
                                                  url) =>
                                              const Center(
                                                  child:
                                                  CircularProgressIndicator()),
                                              errorWidget: (context,
                                                  url,
                                                  error) =>
                                                  Icon(
                                                      Icons
                                                          .no_accounts,
                                                      size:
                                                      20),
                                            ),
                                          ),
                                        ),
                                        Text(
                                            global
                                                .hororscopeSignList[
                                            index]
                                                .name,
                                            textAlign:
                                            TextAlign
                                                .center,
                                            style: Get
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                fontSize:
                                                10))
                                            .tr()
                                      ],
                                    ),
                                  );
                                }),
                          )
                              : const SizedBox(),

                          ///live astro
                          GetBuilder<BottomNavigationController>(
                              builder:
                                  (bottomNavigationController) {
                                return bottomNavigationController
                                    .liveAstrologer.length ==
                                    0
                                    ? const SizedBox()
                                    : SizedBox(
                                  height: 200,
                                  child: Card(
                                    elevation: 0,
                                    margin:
                                    EdgeInsets.only(top: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.zero),
                                    child: Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                10),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Live Astrologers',
                                                      style: Get
                                                          .theme
                                                          .primaryTextTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight.w500),
                                                    ).tr(),
                                                    Padding(
                                                      padding: EdgeInsets
                                                          .only(
                                                          left:
                                                          5),
                                                      child:
                                                      GestureDetector(
                                                        onTap:
                                                            () async {
                                                          global.showOnlyLoaderDialog(
                                                              context);
                                                          await bottomNavigationController
                                                              .getLiveAstrologerList();
                                                          global
                                                              .hideLoader();
                                                        },
                                                        child:
                                                        Icon(
                                                          Icons
                                                              .refresh,
                                                          size:
                                                          20,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                GestureDetector(
                                                  onTap:
                                                      () async {
                                                    bool isLogin =
                                                    await global
                                                        .isLogin();
                                                    if (isLogin) {
                                                      Get.to(() =>
                                                          LiveAstrologerListScreen());
                                                    }
                                                  },
                                                  child: Text(
                                                    'View All',
                                                    style: Get
                                                        .theme
                                                        .primaryTextTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                      fontWeight:
                                                      FontWeight
                                                          .w400,
                                                      color: Colors
                                                          .grey[
                                                      500],
                                                    ),
                                                  ).tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GetBuilder<
                                              BottomNavigationController>(
                                            builder: (c) {
                                              return Expanded(
                                                child: ListView
                                                    .builder(
                                                  itemCount:
                                                  bottomNavigationController
                                                      .liveAstrologer
                                                      .length,
                                                  shrinkWrap:
                                                  true,
                                                  scrollDirection:
                                                  Axis.horizontal,
                                                  padding: EdgeInsets
                                                      .only(
                                                      top: 10,
                                                      left:
                                                      10),
                                                  itemBuilder:
                                                      (context,
                                                      index) {
                                                    return GestureDetector(
                                                        onTap:
                                                            () async {
                                                          bottomController.anotherLiveAstrologers = bottomNavigationController
                                                              .liveAstrologer
                                                              .where((element) =>
                                                          element.astrologerId !=
                                                              bottomNavigationController.liveAstrologer[index].astrologerId)
                                                              .toList();
                                                          bottomController
                                                              .update();
                                                          await liveController.getWaitList(bottomNavigationController
                                                              .liveAstrologer[index]
                                                              .channelName);
                                                          int index2 = liveController.waitList.indexWhere((element) =>
                                                          element.userId ==
                                                              global.currentUserId);
                                                          if (index2 !=
                                                              -1) {
                                                            liveController.isImInWaitList =
                                                            true;
                                                            liveController
                                                                .update();
                                                          } else {
                                                            liveController.isImInWaitList =
                                                            false;
                                                            liveController
                                                                .update();
                                                          }
                                                          liveController.isImInLive =
                                                          true;
                                                          liveController.isJoinAsChat =
                                                          false;
                                                          liveController.isLeaveCalled =
                                                          false;
                                                          liveController
                                                              .update();
                                                          Get.to(
                                                                () =>
                                                                LiveAstrologerScreen(
                                                                  token:
                                                                  bottomNavigationController.liveAstrologer[index].token,
                                                                  channel:
                                                                  bottomNavigationController.liveAstrologer[index].channelName,
                                                                  astrologerName:
                                                                  bottomNavigationController.liveAstrologer[index].name,
                                                                  astrologerProfile:
                                                                  bottomNavigationController.liveAstrologer[index].profileImage,
                                                                  astrologerId:
                                                                  bottomNavigationController.liveAstrologer[index].astrologerId,
                                                                  isFromHome:
                                                                  true,
                                                                  charge:
                                                                  bottomNavigationController.liveAstrologer[index].charge,
                                                                  isForLiveCallAcceptDecline:
                                                                  false,
                                                                  isFromNotJoined:
                                                                  false,
                                                                  isFollow:
                                                                  bottomNavigationController.liveAstrologer[index].isFollow!,
                                                                  videoCallCharge:
                                                                  bottomNavigationController.liveAstrologer[index].videoCallRate,
                                                                ),
                                                          );
                                                        },
                                                        child: SizedBox(
                                                            child: Stack(alignment: Alignment.bottomCenter, children: [
                                                              bottomNavigationController.liveAstrologer[index].profileImage !=
                                                                  ""
                                                                  ? Container(
                                                                width: 95,
                                                                height: 200,
                                                                margin: EdgeInsets.only(right: 4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.black.withOpacity(0.3),
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    border: Border.all(
                                                                      color: Color.fromARGB(255, 214, 214, 214),
                                                                    ),
                                                                    image: DecorationImage(
                                                                        fit: BoxFit.cover,
                                                                        image: NetworkImage(
                                                                          '${global.imgBaseurl}${bottomNavigationController.liveAstrologer[index].profileImage}',
                                                                        ),
                                                                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken))),
                                                              )
                                                                  : Container(
                                                                width: 95,
                                                                height: 200,
                                                                margin: EdgeInsets.only(right: 4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.black.withOpacity(0.3),
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    border: Border.all(
                                                                      color: Color.fromARGB(255, 214, 214, 214),
                                                                    ),
                                                                    image: DecorationImage(
                                                                        fit: BoxFit.cover,
                                                                        image: AssetImage(
                                                                          Images.deafultUser,
                                                                        ),
                                                                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken))),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    bottom: 20),
                                                                child:
                                                                Column(
                                                                  mainAxisSize:
                                                                  MainAxisSize.min,
                                                                  children: [
                                                                    Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Get.theme.primaryColor,
                                                                          borderRadius: BorderRadius.circular(5),
                                                                        )),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom: 20),
                                                                      child: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Container(
                                                                            decoration: BoxDecoration(
                                                                              color: Get.theme.primaryColor,
                                                                              borderRadius: BorderRadius.circular(5),
                                                                            ),
                                                                            padding: EdgeInsets.symmetric(horizontal: 3),
                                                                            child: Row(
                                                                              children: [
                                                                                CircleAvatar(
                                                                                  radius: 3,
                                                                                  backgroundColor: Colors.green,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 3,
                                                                                ),
                                                                                Text(
                                                                                  'LIVE',
                                                                                  style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.w300,
                                                                                  ),
                                                                                ).tr(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${bottomNavigationController.liveAstrologer[index].name}',
                                                                            style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w300,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ).tr(),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ])));
                                                  },
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),

                          dailyHoroscopeController
                              .dailyList!
                              .tomorrowInsight!
                              .isNotEmpty ||
                              dailyHoroscopeController
                                  .dailyList!
                                  .todayInsight!
                                  .isNotEmpty ||
                              dailyHoroscopeController
                                  .dailyList!
                                  .yeasterdayInsight!
                                  .isNotEmpty
                              ? Text('Daily Horosope Insights',
                              style:
                              Get.textTheme.titleMedium)
                              .tr()
                              : SizedBox(),
                          dailyHoroscopeController.day == 1
                              ? dailyHoroscopeController.dailyList!
                              .yeasterdayInsight!.isNotEmpty
                              ? ListView.builder(
                              physics:
                              NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount:
                              dailyHoroscopeController
                                  .dailyList!
                                  .yeasterdayInsight!
                                  .length,
                              itemBuilder:
                                  (context, index) {
                                return Card(
                                  //margin: EdgeInsets.all(7),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets
                                        .all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        dailyHoroscopeController
                                            .dailyList!
                                            .yeasterdayInsight![
                                        index]
                                            .coverImage !=
                                            ""
                                            ? Container(
                                          height: 150,
                                          width: double
                                              .infinity,
                                          padding:
                                          EdgeInsets
                                              .all(8),
                                          child: Image
                                              .network(
                                            '${global.imgBaseurl}${dailyHoroscopeController.dailyList!.yeasterdayInsight![index].coverImage}',
                                            fit: BoxFit
                                                .cover,
                                          ),
                                        )
                                            : SizedBox(),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment
                                              .bottomRight,
                                          child: RotatedBox(
                                            quarterTurns:
                                            45,
                                            child: ClipPath(
                                              clipper: MultiplePointsClipper(
                                                  Sides
                                                      .bottom,
                                                  heightOfPoint:
                                                  10,
                                                  numberOfPoints:
                                                  1),
                                              child:
                                              Container(
                                                width: 20,
                                                height: 135,
                                                decoration:
                                                BoxDecoration(
                                                    color:
                                                    Get.theme.primaryColor,
                                                    borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.circular(10),
                                                    )),
                                                alignment:
                                                Alignment
                                                    .topCenter,
                                                padding: EdgeInsets
                                                    .only(
                                                    top:
                                                    5),
                                                child:
                                                RotatedBox(
                                                  quarterTurns:
                                                  -45,
                                                  child:
                                                  Text(
                                                    "${dailyHoroscopeController.dailyList!.yeasterdayInsight![index].title}",
                                                    textAlign:
                                                    TextAlign.center,
                                                    style: Get
                                                        .theme
                                                        .primaryTextTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                      fontSize:
                                                      10,
                                                    ),
                                                  ).tr(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "\"${dailyHoroscopeController.dailyList!.yeasterdayInsight![index].title} \"",
                                          style: Get
                                              .theme
                                              .primaryTextTheme
                                              .titleMedium!
                                              .copyWith(
                                              fontWeight:
                                              FontWeight
                                                  .w500),
                                        ).tr(),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FutureBuilder(
                                          future: global
                                              .showHtml(
                                            html: dailyHoroscopeController
                                                .dailyList!
                                                .yeasterdayInsight![
                                            index]
                                                .description ??
                                                '',
                                            style: {
                                              "html": Style(
                                                  color: Colors
                                                      .grey),
                                            },
                                          ),
                                          builder: (context,
                                              snapshot) {
                                            return snapshot
                                                .data ??
                                                const SizedBox();
                                          },
                                        ),
                                        TextButton(
                                          onPressed:
                                              () async {
                                            String link = dailyHoroscopeController
                                                .dailyList!
                                                .yeasterdayInsight![
                                            index]
                                                .link
                                                .toString();
                                            print(link);
                                            if (link ==
                                                "") {
                                            } else {
                                              if (await canLaunchUrl(
                                                  Uri.parse(
                                                      link))) {
                                                await launchUrl(
                                                    Uri.parse(
                                                        link));
                                              }
                                            }
                                          },
                                          child: Text(
                                              'Watch ${dailyHoroscopeController.dailyList!.yeasterdayInsight![index].title}',
                                              style: Get
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500))
                                              .tr(),
                                          style:
                                          ButtonStyle(
                                            padding: WidgetStateProperty
                                                .all(EdgeInsets
                                                .all(
                                                10)),
                                            backgroundColor:
                                            WidgetStateProperty
                                                .all(Get
                                                .theme
                                                .primaryColor),
                                            shape:
                                            WidgetStateProperty
                                                .all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              : dailyHoroscopeController.day ==
                              2
                          // ignore: unnecessary_null_comparison
                              ? dailyHoroscopeController
                              .dailyList!
                              .todayInsight!
                              .isNotEmpty
                              ? Card(
                            //margin: EdgeInsets.all(7),
                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .start,
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Container(
                                    height: 150,
                                    width: double
                                        .infinity,
                                    padding:
                                    EdgeInsets
                                        .all(
                                        8),
                                    child: Image
                                        .network(
                                      '${global.imgBaseurl}${dailyHoroscopeController.dailyList!.todayInsight![1].coverImage}',
                                      fit: BoxFit
                                          .cover,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment:
                                    Alignment
                                        .bottomRight,
                                    child:
                                    RotatedBox(
                                      quarterTurns:
                                      45,
                                      child:
                                      ClipPath(
                                        clipper: MultiplePointsClipper(
                                            Sides
                                                .bottom,
                                            heightOfPoint:
                                            10,
                                            numberOfPoints:
                                            1),
                                        child:
                                        Container(
                                          width:
                                          20,
                                          height:
                                          135,
                                          decoration: BoxDecoration(
                                              color: Get.theme.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(10),
                                              )),
                                          alignment:
                                          Alignment.topCenter,
                                          padding:
                                          EdgeInsets.only(top: 5),
                                          child:
                                          RotatedBox(
                                            quarterTurns:
                                            -45,
                                            child:
                                            Text(
                                              ' ${dailyHoroscopeController.dailyList!.todayInsight![2].name}',
                                              textAlign:
                                              TextAlign.center,
                                              style:
                                              Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                                fontSize: 10,
                                              ),
                                            ).tr(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "\"${dailyHoroscopeController.dailyList!.todayInsight![1].title} \"",
                                    style: Get
                                        .theme
                                        .primaryTextTheme
                                        .titleMedium!
                                        .copyWith(
                                        fontWeight:
                                        FontWeight.w500),
                                  ).tr(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FutureBuilder(
                                    future: global
                                        .showHtml(
                                      html: dailyHoroscopeController
                                          .dailyList!
                                          .todayInsight![1]
                                          .description ??
                                          '',
                                    ),
                                    builder: (context,
                                        snapshot) {
                                      return snapshot
                                          .data ??
                                          const SizedBox();
                                    },
                                  ),
                                  TextButton(
                                    onPressed:
                                        () async {},
                                    child: Text(
                                        'Watch Movie',
                                        style: Get
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(fontSize: 12, fontWeight: FontWeight.w500))
                                        .tr(),
                                    style:
                                    ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          EdgeInsets.all(
                                              10)),
                                      backgroundColor:
                                      WidgetStateProperty.all(Get
                                          .theme
                                          .primaryColor),
                                      shape:
                                      WidgetStateProperty
                                          .all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : dailyHoroscopeController
                              .day ==
                              1
                          // ignore: unnecessary_null_comparison
                              ? dailyHoroscopeController.dailyList!.tomorrowHoroscope![2] !=
                              null
                              ? Card(
                            child:
                            Padding(
                              padding:
                              const EdgeInsets
                                  .all(
                                  8.0),
                              child:
                              Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .start,
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Container(
                                    height:
                                    150,
                                    width:
                                    double.infinity,
                                    padding:
                                    EdgeInsets.all(8),
                                    child:
                                    Image.network(
                                      '${global.imgBaseurl}${dailyHoroscopeController.dailyList!.tomorrowInsight![2].coverImage}',
                                      fit:
                                      BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                    10,
                                  ),
                                  Align(
                                    alignment:
                                    Alignment.bottomRight,
                                    child:
                                    RotatedBox(
                                      quarterTurns:
                                      45,
                                      child:
                                      ClipPath(
                                        clipper: MultiplePointsClipper(Sides.bottom, heightOfPoint: 10, numberOfPoints: 1),
                                        child: Container(
                                          width: 20,
                                          height: 135,
                                          decoration: BoxDecoration(
                                              color: Get.theme.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(10),
                                              )),
                                          alignment: Alignment.topCenter,
                                          padding: EdgeInsets.only(top: 5),
                                          child: RotatedBox(
                                            quarterTurns: -45,
                                            child: Text(
                                              '${dailyHoroscopeController.dailyList!.tomorrowInsight![2].name}',
                                              textAlign: TextAlign.center,
                                              style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                                fontSize: 10,
                                              ),
                                            ).tr(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "\"${dailyHoroscopeController.dailyList!.tomorrowInsight![2].title} \"",
                                    style: Get
                                        .theme
                                        .primaryTextTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ).tr(),
                                  SizedBox(
                                    height:
                                    10,
                                  ),
                                  Html(
                                    data:
                                    '${dailyHoroscopeController.dailyList!.tomorrowInsight![2].description}',
                                  ),
                                  TextButton(
                                    onPressed:
                                        () {},
                                    child:
                                    Text('Watch Movie', style: Get.textTheme.titleMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w500)).tr(),
                                    style:
                                    ButtonStyle(
                                      padding:
                                      WidgetStateProperty.all(EdgeInsets.all(10)),
                                      backgroundColor:
                                      WidgetStateProperty.all(Get.theme.primaryColor),
                                      shape:
                                      WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : SizedBox()
                              : SizedBox()
                              : SizedBox()
                              : dailyHoroscopeController.day == 2
                          // ignore: unnecessary_null_comparison
                              ? dailyHoroscopeController
                              .dailyList!
                              .todayInsight!
                              .isNotEmpty
                              ? ListView.builder(
                              itemCount:
                              dailyHoroscopeController
                                  .dailyList!
                                  .todayInsight!
                                  .length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Card(
                                  //margin: EdgeInsets.all(7),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets
                                        .all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Container(
                                          height: 150,
                                          width: double
                                              .infinity,
                                          padding:
                                          EdgeInsets
                                              .all(
                                              8),
                                          child: Image
                                              .network(
                                            '${global.imgBaseurl}${dailyHoroscopeController.dailyList!.todayInsight![index].coverImage}',
                                            fit: BoxFit
                                                .cover,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment:
                                          Alignment
                                              .bottomRight,
                                          child:
                                          RotatedBox(
                                            quarterTurns:
                                            45,
                                            child:
                                            ClipPath(
                                              clipper: MultiplePointsClipper(
                                                  Sides
                                                      .bottom,
                                                  heightOfPoint:
                                                  10,
                                                  numberOfPoints:
                                                  1),
                                              child:
                                              Container(
                                                width:
                                                20,
                                                height:
                                                135,
                                                decoration: BoxDecoration(
                                                    color: Get.theme.primaryColor,
                                                    borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.circular(10),
                                                    )),
                                                alignment:
                                                Alignment.topCenter,
                                                padding:
                                                EdgeInsets.only(top: 5),
                                                child:
                                                RotatedBox(
                                                  quarterTurns:
                                                  -45,
                                                  child:
                                                  Text(
                                                    '${dailyHoroscopeController.dailyList!.todayInsight![index].name}',
                                                    textAlign:
                                                    TextAlign.center,
                                                    style:
                                                    Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                                      fontSize: 10,
                                                    ),
                                                  ).tr(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "\"${dailyHoroscopeController.dailyList!.todayInsight![index].title} \"",
                                          style: Get
                                              .theme
                                              .primaryTextTheme
                                              .titleMedium!
                                              .copyWith(
                                              fontWeight:
                                              FontWeight.w500),
                                        ).tr(),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FutureBuilder(
                                          future: global
                                              .showHtml(
                                            html: dailyHoroscopeController
                                                .dailyList!
                                                .todayInsight![index]
                                                .description ??
                                                '',
                                          ),
                                          builder: (context,
                                              snapshot) {
                                            return snapshot
                                                .data ??
                                                const SizedBox();
                                          },
                                        ),
                                        TextButton(
                                          onPressed:
                                              () async {
                                            String link = dailyHoroscopeController
                                                .dailyList!
                                                .todayInsight![
                                            index]
                                                .link
                                                .toString();
                                            print(link);
                                            if (link ==
                                                "") {
                                            } else {
                                              if (await canLaunchUrl(
                                                  Uri.parse(
                                                      link))) {
                                                await launchUrl(
                                                    Uri.parse(link));
                                              }
                                            }
                                          },
                                          child: Text(
                                              'Watch ${dailyHoroscopeController.dailyList!.todayInsight![index].title}',
                                              style: Get
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(fontSize: 12, fontWeight: FontWeight.w500))
                                              .tr(),
                                          style:
                                          ButtonStyle(
                                            padding: WidgetStateProperty.all(
                                                EdgeInsets.all(
                                                    10)),
                                            backgroundColor:
                                            WidgetStateProperty.all(Get
                                                .theme
                                                .primaryColor),
                                            shape:
                                            WidgetStateProperty
                                                .all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              : const SizedBox()
                              : dailyHoroscopeController.day == 3
                          // ignore: unnecessary_null_comparison
                              ? dailyHoroscopeController.dailyList!.tomorrowInsight!.isNotEmpty
                              ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: dailyHoroscopeController.dailyList!.tomorrowInsight!.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets
                                        .all(
                                        8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Container(
                                          height:
                                          150,
                                          width: double
                                              .infinity,
                                          padding:
                                          EdgeInsets.all(
                                              8),
                                          child: Image
                                              .network(
                                            '${global.imgBaseurl}${dailyHoroscopeController.dailyList!.tomorrowInsight![index].coverImage}',
                                            fit: BoxFit
                                                .cover,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                          10,
                                        ),
                                        Align(
                                          alignment:
                                          Alignment
                                              .bottomRight,
                                          child:
                                          RotatedBox(
                                            quarterTurns:
                                            45,
                                            child:
                                            ClipPath(
                                              clipper: MultiplePointsClipper(
                                                  Sides.bottom,
                                                  heightOfPoint: 10,
                                                  numberOfPoints: 1),
                                              child:
                                              Container(
                                                width:
                                                20,
                                                height:
                                                135,
                                                decoration: BoxDecoration(
                                                    color: Get.theme.primaryColor,
                                                    borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.circular(10),
                                                    )),
                                                alignment:
                                                Alignment.topCenter,
                                                padding:
                                                EdgeInsets.only(top: 5),
                                                child:
                                                RotatedBox(
                                                  quarterTurns: -45,
                                                  child: Text(
                                                    '${dailyHoroscopeController.dailyList!.tomorrowInsight![index].name}',
                                                    textAlign: TextAlign.center,
                                                    style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                                                      fontSize: 10,
                                                    ),
                                                  ).tr(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "\"${dailyHoroscopeController.dailyList!.tomorrowInsight![index].title} \"",
                                          style: Get
                                              .theme
                                              .primaryTextTheme
                                              .titleMedium!
                                              .copyWith(
                                              fontWeight: FontWeight.w500),
                                        ).tr(),
                                        SizedBox(
                                          height:
                                          10,
                                        ),
                                        FutureBuilder(
                                          future: global
                                              .showHtml(
                                            html: dailyHoroscopeController.dailyList!.tomorrowInsight![index].description ??
                                                '',
                                          ),
                                          builder:
                                              (context,
                                              snapshot) {
                                            return snapshot.data ??
                                                const SizedBox();
                                          },
                                        ),
                                        TextButton(
                                          onPressed:
                                              () async {
                                            String link = dailyHoroscopeController
                                                .dailyList!
                                                .tomorrowInsight![index]
                                                .link
                                                .toString();
                                            print(
                                                link);
                                            if (link ==
                                                "") {
                                            } else {
                                              if (await canLaunchUrl(
                                                  Uri.parse(link))) {
                                                await launchUrl(Uri.parse(link));
                                              }
                                            }
                                          },
                                          child: Text(
                                              'Watch ${dailyHoroscopeController.dailyList!.tomorrowInsight![index].title}',
                                              style: Get.textTheme.titleMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w500))
                                              .tr(),
                                          style:
                                          ButtonStyle(
                                            padding:
                                            WidgetStateProperty.all(EdgeInsets.all(10)),
                                            backgroundColor: WidgetStateProperty.all(Get
                                                .theme
                                                .primaryColor),
                                            shape: WidgetStateProperty
                                                .all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              : SizedBox()
                              : SizedBox(),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    dailyHoroscopeController
                                        .updateTimely(
                                        month: false,
                                        week: true,
                                        year: false);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        18, 8, 18, 8),
                                    decoration: BoxDecoration(
                                      color:
                                      dailyHoroscopeController
                                          .isWeek
                                          ? Color.fromARGB(255,
                                          247, 243, 214)
                                          : Colors.transparent,
                                      border: Border.all(
                                          color:
                                          dailyHoroscopeController
                                              .isWeek
                                              ? Get.theme
                                              .primaryColor
                                              : Colors.grey),
                                      borderRadius:
                                      BorderRadius.only(
                                          topLeft:
                                          Radius.circular(
                                              10.0),
                                          bottomLeft:
                                          Radius.circular(
                                              10.0)),
                                    ),
                                    child: Text(
                                        '''Daily \n Horoscope''',
                                        textAlign:
                                        TextAlign.center,
                                        style: Get.textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontSize: 12))
                                        .tr(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    dailyHoroscopeController
                                        .updateTimely(
                                        month: true,
                                        week: false,
                                        year: false);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        18, 8, 18, 8),
                                    decoration: BoxDecoration(
                                      color:
                                      dailyHoroscopeController
                                          .isMonth
                                          ? Color.fromARGB(255,
                                          247, 243, 214)
                                          : Colors.transparent,
                                      border: Border.all(
                                          color:
                                          dailyHoroscopeController
                                              .isMonth
                                              ? Get.theme
                                              .primaryColor
                                              : Colors.grey),
                                    ),
                                    child: Text(
                                        '''Monthly \n Horoscope''',
                                        textAlign:
                                        TextAlign.center,
                                        style: Get.textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontSize: 12))
                                        .tr(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    dailyHoroscopeController
                                        .updateTimely(
                                        month: false,
                                        week: false,
                                        year: true);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        18, 8, 18, 8),
                                    decoration: BoxDecoration(
                                      color:
                                      dailyHoroscopeController
                                          .isYear
                                          ? Color.fromARGB(255,
                                          247, 243, 214)
                                          : Colors.transparent,
                                      border: Border.all(
                                          color:
                                          dailyHoroscopeController
                                              .isYear
                                              ? Get.theme
                                              .primaryColor
                                              : Colors.grey),
                                      borderRadius:
                                      BorderRadius.only(
                                          topRight:
                                          Radius.circular(
                                              10.0),
                                          bottomRight:
                                          Radius.circular(
                                              10.0)),
                                    ),
                                    child: Text(
                                        '''Yearly \n Horoscope''',
                                        textAlign:
                                        TextAlign.center,
                                        style: Get.textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontSize: 12))
                                        .tr(),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Get.theme.primaryColor),
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: dailyHoroscopeController.isWeek
                                ? Padding(
                              padding:
                              const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Center(
                                      child: Text(
                                        'Daily Horoscope',
                                        style: Get.textTheme
                                            .titleMedium!
                                            .copyWith(
                                            fontWeight:
                                            FontWeight
                                                .bold),
                                        textAlign:
                                        TextAlign.center,
                                      ).tr()),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.black,
                                          height: 10,
                                          indent: 200,
                                          endIndent: 10,
                                        ),
                                      ),
                                      Text(
                                          '${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                                          style: Get.textTheme
                                              .titleMedium!
                                              .copyWith(
                                              fontSize:
                                              13,
                                              color: Colors
                                                  .grey)),
                                      const Expanded(
                                        child: Divider(
                                          color: Colors.black,
                                          height: 10,
                                          indent: 200,
                                          endIndent: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      NeverScrollableScrollPhysics(),
                                      itemCount:
                                      dailyHoroscopeController
                                          .dailyList!
                                          .weeklyHoroScope!
                                          .length,
                                      itemBuilder:
                                          (context, index) {
                                        return Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              index == 0
                                                  ? "Daily Horoscope"
                                                  : '${dailyHoroscopeController.dailyList!.weeklyHoroScope![index].title}',
                                              style: Get
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                  fontWeight:
                                                  FontWeight.bold),
                                              textAlign:
                                              TextAlign
                                                  .center,
                                            ).tr(),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            FutureBuilder(
                                              future: global
                                                  .showHtml(
                                                html: dailyHoroscopeController
                                                    .dailyList!
                                                    .weeklyHoroScope![
                                                index]
                                                    .description ??
                                                    '',
                                              ),
                                              builder: (context,
                                                  snapshot) {
                                                return snapshot
                                                    .data ??
                                                    const SizedBox();
                                              },
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        );
                                      })
                                ],
                              ),
                            )
                                : dailyHoroscopeController.isMonth
                                ? dailyHoroscopeController
                                .dailyList ==
                                null
                                ? const SizedBox()
                                : Padding(
                              padding:
                              const EdgeInsets
                                  .all(8.0),
                              child: Column(
                                children: [
                                  Text('Monthly horoscope',
                                      style: Get
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                          fontWeight:
                                          FontWeight.bold))
                                      .tr(),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisSize:
                                    MainAxisSize
                                        .min,
                                    children: [
                                      Expanded(
                                        child:
                                        Divider(
                                          color: Colors
                                              .black,
                                          height: 10,
                                          indent: 200,
                                          endIndent:
                                          10,
                                        ),
                                      ),
                                      Text(
                                          DateFormat(
                                              'MMMM yyy')
                                              .format(DateTime
                                              .now()),
                                          style: Get
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                              fontSize:
                                              13,
                                              color:
                                              Colors.grey)),
                                      const Expanded(
                                        child:
                                        Divider(
                                          color: Colors
                                              .black,
                                          height: 10,
                                          indent: 200,
                                          endIndent:
                                          10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                      shrinkWrap:
                                      true,
                                      physics:
                                      NeverScrollableScrollPhysics(),
                                      itemCount: dailyHoroscopeController
                                          .dailyList!
                                          .monthlyHoroScope!
                                          .length,
                                      itemBuilder:
                                          (context,
                                          index) {
                                        return Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(dailyHoroscopeController.dailyList!.monthlyHoroScope![index].title!,
                                                style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold))
                                                .tr(),
                                            SizedBox(
                                              height:
                                              10,
                                            ),
                                            FutureBuilder(
                                              future:
                                              global.showHtml(
                                                html: dailyHoroscopeController.dailyList!.monthlyHoroScope![index].description ??
                                                    '',
                                              ),
                                              builder:
                                                  (context,
                                                  snapshot) {
                                                return snapshot.data ??
                                                    const SizedBox();
                                              },
                                            ),
                                            const SizedBox(
                                              height:
                                              10,
                                            ),
                                          ],
                                        );
                                      })
                                ],
                              ),
                            )
                                : dailyHoroscopeController
                                .isYear
                                ? dailyHoroscopeController
                                .dailyList !=
                                null
                                ? TimeWiseHoroscopeWidget(
                              dailyHoroscopeModel:
                              dailyHoroscopeController
                                  .dailyList!,
                            )
                                : const SizedBox()
                                : SizedBox(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          global.user.contactNo == null &&
                              global.currentUserId == null
                              ? const SizedBox()
                              : Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey),
                              color: Color.fromARGB(
                                  255, 247, 243, 214),
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            child: TextButton(
                              onPressed: () {
                                dailyHoroscopeController
                                    .feedbackGroupValue =
                                null;
                                dailyHoroscopeController
                                    .update();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding:
                                        const EdgeInsets
                                            .only(
                                            left: 8.0,
                                            right: 8.0),
                                        child: SimpleDialog(
                                          insetPadding:
                                          const EdgeInsets
                                              .all(8),
                                          titlePadding:
                                          const EdgeInsets
                                              .all(0),
                                          title: null,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .end,
                                              children: [
                                                IconButton(
                                                    onPressed:
                                                        () {
                                                      Get.back();
                                                    },
                                                    icon: Icon(
                                                        Icons
                                                            .close))
                                              ],
                                            ),
                                            GetBuilder<
                                                DailyHoroscopeController>(
                                                builder: (d) {
                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .all(
                                                            8.0),
                                                        child: Text(
                                                            'How was your overall experience of Daily horoscope? ',
                                                            style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold))
                                                            .tr(),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                        25,
                                                        child:
                                                        RadioListTile(
                                                          dense:
                                                          true,
                                                          contentPadding:
                                                          EdgeInsets.symmetric(horizontal: 0),
                                                          title: Text("Great")
                                                              .tr(),
                                                          value:
                                                          "Great",
                                                          activeColor: Get
                                                              .theme
                                                              .primaryColor,
                                                          groupValue:
                                                          dailyHoroscopeController.feedbackGroupValue,
                                                          onChanged:
                                                              (value) {
                                                            dailyHoroscopeController.feedbackGroupValue =
                                                                value;
                                                            dailyHoroscopeController
                                                                .update();
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                        25,
                                                        child:
                                                        RadioListTile(
                                                          dense:
                                                          true,
                                                          contentPadding:
                                                          EdgeInsets.symmetric(horizontal: 0),
                                                          title: Text("Average")
                                                              .tr(),
                                                          value:
                                                          "Average",
                                                          activeColor: Get
                                                              .theme
                                                              .primaryColor,
                                                          groupValue:
                                                          dailyHoroscopeController.feedbackGroupValue,
                                                          onChanged:
                                                              (value) {
                                                            dailyHoroscopeController.feedbackGroupValue =
                                                                value;
                                                            dailyHoroscopeController
                                                                .update();
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                        25,
                                                        child:
                                                        RadioListTile(
                                                          dense:
                                                          true,
                                                          contentPadding:
                                                          EdgeInsets.symmetric(horizontal: 0),
                                                          title: Text("Needs improvement")
                                                              .tr(),
                                                          value:
                                                          "Needs improvement",
                                                          activeColor: Get
                                                              .theme
                                                              .primaryColor,
                                                          groupValue:
                                                          dailyHoroscopeController.feedbackGroupValue,
                                                          onChanged:
                                                              (value) {
                                                            dailyHoroscopeController.feedbackGroupValue =
                                                                value;
                                                            dailyHoroscopeController
                                                                .update();
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                }),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(
                                                  8.0),
                                              child: Divider(
                                                thickness: 2,
                                              ),
                                            ),
                                            GetBuilder<
                                                DailyHoroscopeController>(
                                                builder: (d) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        left: 8.0,
                                                        right:
                                                        8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        dailyHoroscopeController.feedbackGroupValue ==
                                                            null
                                                            ? const SizedBox()
                                                            : Text('Share your feedback', style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold))
                                                            .tr(),
                                                        dailyHoroscopeController.feedbackGroupValue ==
                                                            null
                                                            ? const SizedBox()
                                                            : TextField(
                                                          controller: dailyHoroscopeController.feedbackController,
                                                          focusNode: dailyHoroscopeController.fFeedback,
                                                          keyboardType: TextInputType.multiline,
                                                          minLines: 3,
                                                          maxLines: 7,
                                                          decoration: InputDecoration(
                                                            isDense: true,
                                                            hintText: 'Type here',
                                                            hintStyle: TextStyle(fontSize: 10),
                                                            border: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.grey),
                                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.grey),
                                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.grey),
                                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: double
                                                              .infinity,
                                                          child:
                                                          TextButton(
                                                            style:
                                                            ButtonStyle(
                                                              padding:
                                                              WidgetStateProperty.all(EdgeInsets.all(0)),
                                                              backgroundColor: WidgetStateProperty.all(dailyHoroscopeController.feedbackGroupValue == null
                                                                  ? Colors.grey
                                                                  : Get.theme.primaryColor),
                                                              shape:
                                                              WidgetStateProperty.all(
                                                                RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              dailyHoroscopeController.fFeedback.unfocus();
                                                              if (dailyHoroscopeController.feedbackGroupValue !=
                                                                  null) {
                                                                global.showOnlyLoaderDialog(context);
                                                                dailyHoroscopeController.addFeedBack();
                                                                global.hideLoader();
                                                                Get.back(); //back from dailog
                                                              }
                                                            },
                                                            child:
                                                            Text(
                                                              'Submit',
                                                              textAlign:
                                                              TextAlign.center,
                                                              style:
                                                              Get.theme.primaryTextTheme.titleMedium,
                                                            ).tr(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Text('Share Feedback',
                                      style: Get.textTheme
                                          .titleMedium!
                                          .copyWith(
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight
                                              .bold)),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  CircleAvatar(
                                      radius: 12,
                                      backgroundColor:
                                      Colors.black,
                                      child: Icon(
                                        Icons
                                            .arrow_forward_ios,
                                        size: 10,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                          )
                        ]),
                  );
                }),
          ),
        ),
        bottomSheet: ContactAstrologerCottomButton());
  }
}
