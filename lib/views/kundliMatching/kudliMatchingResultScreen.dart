// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/kundliMatchingController.dart';
import 'package:AstrowayCustomer/controllers/liveController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:AstrowayCustomer/views/liveAstrologerList.dart';
import 'package:AstrowayCustomer/views/live_astrologer/live_astrologer_screen.dart';
import 'package:AstrowayCustomer/widget/contactAstrologerBottomButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../model/NorthKundaliMatchingModel.dart';
import '../../model/southkundaliMatchingModel.dart';

class KudliMatchingResultScreen extends StatelessWidget {
  KudliMatchingResultScreen(
      {Key? key,
      required this.northKundaliMatchingModel,
      required this.southKundaliMatchingModel})
      : super(key: key);
  final KundliMatchingController kundliMatchingController =
      Get.find<KundliMatchingController>();
  BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();
  LiveController liveController = Get.find<LiveController>();
  NorthKundaliMatchingModel? northKundaliMatchingModel;
  SouthKundaliMatchingModel? southKundaliMatchingModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomSheet: ContactAstrologerCottomButton(),
        body:
            GetBuilder<KundliMatchingController>(builder: (matchingController) {
          return SingleChildScrollView(
            child:
                northKundaliMatchingModel != null ||
                        southKundaliMatchingModel != null
                    ? (southKundaliMatchingModel != null
                        ? (southKundaliMatchingModel!.recordList!.response ==
                                null
                            ? Center(child: Text("No Data"))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.4,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(30),
                                              bottomRight: Radius.circular(30)),
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: AssetImage(Images.sky),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                              child: Text(
                                                "Compatibility Score",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ).tr(),
                                            ),
                                            southKundaliMatchingModel!
                                                        .recordList!
                                                        .response!
                                                        .score ==
                                                    null
                                                ? SizedBox()
                                                : Container(
                                                    height: 180,
                                                    width: 230,
                                                    child: SfRadialGauge(
                                                      axes: <RadialAxis>[
                                                        RadialAxis(
                                                          showLabels: false,
                                                          showAxisLine: false,
                                                          showTicks: false,
                                                          minimum: 0,
                                                          maximum: double.parse(
                                                              southKundaliMatchingModel!
                                                                  .recordList!
                                                                  .response!
                                                                  .botResponse
                                                                  .toString()
                                                                  .split("out of")[
                                                                      1]
                                                                  .substring(
                                                                      0, 3)),
                                                          ranges: <GaugeRange>[
                                                            GaugeRange(
                                                              startValue: 0,
                                                              endValue: 3.3,
                                                              color: Color(
                                                                  0xFFFE2A25),
                                                              label: '',
                                                              sizeUnit:
                                                                  GaugeSizeUnit
                                                                      .factor,
                                                              labelStyle:
                                                                  GaugeTextStyle(
                                                                      fontFamily:
                                                                          'Times',
                                                                      fontSize:
                                                                          20),
                                                              startWidth: 0.50,
                                                              endWidth: 0.50,
                                                            ),
                                                            GaugeRange(
                                                              startValue: 3.3,
                                                              endValue: 6.6,
                                                              color: Color(
                                                                  0xFFFFBA00),
                                                              label: '',
                                                              startWidth: 0.50,
                                                              endWidth: 0.50,
                                                              sizeUnit:
                                                                  GaugeSizeUnit
                                                                      .factor,
                                                            ),
                                                            GaugeRange(
                                                              startValue: 6.6,
                                                              endValue: 10,
                                                              color: Color(
                                                                  0xFF00AB47),
                                                              label: '',
                                                              sizeUnit:
                                                                  GaugeSizeUnit
                                                                      .factor,
                                                              startWidth: 0.50,
                                                              endWidth: 0.50,
                                                            ),
                                                          ],
                                                          pointers: <GaugePointer>[
                                                            NeedlePointer(
                                                              value: southKundaliMatchingModel!
                                                                          .recordList!
                                                                          .response!
                                                                          .score !=
                                                                      null
                                                                  ? double.parse(southKundaliMatchingModel!
                                                                      .recordList!
                                                                      .response!
                                                                      .score
                                                                      .toString())
                                                                  : 0.0,
                                                              needleStartWidth:
                                                                  0,
                                                              needleEndWidth: 5,
                                                              needleColor: Color(
                                                                  0xFFDADADA),
                                                              enableAnimation:
                                                                  true,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        leading: GestureDetector(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: Icon(
                                            kIsWeb
                                                ? Icons.arrow_back
                                                : Platform.isIOS
                                                    ? Icons.arrow_back_ios
                                                    : Icons.arrow_back,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: const Text(
                                          "Kundli Matching",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ).tr(),
                                        trailing: Container(
                                          padding: const EdgeInsets.all(3),
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Get.theme.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              // showDialog(
                                              //   context: context,
                                              //   builder: (context) {
                                              //     return Dialog(
                                              //       insetPadding: EdgeInsets.zero,
                                              //       child: Screenshot(
                                              //         controller: screenshotController,
                                              //         child: Container(
                                              //           width: MediaQuery.of(context).size.width,
                                              //           decoration: const BoxDecoration(
                                              //             image: DecorationImage(
                                              //               fit: BoxFit.fill,
                                              //               image: AssetImage(Images.sky),
                                              //             ),
                                              //           ),
                                              //           child: Padding(
                                              //             padding: const EdgeInsets.all(8.0),
                                              //             child: Column(
                                              //               children: [
                                              //                 Row(
                                              //                   mainAxisAlignment: MainAxisAlignment.center,
                                              //                   children: [
                                              //                     Image.asset(
                                              //                       Images.splash_image,
                                              //                       height: 30,
                                              //                       width: 30,
                                              //                     ),
                                              //                     const SizedBox(
                                              //                       width: 10,
                                              //                     ),
                                              //                     Text(
                                              //                       global.getSystemFlagValueForLogin(global.systemFlagNameList.appName),
                                              //                       style: TextStyle(color: Colors.white),
                                              //                     ),
                                              //                   ],
                                              //                 ),
                                              //                 isFemaleManglik == null
                                              //                     ? const SizedBox()
                                              //                     : Padding(
                                              //                         padding: const EdgeInsets.all(8.0),
                                              //                         child: Row(
                                              //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              //                           children: [
                                              //                             Column(
                                              //                               children: [
                                              //                                 Container(
                                              //                                   height: 70,
                                              //                                   width: 100,
                                              //                                   decoration: BoxDecoration(
                                              //                                     shape: BoxShape.circle,
                                              //                                     border: Border.all(
                                              //                                       color: Colors.green,
                                              //                                       width: 3, /*strokeAlign: StrokeAlign.outside*/
                                              //                                     ),
                                              //                                     color: Get.theme.primaryColor,
                                              //                                     image: const DecorationImage(
                                              //                                       image: AssetImage(
                                              //                                         "assets/images/no_customer_image.png",
                                              //                                       ),
                                              //                                     ),
                                              //                                   ),
                                              //                                 ),
                                              //                                 Padding(
                                              //                                   padding: const EdgeInsets.only(top: 8.0),
                                              //                                   child: Text(
                                              //                                     '${cBoysName.text}',
                                              //                                     style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(color: Colors.white),
                                              //                                   ),
                                              //                                 ),
                                              //                                 isFemaleManglik == null
                                              //                                     ? const SizedBox()
                                              //                                     : Padding(
                                              //                                         padding: EdgeInsets.only(top: 6.0),
                                              //                                         child: Text(
                                              //                                           isFemaleManglik! ? 'Non Manglik' : 'Manglik',
                                              //                                           style: TextStyle(
                                              //                                             color: isFemaleManglik! ? Colors.green : Colors.red,
                                              //                                           ),
                                              //                                         ),
                                              //                                       ),
                                              //                               ],
                                              //                             ),
                                              //                             Image.asset(
                                              //                               "assets/images/couple_ring_image.png",
                                              //                               scale: 8,
                                              //                             ),
                                              //                             Column(
                                              //                               children: [
                                              //                                 Container(
                                              //                                   height: 60,
                                              //                                   width: 110,
                                              //                                   decoration: BoxDecoration(
                                              //                                     shape: BoxShape.circle,
                                              //                                     border: Border.all(
                                              //                                       color: Colors.green,
                                              //                                       width: 3, /* strokeAlign: StrokeAlign.outside*/
                                              //                                     ),
                                              //                                     color: Get.theme.primaryColor,
                                              //                                     image: const DecorationImage(
                                              //                                       image: AssetImage(
                                              //                                         "assets/images/no_customer_image.png",
                                              //                                       ),
                                              //                                     ),
                                              //                                   ),
                                              //                                 ),
                                              //                                 Padding(
                                              //                                   padding: const EdgeInsets.only(top: 8.0),
                                              //                                   child: Text(
                                              //                                     '${cGirlName.text}',
                                              //                                     style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(color: Colors.white),
                                              //                                   ),
                                              //                                 ),
                                              //                                 Padding(
                                              //                                   padding: EdgeInsets.only(top: 9.0),
                                              //                                   child: Text(
                                              //                                     isFemaleManglik! ? 'Non Manglik' : 'Manglik',
                                              //                                     style: TextStyle(
                                              //                                       color: isFemaleManglik! ? Colors.green : Colors.red,
                                              //                                     ),
                                              //                                   ),
                                              //                                 ),
                                              //                               ],
                                              //                             ),
                                              //                           ],
                                              //                         ),
                                              //                       ),
                                              //                 Padding(
                                              //                   padding: EdgeInsets.only(bottom: 10),
                                              //                   child: Text(
                                              //                     "Compatibility Score",
                                              //                     style: TextStyle(
                                              //                       color: Get.theme.primaryColor,
                                              //                       fontSize: 18,
                                              //                     ),
                                              //                   ),
                                              //                 ),
                                              //                 kundliMatchDetailList!.totalList!.receivedPoints == null
                                              //                     ? SizedBox()
                                              //                     : Container(
                                              //                         height: 180,
                                              //                         width: 230,
                                              //                         child: SfRadialGauge(
                                              //                           axes: <RadialAxis>[
                                              //                             RadialAxis(
                                              //                               showLabels: false,
                                              //                               showAxisLine: false,
                                              //                               showTicks: false,
                                              //                               minimum: 0,
                                              //                               maximum: 36,
                                              //                               ranges: <GaugeRange>[
                                              //                                 GaugeRange(
                                              //                                   startValue: 0,
                                              //                                   endValue: 12,
                                              //                                   color: Color(0xFFFE2A25),
                                              //                                   label: '',
                                              //                                   sizeUnit: GaugeSizeUnit.factor,
                                              //                                   labelStyle: GaugeTextStyle(fontFamily: 'Times', fontSize: 20),
                                              //                                   startWidth: 0.50,
                                              //                                   endWidth: 0.50,
                                              //                                 ),
                                              //                                 GaugeRange(
                                              //                                   startValue: 12,
                                              //                                   endValue: 24,
                                              //                                   color: Color(0xFFFFBA00),
                                              //                                   label: '',
                                              //                                   startWidth: 0.50,
                                              //                                   endWidth: 0.50,
                                              //                                   sizeUnit: GaugeSizeUnit.factor,
                                              //                                 ),
                                              //                                 GaugeRange(
                                              //                                   startValue: 24,
                                              //                                   endValue: 36,
                                              //                                   color: Color(0xFF00AB47),
                                              //                                   label: '',
                                              //                                   sizeUnit: GaugeSizeUnit.factor,
                                              //                                   startWidth: 0.50,
                                              //                                   endWidth: 0.50,
                                              //                                 ),
                                              //                               ],
                                              //                               pointers: <GaugePointer>[
                                              //                                 NeedlePointer(
                                              //                                   value: kundliMatchDetailList!.totalList!.receivedPoints != null ? double.parse(kundliMatchDetailList!.totalList!.receivedPoints.toString()) : 0.0,
                                              //                                   needleStartWidth: 0,
                                              //                                   needleEndWidth: 5,
                                              //                                   needleColor: Color(0xFFDADADA),
                                              //                                 ),
                                              //                               ],
                                              //                             )
                                              //                           ],
                                              //                         )),
                                              //                 kundliMatchDetailList!.totalList!.receivedPoints == null
                                              //                     ? const SizedBox()
                                              //                     : Container(
                                              //                         height: 50,
                                              //                         width: 100,
                                              //                         decoration: BoxDecoration(
                                              //                           color: Colors.white,
                                              //                           border: Border.all(color: Colors.greenAccent),
                                              //                           borderRadius: BorderRadius.circular(15),
                                              //                         ),
                                              //                         child: Center(
                                              //                             child: RichText(
                                              //                           text: TextSpan(
                                              //                             text: '${kundliMatchDetailList!.totalList!.receivedPoints!}/',
                                              //                             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
                                              //                             children: <TextSpan>[
                                              //                               TextSpan(
                                              //                                 text: '${kundliMatchDetailList!.totalList!.totalPoints!}',
                                              //                                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
                                              //                               ),
                                              //                             ],
                                              //                           ),
                                              //                         )),
                                              //                       ),
                                              //                 kundliMatchDetailList!.conclusionList!.report == null
                                              //                     ? const SizedBox()
                                              //                     : Container(
                                              //                         padding: const EdgeInsets.only(top: 8, left: 8.0, right: 8.0),
                                              //                         margin: const EdgeInsets.symmetric(vertical: 20),
                                              //                         width: MediaQuery.of(context).size.width,
                                              //                         decoration: BoxDecoration(
                                              //                           borderRadius: BorderRadius.circular(15),
                                              //                           border: Border.all(color: Get.theme.primaryColor),
                                              //                           gradient: LinearGradient(
                                              //                             begin: Alignment.topCenter,
                                              //                             end: Alignment.bottomCenter,
                                              //                             colors: [
                                              //                               Get.theme.primaryColor,
                                              //                               Colors.white,
                                              //                             ],
                                              //                           ),
                                              //                         ),
                                              //                         child: Column(
                                              //                           children: [
                                              //                             Text(
                                              //                               "${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)} ${tr("Conclusion")}",
                                              //                               style: Theme.of(context).primaryTextTheme.titleMedium,
                                              //                             ),
                                              //                             Padding(
                                              //                               padding: EdgeInsets.only(top: 10.0, bottom: 10),
                                              //                               child: Text(
                                              //                                 '${tr("The overall points of this couple")} ${kundliMatchDetailList!.conclusionList!.report!}',
                                              //                                 style: TextStyle(fontSize: 12, color: Colors.black),
                                              //                               ),
                                              //                             ),
                                              //                           ],
                                              //                         ),
                                              //                       )
                                              //               ],
                                              //             ),
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     );
                                              //   },
                                              // );
                                              // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
                                              // String appShareLink;
                                              // // ignore: unused_local_variable
                                              // String applink;
                                              // final DynamicLinkParameters parameters = DynamicLinkParameters(
                                              //   uriPrefix: 'https://astrowaydiploy.page.link',
                                              //   link: Uri.parse("https://astrowaydiploy.page.link/userProfile?screen=astroProfile"),
                                              //   androidParameters: AndroidParameters(
                                              //     packageName: 'com.astrowaydiploy.user',
                                              //     minimumVersion: 1,
                                              //   ),
                                              // );
                                              // Uri url;
                                              // final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.short);
                                              // url = shortLink.shortUrl;
                                              // appShareLink = url.toString();
                                              // applink = appShareLink;
                                              // Get.back(); //back from dialog
                                              // final temp1 = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
                                              // screenshotController.capture().then((image) async {
                                              //   if (image != null) {
                                              //     try {
                                              //       String fileName = DateTime.now().microsecondsSinceEpoch.toString();
                                              //       final imagePath = await File('${temp1!.path}/$fileName.png').create();
                                              //       // ignore: unnecessary_null_comparison
                                              //       if (imagePath != null) {
                                              //         final temp;
                                              //         if (Platform.isIOS) {
                                              //           temp = await getApplicationDocumentsDirectory();
                                              //         } else {
                                              //           temp = await getExternalStorageDirectory();
                                              //         }
                                              //         final path = '${temp!.path}/$fileName.jpg';
                                              //         File(path).writeAsBytesSync(image);
                                              //
                                              //         await FlutterShare.shareFile(filePath: path, title: '${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)}', text: "Check out the ${global.getSystemFlagValue(global.systemFlagNameList.appName)} marriage compatibility report for ${cBoysName.text} and ${cGirlName.text}. Get your free Matchnaking report here: $appShareLink").then((value) {}).catchError((e) {
                                              //           print(e);
                                              //         });
                                              //       }
                                              //     } catch (e) {
                                              //       print('Exception in match sharing $e');
                                              //     }
                                              //   }
                                              // }).catchError((onError) {
                                              //   print('Error --->> $onError');
                                              // });
                                            },
                                            child: FittedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  FittedBox(
                                                    child: Text(
                                                      "Share",
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              fontSize: 8,
                                                              color:
                                                                  Colors.white),
                                                    ).tr(),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 6.0),
                                                    child: FittedBox(
                                                      child: Icon(
                                                        Icons.share,
                                                        color: Colors.green,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      southKundaliMatchingModel!.recordList!
                                                  .response!.score ==
                                              null
                                          ? const SizedBox()
                                          : Positioned(
                                              bottom: -25,
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.8,
                                              child: Container(
                                                height: 50,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color:
                                                          Colors.greenAccent),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                    child: RichText(
                                                  text: TextSpan(
                                                    text:
                                                        '${southKundaliMatchingModel!.recordList!.response!.score}/',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 24),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text:
                                                            '${southKundaliMatchingModel!.recordList!.response!.botResponse.toString().split("out of")[1].substring(0, 3)}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                              ),
                                            ),
                                    ],
                                  ),
//----------------------Details-----------------------

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      children: [
                                        ///report
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 40.0,
                                          ),
                                          child: Center(
                                            child: Text(
                                                    "${southKundaliMatchingModel!.recordList!.response!.botResponse}",
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18))
                                                .tr(),
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 20.0, bottom: 20),
                                          child: Center(
                                            child: Text("Details",
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18))
                                                .tr(),
                                          ),
                                        ),
//------------------Card-------------------------------

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.dina ==
                                                null
                                            ? const SizedBox()
                                            : Container(
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                    color: Color(0xfffff6f1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.dina!.name!.toUpperCase()}",
                                                              style: Theme.of(
                                                                      context)
                                                                  .primaryTextTheme
                                                                  .titleMedium,
                                                            ).tr(),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0,
                                                                      right: 5),
                                                              child: Text(
                                                                "${southKundaliMatchingModel!.recordList!.response!.dina!.description}",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ).tr(),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "Girl",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                    Text(
                                                                      "${southKundaliMatchingModel!.recordList!.response!.dina!.girlStar}",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.black),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: 50,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "Boy",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                    Text(
                                                                      "${southKundaliMatchingModel!.recordList!.response!.dina!.boyStar}",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.black),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                  ],
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      CircularPercentIndicator(
                                                        radius: 35.0,
                                                        lineWidth: 5.0,
                                                        percent: southKundaliMatchingModel!
                                                                .recordList!
                                                                .response!
                                                                .dina!
                                                                .dina!
                                                                .toDouble() /
                                                            southKundaliMatchingModel!
                                                                .recordList!
                                                                .response!
                                                                .dina!
                                                                .fullScore!
                                                                .toDouble(),
                                                        center: new Text(
                                                          "${southKundaliMatchingModel!.recordList!.response!.dina!.dina}/${southKundaliMatchingModel!.recordList!.response!.dina!.fullScore}",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xfffca47c),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ).tr(),
                                                        progressColor:
                                                            Color(0xfffca47c),
                                                      )
                                                    ],
                                                  ),
                                                )),

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.gana ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffeffaf4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.gana!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.gana!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.gana!.girlGana}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.gana!.boyGana}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .gana!
                                                                    .gana!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .gana!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.gana!.gana!}/${southKundaliMatchingModel!.recordList!.response!.gana!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xfffca47c),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xfffca47c),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.mahendra ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffcf2fd),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.mahendra!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.mahendra!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.mahendra!.girlStar}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.mahendra!.boyStar}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .mahendra!
                                                                    .mahendra!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .mahendra!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.mahendra!.mahendra!}/${southKundaliMatchingModel!.recordList!.response!.mahendra!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffba6ad9),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffba6ad9),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.sthree ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffeef7fe),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.sthree!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.sthree!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.sthree!.girlStar}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.sthree!.boyStar}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .sthree!
                                                                    .sthree!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .sthree!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.sthree!.sthree!}/${southKundaliMatchingModel!.recordList!.response!.sthree!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff58a4f2),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xff58a4f2),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                        southKundaliMatchingModel!.recordList!
                                                    .response!.yoni ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffff2f9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.yoni!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.yoni!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.yoni!.girlYoni}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.yoni!.boyYoni}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .yoni!
                                                                    .yoni!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .yoni!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.yoni!.yoni!}/${southKundaliMatchingModel!.recordList!.response!.yoni!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffff84bb),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffff84bb),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.rasi ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffff6f1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.rasi!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.rasi!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.rasi!.girlRasi}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.rasi!.boyRasi}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .rasi!
                                                                    .rasi!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .rasi!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.rasi!.rasi!}/${southKundaliMatchingModel!.recordList!.response!.rasi!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffffa37a),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffffa37a),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.rasiathi ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffeffaf4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.rasiathi!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.rasiathi!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.rasiathi!.girlLord}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.rasiathi!.boyLord}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .rasiathi!
                                                                    .rasiathi!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .rasiathi!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.rasiathi!.rasiathi}/${southKundaliMatchingModel!.recordList!.response!.rasiathi!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                    (0xff70ce99),
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                              (0xff70ce99),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                        //
                                        southKundaliMatchingModel!.recordList!
                                                    .response!.vasya ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffcf2fd),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.vasya!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.vasya!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.vasya!.girlRasi}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.vasya!.boyRasi}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .vasya!
                                                                    .vasya!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .vasya!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.vasya!.vasya}/${southKundaliMatchingModel!.recordList!.response!.vasya!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffbb6bda),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffbb6bda),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.rajju ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffeffaf4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.rajju!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.rajju!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.rajju!.girlRajju}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.rajju!.boyRajju}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .rajju!
                                                                    .rajju!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .rajju!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.rajju!.rajju}/${southKundaliMatchingModel!.recordList!.response!.rajju!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff70ce99),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xff70ce99),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        southKundaliMatchingModel!.recordList!
                                                    .response!.vedha ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffcf2fd),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${southKundaliMatchingModel!.recordList!.response!.vedha!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${southKundaliMatchingModel!.recordList!.response!.vedha!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.vedha!.girlStar}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${southKundaliMatchingModel!.recordList!.response!.vedha!.boyStar}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .vedha!
                                                                    .vedha!
                                                                    .toDouble() /
                                                                southKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .vedha!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${southKundaliMatchingModel!.recordList!.response!.vedha!.vedha}/${southKundaliMatchingModel!.recordList!.response!.vedha!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffbb6bda),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffbb6bda),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

//----------------------------------Manglik Report-------------------------------------
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Text(
                                            "Manglik Report",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .titleMedium,
                                          ).tr(),
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  height: 70,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width:
                                                          3, /*strokeAlign: StrokeAlign.outside*/
                                                    ),
                                                    color:
                                                        Get.theme.primaryColor,
                                                    image:
                                                        const DecorationImage(
                                                      image: AssetImage(
                                                        "assets/images/no_customer_image.png",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    '${kundliMatchingController.cBoysName.text}',
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium,
                                                  ).tr(),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 9.0),
                                                  child: Text(
                                                    '${southKundaliMatchingModel!.boyManaglikRpt!.response!.botResponse}',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: southKundaliMatchingModel!
                                                                    .boyManaglikRpt!
                                                                    .response!
                                                                    .score! >
                                                                50
                                                            ? Colors.green
                                                            : Colors.red),
                                                  ).tr(),
                                                ),
                                              ],
                                            ),
                                            Image.asset(
                                              "assets/images/couple_ring_image.png",
                                              scale: 8,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  height: 70,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width:
                                                          3, /* strokeAlign: StrokeAlign.outside*/
                                                    ),
                                                    color:
                                                        Get.theme.primaryColor,
                                                    image:
                                                        const DecorationImage(
                                                      image: AssetImage(
                                                        "assets/images/no_customer_image.png",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    '${kundliMatchingController.cGirlName.text}',
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium,
                                                  ).tr(),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 9.0),
                                                  child: Text(
                                                    '${southKundaliMatchingModel!.girlMangalikRpt!.response!.botResponse}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: southKundaliMatchingModel!
                                                                  .girlMangalikRpt!
                                                                  .response!
                                                                  .score! >
                                                              50
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ).tr(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
//--------------------------Conclusion-------------------------------------
                                        southKundaliMatchingModel!.recordList!
                                                    .response!.score ==
                                                null
                                            ? const SizedBox()
                                            : Container(
                                                padding: const EdgeInsets.only(
                                                    top: 8,
                                                    left: 8.0,
                                                    right: 8.0),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Get
                                                          .theme.primaryColor),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Get.theme.primaryColor,
                                                      Colors.white,
                                                    ],
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)} Conclusion",
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                    ).tr(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0),
                                                      child: Text(
                                                        '${tr("The overall points of this couple")} ${southKundaliMatchingModel!.recordList!.response!.score}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.white),
                                                      ).tr(),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 9.0),
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                      .white),
                                                          foregroundColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                      .black),
                                                          shape: WidgetStateProperty.all(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50))),
                                                        ),
                                                        onPressed: () {
                                                          BottomNavigationController
                                                              bottomNavigationController =
                                                              Get.find<
                                                                  BottomNavigationController>();
                                                          bottomNavigationController
                                                              .setIndex(1, 1);
                                                          Get.off(() =>
                                                              BottomNavigationBarScreen(
                                                                  index: 0));
                                                        },
                                                        child: const Text(
                                                                "Chat with Astrologer")
                                                            .tr(),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 15.0),
                                                      child: Image.asset(
                                                        "assets/images/couple_image.png",
                                                        scale: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                  bottomNavigationController
                                          .liveAstrologer.isEmpty
                                      ? const SizedBox()
                                      : SizedBox(
                                          height: 200,
                                          child: Card(
                                            elevation: 0,
                                            margin: EdgeInsets.only(top: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text('Have Doubts regarding your match??',
                                                                    style: Get
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 12))
                                                                .tr(),
                                                            Text('Connect with recommended astrologers',
                                                                    style: Get
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 10))
                                                                .tr(),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() =>
                                                                LiveAstrologerListScreen());
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
                                                                  .grey[500],
                                                            ),
                                                          ).tr(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  bottomNavigationController
                                                          .liveAstrologer
                                                          .isEmpty
                                                      ? const SizedBox()
                                                      : Expanded(
                                                          child:
                                                              ListView.builder(
                                                            itemCount:
                                                                bottomNavigationController
                                                                    .liveAstrologer
                                                                    .length,
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    left: 10),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    bottomNavigationController.anotherLiveAstrologers = bottomNavigationController
                                                                        .liveAstrologer
                                                                        .where((element) =>
                                                                            element.astrologerId !=
                                                                            bottomNavigationController.liveAstrologer[index].astrologerId)
                                                                        .toList();
                                                                    bottomNavigationController
                                                                        .update();
                                                                    await liveController.getWaitList(bottomNavigationController
                                                                        .liveAstrologer[
                                                                            index]
                                                                        .channelName);
                                                                    int index2 = liveController
                                                                        .waitList
                                                                        .indexWhere((element) =>
                                                                            element.userId ==
                                                                            global.currentUserId);
                                                                    if (index2 !=
                                                                        -1) {
                                                                      liveController
                                                                              .isImInWaitList =
                                                                          true;
                                                                      liveController
                                                                          .update();
                                                                    } else {
                                                                      liveController
                                                                              .isImInWaitList =
                                                                          false;
                                                                      liveController
                                                                          .update();
                                                                    }
                                                                    liveController
                                                                            .isImInLive =
                                                                        true;
                                                                    liveController
                                                                            .isJoinAsChat =
                                                                        false;
                                                                    liveController
                                                                            .isLeaveCalled =
                                                                        false;
                                                                    liveController
                                                                        .update();
                                                                    Get.to(
                                                                      () =>
                                                                          LiveAstrologerScreen(
                                                                        isFollow: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .isFollow!,
                                                                        token: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .token,
                                                                        channel: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .channelName,
                                                                        astrologerName: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .name,
                                                                        astrologerId: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .astrologerId,
                                                                        isFromHome:
                                                                            true,
                                                                        charge: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .charge,
                                                                        isForLiveCallAcceptDecline:
                                                                            false,
                                                                        videoCallCharge: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .videoCallRate,
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      SizedBox(
                                                                          child: Stack(
                                                                              alignment: Alignment.bottomCenter,
                                                                              children: [
                                                                        bottomNavigationController.liveAstrologer[index].profileImage != "" &&
                                                                                bottomNavigationController.liveAstrologer[index].profileImage != null
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
                                                        )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  SizedBox(
                                    height: 60,
                                  )
                                ],
                              ))
                        : (northKundaliMatchingModel!.recordList!.response ==
                                null
                            ? Center(child: Text("No Data"))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.4,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(30),
                                              bottomRight: Radius.circular(30)),
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: AssetImage(Images.sky),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                              child: Text(
                                                "Compatibility Score",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ).tr(),
                                            ),
                                            Container(
                                                height: 180,
                                                width: 230,
                                                child: SfRadialGauge(
                                                  axes: <RadialAxis>[
                                                    RadialAxis(
                                                      showLabels: false,
                                                      showAxisLine: false,
                                                      showTicks: false,
                                                      minimum: 0,
                                                      maximum: 36,
                                                      ranges: <GaugeRange>[
                                                        GaugeRange(
                                                          startValue: 0,
                                                          endValue: 12,
                                                          color:
                                                              Color(0xFFFE2A25),
                                                          label: '',
                                                          sizeUnit:
                                                              GaugeSizeUnit
                                                                  .factor,
                                                          labelStyle:
                                                              GaugeTextStyle(
                                                                  fontFamily:
                                                                      'Times',
                                                                  fontSize: 20),
                                                          startWidth: 0.50,
                                                          endWidth: 0.50,
                                                        ),
                                                        GaugeRange(
                                                          startValue: 12,
                                                          endValue: 24,
                                                          color:
                                                              Color(0xFFFFBA00),
                                                          label: '',
                                                          startWidth: 0.50,
                                                          endWidth: 0.50,
                                                          sizeUnit:
                                                              GaugeSizeUnit
                                                                  .factor,
                                                        ),
                                                        GaugeRange(
                                                          startValue: 24,
                                                          endValue: 36,
                                                          color:
                                                              Color(0xFF00AB47),
                                                          label: '',
                                                          sizeUnit:
                                                              GaugeSizeUnit
                                                                  .factor,
                                                          startWidth: 0.50,
                                                          endWidth: 0.50,
                                                        ),
                                                      ],
                                                      pointers: <GaugePointer>[
                                                        NeedlePointer(
                                                          value: northKundaliMatchingModel!
                                                                      .recordList!
                                                                      .response!
                                                                      .score !=
                                                                  null
                                                              ? double.parse(
                                                                  northKundaliMatchingModel!
                                                                      .recordList!
                                                                      .response!
                                                                      .score
                                                                      .toString())
                                                              : 0.0,
                                                          needleStartWidth: 0,
                                                          needleEndWidth: 5,
                                                          needleColor:
                                                              Color(0xFFDADADA),
                                                          enableAnimation: true,
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        leading: GestureDetector(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: Icon(
                                            Platform.isIOS
                                                ? Icons.arrow_back_ios
                                                : Icons.arrow_back,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: const Text(
                                          "Kundli Matching",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ).tr(),
                                        trailing: Container(
                                          padding: const EdgeInsets.all(3),
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Get.theme.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
                                              // String appShareLink;
                                              // // ignore: unused_local_variable
                                              // String applink;
                                              // final DynamicLinkParameters parameters = DynamicLinkParameters(
                                              //   uriPrefix: 'https://astrowaydiploy.page.link',
                                              //   link: Uri.parse("https://astrowaydiploy.page.link/userProfile?screen=astroProfile"),
                                              //   androidParameters: AndroidParameters(
                                              //     packageName: 'com.astrowaydiploy.user',
                                              //     minimumVersion: 1,
                                              //   ),
                                              // );
                                              // Uri url;
                                              // final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.short);
                                              // url = shortLink.shortUrl;
                                              // appShareLink = url.toString();
                                              // applink = appShareLink;
                                              // Get.back(); //back from dialog
                                              // final temp1 = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
                                              // screenshotController.capture().then((image) async {
                                              //   if (image != null) {
                                              //     try {
                                              //       String fileName = DateTime.now().microsecondsSinceEpoch.toString();
                                              //       final imagePath = await File('${temp1!.path}/$fileName.png').create();
                                              //       // ignore: unnecessary_null_comparison
                                              //       if (imagePath != null) {
                                              //         final temp;
                                              //         if (Platform.isIOS) {
                                              //           temp = await getApplicationDocumentsDirectory();
                                              //         } else {
                                              //           temp = await getExternalStorageDirectory();
                                              //         }
                                              //         final path = '${temp!.path}/$fileName.jpg';
                                              //         File(path).writeAsBytesSync(image);
                                              //
                                              //         await FlutterShare.shareFile(filePath: path, title: '${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)}', text: "Check out the ${global.getSystemFlagValue(global.systemFlagNameList.appName)} marriage compatibility report for ${cBoysName.text} and ${cGirlName.text}. Get your free Matchnaking report here: $appShareLink").then((value) {}).catchError((e) {
                                              //           print(e);
                                              //         });
                                              //       }
                                              //     } catch (e) {
                                              //       print('Exception in match sharing $e');
                                              //     }
                                              //   }
                                              // }).catchError((onError) {
                                              //   print('Error --->> $onError');
                                              // });
                                            },
                                            child: FittedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  FittedBox(
                                                    child: Text(
                                                      "Share",
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              fontSize: 8),
                                                    ).tr(),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 6.0),
                                                    child: FittedBox(
                                                      child: Icon(
                                                        Icons.share,
                                                        color: Colors.green,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      northKundaliMatchingModel!.recordList!
                                                  .response!.score ==
                                              null
                                          ? const SizedBox()
                                          : Positioned(
                                              bottom: -25,
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.8,
                                              child: Container(
                                                height: 50,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color:
                                                          Colors.greenAccent),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                    child: RichText(
                                                  text: TextSpan(
                                                    text:
                                                        '${northKundaliMatchingModel!.recordList!.response!.score}/',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 24),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text:
                                                            '${northKundaliMatchingModel!.recordList!.response!.botResponse.toString().split("out of")[1].substring(0, 3)}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                              ),
                                            ),
                                    ],
                                  ),
//----------------------Details-----------------------

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      children: [
                                        ///report
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 40.0,
                                          ),
                                          child: Center(
                                            child: Text(
                                                    "${northKundaliMatchingModel!.recordList!.response!.botResponse}",
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18))
                                                .tr(),
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 20.0, bottom: 20),
                                          child: Center(
                                            child: Text("Details",
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18))
                                                .tr(),
                                          ),
                                        ),
//------------------Card-------------------------------

                                        northKundaliMatchingModel!.recordList!
                                                    .response!.tara ==
                                                null
                                            ? const SizedBox()
                                            : Container(
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                    color: Color(0xfffff6f1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.tara!.name!.toUpperCase()}",
                                                              style: Theme.of(
                                                                      context)
                                                                  .primaryTextTheme
                                                                  .titleMedium,
                                                            ).tr(),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0,
                                                                      right: 5),
                                                              child: Text(
                                                                "${northKundaliMatchingModel!.recordList!.response!.tara!.description}",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ).tr(),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "Girl",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                    Text(
                                                                      "${northKundaliMatchingModel!.recordList!.response!.tara!.girlTara}",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.black),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: 50,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "Boy",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                    Text(
                                                                      "${northKundaliMatchingModel!.recordList!.response!.tara!.boyTara}",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.black),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ).tr(),
                                                                  ],
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      CircularPercentIndicator(
                                                        radius: 35.0,
                                                        lineWidth: 5.0,
                                                        percent: northKundaliMatchingModel!
                                                                .recordList!
                                                                .response!
                                                                .tara!
                                                                .tara!
                                                                .toDouble() /
                                                            northKundaliMatchingModel!
                                                                .recordList!
                                                                .response!
                                                                .tara!
                                                                .tara!
                                                                .toDouble(),
                                                        center: new Text(
                                                          "${northKundaliMatchingModel!.recordList!.response!.tara!.tara}/${northKundaliMatchingModel!.recordList!.response!.tara!.fullScore}",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xfffca47c),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ).tr(),
                                                        progressColor:
                                                            Color(0xfffca47c),
                                                      )
                                                    ],
                                                  ),
                                                )),

                                        northKundaliMatchingModel!.recordList!
                                                    .response!.gana ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffeffaf4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${northKundaliMatchingModel!.recordList!.response!.gana!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${northKundaliMatchingModel!.recordList!.response!.gana!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.gana!.girlGana}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.gana!.boyGana}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .gana!
                                                                    .gana!
                                                                    .toDouble() /
                                                                northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .gana!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.gana!.gana!}/${northKundaliMatchingModel!.recordList!.response!.gana!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xfffca47c),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xfffca47c),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        northKundaliMatchingModel!.recordList!
                                                    .response!.yoni ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffcf2fd),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${northKundaliMatchingModel!.recordList!.response!.yoni!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${northKundaliMatchingModel!.recordList!.response!.yoni!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.yoni!.girlYoni}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.yoni!.boyYoni}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .yoni!
                                                                    .yoni!
                                                                    .toDouble() /
                                                                northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .yoni!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.yoni!.yoni!}/${northKundaliMatchingModel!.recordList!.response!.yoni!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffba6ad9),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffba6ad9),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        northKundaliMatchingModel!.recordList!
                                                    .response!.bhakoot ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffeef7fe),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${northKundaliMatchingModel!.recordList!.response!.bhakoot!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${northKundaliMatchingModel!.recordList!.response!.bhakoot!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.bhakoot!.girlRasiName}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.bhakoot!.boyRasiName}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .bhakoot!
                                                                    .bhakoot!
                                                                    .toDouble() /
                                                                northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .bhakoot!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.bhakoot!.bhakoot!}/${northKundaliMatchingModel!.recordList!.response!.bhakoot!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff58a4f2),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xff58a4f2),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                        northKundaliMatchingModel!.recordList!
                                                    .response!.grahamaitri ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffff2f9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${northKundaliMatchingModel!.recordList!.response!.grahamaitri!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${northKundaliMatchingModel!.recordList!.response!.grahamaitri!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.grahamaitri!.girlLord}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.grahamaitri!.boyLord}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .grahamaitri!
                                                                    .grahamaitri!
                                                                    .toDouble() /
                                                                northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .grahamaitri!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.grahamaitri!.grahamaitri!}/${northKundaliMatchingModel!.recordList!.response!.grahamaitri!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffff84bb),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffff84bb),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        northKundaliMatchingModel!.recordList!
                                                    .response!.vasya ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffff6f1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${northKundaliMatchingModel!.recordList!.response!.vasya!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${northKundaliMatchingModel!.recordList!.response!.vasya!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.vasya!.girlVasya}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.vasya!.boyVasya}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .vasya!
                                                                    .vasya!
                                                                    .toDouble() /
                                                                northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .vasya!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.vasya!.vasya!}/${northKundaliMatchingModel!.recordList!.response!.vasya!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffffa37a),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffffa37a),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),

                                        northKundaliMatchingModel!.recordList!
                                                    .response!.nadi ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffeffaf4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${northKundaliMatchingModel!.recordList!.response!.nadi!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${northKundaliMatchingModel!.recordList!.response!.nadi!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.nadi!.girlNadi}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.nadi!.boyNadi}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .nadi!
                                                                    .nadi!
                                                                    .toDouble() /
                                                                northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .nadi!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.nadi!.nadi!}/${northKundaliMatchingModel!.recordList!.response!.nadi!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                    (0xff70ce99),
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                              (0xff70ce99),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                        //
                                        northKundaliMatchingModel!.recordList!
                                                    .response!.varna ==
                                                null
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xfffcf2fd),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${northKundaliMatchingModel!.recordList!.response!.varna!.name!.toUpperCase()}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .titleMedium,
                                                                ).tr(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0,
                                                                          right:
                                                                              5),
                                                                  child: Text(
                                                                    "${northKundaliMatchingModel!.recordList!.response!.varna!.description}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                  ).tr(),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Girl",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.varna!.girlVarna}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Boy",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                        Text(
                                                                          "${northKundaliMatchingModel!.recordList!.response!.varna!.boyVarna}",
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black),
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                        ).tr(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          CircularPercentIndicator(
                                                            radius: 35.0,
                                                            lineWidth: 5.0,
                                                            percent: northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .varna!
                                                                    .varna!
                                                                    .toDouble() /
                                                                northKundaliMatchingModel!
                                                                    .recordList!
                                                                    .response!
                                                                    .varna!
                                                                    .fullScore!
                                                                    .toDouble(),
                                                            center: new Text(
                                                              "${northKundaliMatchingModel!.recordList!.response!.varna!.varna!}/${northKundaliMatchingModel!.recordList!.response!.varna!.fullScore!}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffbb6bda),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ).tr(),
                                                            progressColor:
                                                                Color(
                                                                    0xffbb6bda),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ),
//----------------------------------Manglik Report-------------------------------------

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Text(
                                            "Manglik Report",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .titleMedium,
                                          ).tr(),
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  height: 70,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width:
                                                          3, /*strokeAlign: StrokeAlign.outside*/
                                                    ),
                                                    color:
                                                        Get.theme.primaryColor,
                                                    image:
                                                        const DecorationImage(
                                                      image: AssetImage(
                                                        "assets/images/no_customer_image.png",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    '${kundliMatchingController.cBoysName.text}',
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium,
                                                  ).tr(),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 9.0),
                                                  child: Text(
                                                    '${northKundaliMatchingModel!.boyManaglikRpt!.response!.botResponse}',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: northKundaliMatchingModel!
                                                                    .boyManaglikRpt!
                                                                    .response!
                                                                    .score! >
                                                                50
                                                            ? Colors.green
                                                            : Colors.red),
                                                  ).tr(),
                                                ),
                                              ],
                                            ),
                                            Image.asset(
                                              "assets/images/couple_ring_image.png",
                                              scale: 8,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  height: 70,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width:
                                                          3, /* strokeAlign: StrokeAlign.outside*/
                                                    ),
                                                    color:
                                                        Get.theme.primaryColor,
                                                    image:
                                                        const DecorationImage(
                                                      image: AssetImage(
                                                        "assets/images/no_customer_image.png",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    '${kundliMatchingController.cGirlName.text}',
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium,
                                                  ).tr(),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 9.0),
                                                  child: Text(
                                                    '${northKundaliMatchingModel!.girlMangalikRpt!.response!.botResponse}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: northKundaliMatchingModel!
                                                                  .girlMangalikRpt!
                                                                  .response!
                                                                  .score! >
                                                              50
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ).tr(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
//--------------------------Conclusion-------------------------------------
                                        northKundaliMatchingModel!.recordList!
                                                    .response!.score ==
                                                null
                                            ? const SizedBox()
                                            : Container(
                                                padding: const EdgeInsets.only(
                                                    top: 8,
                                                    left: 8.0,
                                                    right: 8.0),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Get
                                                          .theme.primaryColor),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Get.theme.primaryColor,
                                                      Colors.white,
                                                    ],
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)} Conclusion",
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ).tr(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0),
                                                      child: Text(
                                                        'The overall points of this couple ${northKundaliMatchingModel!.recordList!.response!.score}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                      ).tr(),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 9.0),
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                      .white),
                                                          foregroundColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                      .black),
                                                          shape: WidgetStateProperty.all(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50))),
                                                        ),
                                                        onPressed: () {
                                                          BottomNavigationController
                                                              bottomNavigationController =
                                                              Get.find<
                                                                  BottomNavigationController>();
                                                          bottomNavigationController
                                                              .setIndex(1, 1);
                                                          Get.off(() =>
                                                              BottomNavigationBarScreen(
                                                                  index: 0));
                                                        },
                                                        child: const Text(
                                                                "Chat with Astrologer")
                                                            .tr(),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 15.0),
                                                      child: Image.asset(
                                                        "assets/images/couple_image.png",
                                                        scale: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                  bottomNavigationController
                                          .liveAstrologer.isEmpty
                                      ? const SizedBox()
                                      : SizedBox(
                                          height: 200,
                                          child: Card(
                                            elevation: 0,
                                            margin: EdgeInsets.only(top: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text('Have Doubts regarding your match??',
                                                                    style: Get
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 12))
                                                                .tr(),
                                                            Text('Connect with recommended astrologers',
                                                                    style: Get
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 10))
                                                                .tr(),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() =>
                                                                LiveAstrologerListScreen());
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
                                                                  .grey[500],
                                                            ),
                                                          ).tr(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  bottomNavigationController
                                                          .liveAstrologer
                                                          .isEmpty
                                                      ? const SizedBox()
                                                      : Expanded(
                                                          child:
                                                              ListView.builder(
                                                            itemCount:
                                                                bottomNavigationController
                                                                    .liveAstrologer
                                                                    .length,
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    left: 10),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    bottomNavigationController.anotherLiveAstrologers = bottomNavigationController
                                                                        .liveAstrologer
                                                                        .where((element) =>
                                                                            element.astrologerId !=
                                                                            bottomNavigationController.liveAstrologer[index].astrologerId)
                                                                        .toList();
                                                                    bottomNavigationController
                                                                        .update();
                                                                    await liveController.getWaitList(bottomNavigationController
                                                                        .liveAstrologer[
                                                                            index]
                                                                        .channelName);
                                                                    int index2 = liveController
                                                                        .waitList
                                                                        .indexWhere((element) =>
                                                                            element.userId ==
                                                                            global.currentUserId);
                                                                    if (index2 !=
                                                                        -1) {
                                                                      liveController
                                                                              .isImInWaitList =
                                                                          true;
                                                                      liveController
                                                                          .update();
                                                                    } else {
                                                                      liveController
                                                                              .isImInWaitList =
                                                                          false;
                                                                      liveController
                                                                          .update();
                                                                    }
                                                                    liveController
                                                                            .isImInLive =
                                                                        true;
                                                                    liveController
                                                                            .isJoinAsChat =
                                                                        false;
                                                                    liveController
                                                                            .isLeaveCalled =
                                                                        false;
                                                                    liveController
                                                                        .update();
                                                                    Get.to(
                                                                      () =>
                                                                          LiveAstrologerScreen(
                                                                        isFollow: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .isFollow!,
                                                                        token: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .token,
                                                                        channel: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .channelName,
                                                                        astrologerName: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .name,
                                                                        astrologerId: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .astrologerId,
                                                                        isFromHome:
                                                                            true,
                                                                        charge: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .charge,
                                                                        isForLiveCallAcceptDecline:
                                                                            false,
                                                                        videoCallCharge: bottomNavigationController
                                                                            .liveAstrologer[index]
                                                                            .videoCallRate,
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      SizedBox(
                                                                          child: Stack(
                                                                              alignment: Alignment.bottomCenter,
                                                                              children: [
                                                                        bottomNavigationController.liveAstrologer[index].profileImage != "" &&
                                                                                bottomNavigationController.liveAstrologer[index].profileImage != null
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
                                                        )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  SizedBox(
                                    height: 60,
                                  )
                                ],
                              )))
                    : Center(
                        child: Text("No Mathcing Found"),
                      ),
          );
        }),
      ),
    );
  }
}
