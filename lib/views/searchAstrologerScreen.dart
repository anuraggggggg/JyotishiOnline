// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/search_controller.dart';
import 'package:AstrowayCustomer/utils/AppColors.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/astromall/astromallScreen.dart';
import 'package:AstrowayCustomer/views/astromall/productDetailScreen.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:AstrowayCustomer/views/callIntakeFormScreen.dart';
import 'package:AstrowayCustomer/views/liveAstrologerList.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
import 'package:AstrowayCustomer/widget/popular_search_widget.dart';
import 'package:AstrowayCustomer/widget/topServicesWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import 'package:responsive_sizer/responsive_sizer.dart';
import '../controllers/chatController.dart';
import '../controllers/reviewController.dart';
import '../controllers/walletController.dart';
import 'astrologerProfile/astrologerProfile.dart';

class SearchAstrologerScreen extends StatelessWidget {
  final String type;
  SearchAstrologerScreen({Key? key, this.type = 'Chat'}) : super(key: key);
  final ChatController chatController = ChatController();
  WalletController walletController = Get.find<WalletController>();
  BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();
  CallController callController = Get.find<CallController>();
  SearchControllerCustom searchControllerr = Get.find<SearchControllerCustom>();
  HistoryController historyController = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SearchControllerCustom searchController =
            Get.find<SearchControllerCustom>();
        searchController.serachTextController.clear();
        searchController.searchText = "";
        searchController.update();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Container(
            alignment: Alignment.bottomCenter,
            height: 10.h,
            margin: EdgeInsets.only(top: 2.h),
            child: AppBar(
              elevation: 1,
              surfaceTintColor: Colors.white,
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  SearchControllerCustom searchController =
                      Get.find<SearchControllerCustom>();
                  searchController.serachTextController.clear();
                  searchController.searchText = "";
                  searchController.update();
                  Get.back();
                },
                child: Container(
                  height: 6.h,
                  width: 8.w,
                  child: Icon(
                   kIsWeb? Icons.arrow_back:   Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
              title: GetBuilder<SearchControllerCustom>(
                  builder: (searchController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 0.1.w),
                  ),
                  width: 86.w,
                  height: 6.h,
                  child: Center(
                    child: TextField(
                      controller: searchController.serachTextController,
                      onSubmitted: (value)async{
                        searchController.searchFnode.unfocus();
                        // global.showOnlyLoaderDialog(context);
                        searchController.astrologerList.clear();
                        searchController.astroProduct.clear();
                        searchController.isAllDataLoaded = false;
                        searchController.isAllDataLoadedForAstromall =
                        false;
                        searchController.searchString = searchController.serachTextController.text;
                        log("searchASTRO");
                        log("${searchController.searchString==""}");
                        searchController.update();
                        await searchController.getSearchResult(
                            searchController.serachTextController.text, null, false);
                        searchController.update();
                      },
                      onChanged: (value) async {

                        if(value.length==0)
                          {
                            searchController.astrologerList.clear();
                            searchController.astroProduct.clear();
                          }
                      },
                      focusNode: searchControllerr.searchFnode,
                      decoration: InputDecoration(
                        hintText: tr("Search astrologers, astromall products"),
                        hintStyle: TextStyle(fontSize: 16.sp),
                        labelStyle: TextStyle(fontSize: 16.sp),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none),
                        suffixIcon:InkWell(
                          onTap: ()async{
                            searchController.searchFnode.unfocus();
                            // global.showOnlyLoaderDialog(context);
                            searchController.astrologerList.clear();
                            searchController.astroProduct.clear();
                            searchController.isAllDataLoaded = false;
                            searchController.isAllDataLoadedForAstromall =
                            false;
                             searchController.searchString = searchController.serachTextController.text;
                             log("searchASTRO");
                            log("${searchController.searchString==""}");
                             searchController.update();
                            await searchController.getSearchResult(
                                searchController.serachTextController.text, null, false);
                            searchController.update();
                          },
                          child: Icon(Icons.search),
                        )
                      ),
                    ),
                  ),
                );
              }),
              actions: [
                Icon(
                  Icons.settings,
                  color: Colors.white,
                ), // Replace with your desired icon
              ],
            ),
          ),
        ),
        body: GetBuilder<SearchControllerCustom>(builder: (searchController) {
          return searchController.serachTextController.text == ""
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text('Top Services').tr(),
                        SizedBox(
                          height: 8,
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TopServicesWidget(
                                  icon: Icons.phone,
                                  color: Color.fromARGB(255, 212, 228, 241),
                                  text: 'Call',
                                  onTap: () {
                                    BottomNavigationController
                                        bottomNavigationController =
                                        Get.find<BottomNavigationController>();
                                    bottomNavigationController.setIndex(3, 0);
                                    Get.to(() => BottomNavigationBarScreen(
                                          index: 3,
                                        ));
                                  },
                                ),
                                TopServicesWidget(
                                  icon: Icons.chat,
                                  color: Color.fromARGB(255, 238, 221, 236),
                                  text: 'Chat',
                                  onTap: () {
                                    BottomNavigationController
                                        bottomNavigationController =
                                        Get.find<BottomNavigationController>();
                                    bottomNavigationController.setIndex(1, 0);
                                    Get.to(() => BottomNavigationBarScreen(
                                          index: 1,
                                        ));
                                  },
                                ),
                                TopServicesWidget(
                                  icon: Icons.live_tv,
                                  color: Color.fromARGB(255, 235, 236, 221),
                                  text: 'Live',
                                  onTap: () {
                                    Get.to(() => LiveAstrologerListScreen());
                                  },
                                ),
                                TopServicesWidget(
                                    icon: Icons.shopping_bag,
                                    color: Color.fromARGB(255, 223, 240, 221),
                                    text: 'Shopping',
                                    onTap: () {
                                      Get.to(() => AstromallScreen());
                                    })
                              ]),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        // Text('Quick Link').tr(),
                        // SizedBox(
                        //   height: 5,
                        // ),
                        // Container(
                        //   height: 15.h,
                        //   child: SingleChildScrollView(
                        //     scrollDirection: Axis.horizontal,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         QuickLinnkWidget(
                        //           text: 'Wallet',
                        //           image: Images.wallet,
                        //           onTap: () async {
                        //             bool isLogin = await global.isLogin();
                        //             if (isLogin) {
                        //               historyController.paymentAllDataLoaded =
                        //                   false;
                        //               historyController.walletTransactionList
                        //                   .clear();
                        //               historyController.walletAllDataLoaded =
                        //                   false;
                        //               historyController.update();
                        //               await historyController.getPaymentLogs(
                        //                   global.currentUserId!, false);
                        //               await historyController
                        //                   .getWalletTransaction(
                        //                       global.currentUserId!, false);
                        //               BottomNavigationController
                        //                   bottomNavigationController = Get.find<
                        //                       BottomNavigationController>();
                        //               bottomNavigationController.setIndex(4, 0);
                        //               callController.setTabIndex(0);
                        //               Get.to(() =>
                        //                   BottomNavigationBarScreen(index: 4));
                        //             }
                        //           },
                        //         ),
                        //         QuickLinnkWidget(
                        //           text: 'Support',
                        //           image: Images.customerService,
                        //           onTap: () async {
                        //             bool isLogin = await global.isLogin();
                        //             if (isLogin) {
                        //               CustomerSupportController
                        //                   customerSupportController =
                        //                   Get.find<CustomerSupportController>();
                        //               AstrologerAssistantController
                        //                   astrologerAssistantController =
                        //                   Get.find<
                        //                       AstrologerAssistantController>();
                        //               global.showOnlyLoaderDialog(context);
                        //               await customerSupportController
                        //                   .getCustomerTickets();
                        //               await astrologerAssistantController
                        //                   .getChatWithAstrologerAssisteant();
                        //               global.hideLoader();
                        //               Get.to(() => CustomerSupportChat());
                        //             }
                        //           },
                        //         ),
                        //         QuickLinnkWidget(
                        //           text: 'Order History',
                        //           image: Images.shopBag,
                        //           onTap: () async {
                        //             bool isLogin = await global.isLogin();
                        //             if (isLogin) {
                        //               historyController.callHistoryList = [];
                        //               historyController.callHistoryList.clear();
                        //               historyController.callAllDataLoaded =
                        //                   false;
                        //               historyController.update();
                        //               await historyController.getCallHistory(
                        //                   global.currentUserId!, false);
                        //               BottomNavigationController
                        //                   bottomNavigationController = Get.find<
                        //                       BottomNavigationController>();
                        //               bottomNavigationController.setIndex(4, 1);
                        //               callController.setTabIndex(1);
                        //               Get.to(() =>
                        //                   BottomNavigationBarScreen(index: 4));
                        //             }
                        //           },
                        //         ),
                        //         QuickLinnkWidget(
                        //           text: 'Profile',
                        //           image: Images.userProfile,
                        //           onTap: () async {
                        //             bool isLogin = await global.isLogin();
                        //             if (isLogin) {
                        //               SplashController splashController =
                        //                   Get.find<SplashController>();
                        //               global.showOnlyLoaderDialog(context);
                        //               await splashController
                        //                   .getCurrentUserData();
                        //               global.hideLoader();
                        //               Get.to(() => EditUserProfile());
                        //             }
                        //           },
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: searchController.searchData.length,
                          itemBuilder: (context, index) {
                            return GetBuilder<SearchControllerCustom>(
                                builder: (c) {
                              return GestureDetector(
                                onTap: () {
                                  global.showOnlyLoaderDialog(context);
                                  searchController.selectSearchTab(index);
                                  searchController.astrologerList.clear();
                                  searchController.astroProduct.clear();
                                  searchController.isAllDataLoaded = false;
                                  searchController.isAllDataLoadedForAstromall =
                                      false;
                                  searchController.searchString =
                                      searchController.searchText;
                                  searchController.update();
                                  searchController.getSearchResult(
                                      searchController.searchText, null, false);
                                  global.hideLoader();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(top: 10),
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                        color: searchController
                                                .searchData[index].isSelected
                                            ? Color.fromARGB(255, 247, 243, 213)
                                            : Colors.transparent,
                                        border: Border.all(
                                            color: searchController
                                                    .searchData[index]
                                                    .isSelected
                                                ? Get.theme.primaryColor
                                                : Colors.black),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                              searchController
                                                  .searchData[index].title,
                                              style: TextStyle(fontSize: 13))
                                          .tr()),
                                ),
                              );
                            });
                          }),
                    ),
                    searchController.searchTabIndex == 0
                        ? Expanded(
                            child: searchController.astrologerList.isEmpty
                                ? searchResultNotFound()
                                : ListView.builder(
                                    itemCount:
                                        searchController.astrologerList.length,
                                    shrinkWrap: true,
                                    controller:
                                        searchController.searchScrollController,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () async {
                                          Get.find<ReviewController>()
                                              .getReviewData(searchController
                                                  .astrologerList[index].id!);
                                          global.showOnlyLoaderDialog(context);
                                          await bottomNavigationController
                                              .getAstrologerbyId(
                                                  searchController
                                                      .astrologerList[index]
                                                      .id!);
                                          global.hideLoader();
                                          Get.to(() => AstrologerProfile(
                                                index: index,
                                              ));
                                        },
                                        child: Column(
                                          children: [
                                            Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            // Padding(
                                                            //   padding:
                                                            //       const EdgeInsets
                                                            //           .only(
                                                            //           top: 10),
                                                            //   child: Container(
                                                            //     height: 65,
                                                            //     width: 65,
                                                            //     decoration:
                                                            //         BoxDecoration(
                                                            //       border: Border.all(
                                                            //           color: Get
                                                            //               .theme
                                                            //               .primaryColor),
                                                            //       borderRadius:
                                                            //           BorderRadius
                                                            //               .circular(
                                                            //                   7),
                                                            //     ),
                                                            //     child:
                                                            //         CircleAvatar(
                                                            //       radius: 36,
                                                            //       backgroundColor: Get
                                                            //           .theme
                                                            //           .primaryColor,
                                                            //       child:
                                                            //           CircleAvatar(
                                                            //         radius: 35,
                                                            //         backgroundColor:
                                                            //             Colors
                                                            //                 .white,
                                                            //         child:
                                                            //             CachedNetworkImage(
                                                            //           height:
                                                            //               55,
                                                            //           width: 55,
                                                            //           imageUrl:
                                                            //               '${global.imgBaseurl}${searchController.astrologerList[index].profileImage}',
                                                            //           placeholder: (context,
                                                            //                   url) =>
                                                            //               const Center(
                                                            //                   child: CircularProgressIndicator()),
                                                            //           errorWidget: (context,
                                                            //                   url,
                                                            //                   error) =>
                                                            //               Image
                                                            //                   .asset(
                                                            //             Images
                                                            //                 .deafultUser,
                                                            //             fit: BoxFit
                                                            //                 .cover,
                                                            //             height:
                                                            //                 50,
                                                            //             width:
                                                            //                 40,
                                                            //           ),
                                                            //         ),
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            Container(
                                                              height: 14.h,
                                                              width: 12.h,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                BorderRadius.circular(2.w),
                                                                child: CachedNetworkImage(
                                                                  height: 14.h,
                                                                  width: 12.h,
                                                                  fit: BoxFit.cover,
                                                                  imageUrl:
                                                                  '${global.imgBaseurl}${searchController.astrologerList[index].profileImage}',
                                                                  placeholder: (context, url) =>
                                                                  const Center(
                                                                      child:
                                                                      CircularProgressIndicator()),
                                                                  errorWidget: (context, url, error) =>
                                                                      Image.asset(
                                                                        Images.deafultUser,
                                                                        fit: BoxFit.cover,
                                                                        height: 14.h,
                                                                        width: 12.h,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 1.w,
                                                              right: 1.w,
                                                              left: 1.w,
                                                              child: Container(
                                                                width: 12.h,
                                                                height: 3.5.h,
                                                                decoration: BoxDecoration(
                                                                  color: getRandomColor(index),
                                                                  borderRadius:
                                                                  BorderRadius.circular(1.w),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    searchController.astrologerList[index]
                                                                        .allSkill!
                                                                        .split(',')[0],
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 14.sp,
                                                                        fontWeight: FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ),
                                                            )

                                                          ],
                                                        ),

                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  searchController
                                                                      .astrologerList[
                                                                          index]
                                                                      .name!,
                                                                ).tr(),
                                                                SizedBox(width:1.w),
                                                                Image.asset(
                                                                  Images.right,
                                                                  height: 18,
                                                                ),
                                                              ],
                                                            ),
                                                            searchController
                                                                        .astrologerList[
                                                                            index]
                                                                        .allSkill ==
                                                                    ""
                                                                ? const SizedBox()
                                                                : Text(
                                                                    searchController
                                                                            .astrologerList[index]
                                                                            .allSkill ??
                                                                        "",
                                                                    style: Get
                                                                        .theme
                                                                        .primaryTextTheme
                                                                        .bodySmall!
                                                                        .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                    ),
                                                                  ).tr(),
                                                            searchController
                                                                        .astrologerList[
                                                                            index]
                                                                        .languageKnown ==
                                                                    ""
                                                                ? const SizedBox()
                                                                : Text(
                                                                    searchController
                                                                        .astrologerList[
                                                                            index]
                                                                        .languageKnown!,
                                                                    style: Get
                                                                        .theme
                                                                        .primaryTextTheme
                                                                        .bodySmall!
                                                                        .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                    ),
                                                                  ).tr(),
                                                            Text(
                                                              'Experience  : ${searchController.astrologerList[index].experienceInYears}',
                                                              style: Get
                                                                  .theme
                                                                  .primaryTextTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ).tr(),
                                                            type == 'Chat'?SizedBox():  Row(
                                                              children: [
                                                                searchController
                                                                            .astrologerList[index]
                                                                            .isFreeAvailable ==
                                                                        true
                                                                    ? Text(
                                                                        'FREE',
                                                                        style: Get
                                                                            .theme
                                                                            .textTheme
                                                                            .titleMedium!
                                                                            .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          letterSpacing:
                                                                              0,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              167,
                                                                              1,
                                                                              1),
                                                                        ),
                                                                      ).tr()
                                                                    : const SizedBox(),
                                                                SizedBox(
                                                                  width: searchController
                                                                              .astrologerList[index]
                                                                              .isFreeAvailable ==
                                                                          true
                                                                      ? 10
                                                                      : 0,
                                                                ),
                                                                Text(
                                                                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${searchController.astrologerList[index].charge}/min',
                                                                  style: Get
                                                                      .theme
                                                                      .textTheme
                                                                      .titleMedium!
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    decoration: searchController.astrologerList[index].isFreeAvailable ==
                                                                            true
                                                                        ? TextDecoration
                                                                            .lineThrough
                                                                        : null,
                                                                    color: searchController.astrologerList[index].isFreeAvailable ==
                                                                            true
                                                                        ? Colors
                                                                            .grey
                                                                        : Color.fromARGB(
                                                                            255,
                                                                            167,
                                                                            1,
                                                                            1),
                                                                    letterSpacing:
                                                                        0,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        type == 'Chat'
                                                            ? TextButton(
                                                                style:
                                                                    ButtonStyle(
                                                                  padding: MaterialStateProperty.all(
                                                                      EdgeInsets
                                                                          .all(
                                                                              0)),
                                                                  fixedSize: MaterialStateProperty
                                                                      .all(Size
                                                                          .fromWidth(
                                                                              90)),
                                                                  backgroundColor: searchController
                                                                              .astrologerList[
                                                                                  index]
                                                                              .chatStatus ==
                                                                          "Online"
                                                                      ? MaterialStateProperty.all(
                                                                          Colors
                                                                              .lightBlue)
                                                                      :  MaterialStateProperty.all(
                                                                              Colors.orangeAccent),
                                                                  shape:
                                                                      MaterialStateProperty
                                                                          .all(
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  bool isLogin =
                                                                      await global
                                                                          .isLogin();
                                                                  if (isLogin) {
                                                                    if (type ==
                                                                        'Chat') {
                                                                      double charge = searchController.astrologerList[index].charge !=
                                                                              null
                                                                          ? double.parse(searchController
                                                                              .astrologerList[index]
                                                                              .charge
                                                                              .toString())
                                                                          : 0;
                                                                      if (charge * 5 <=
                                                                              global
                                                                                  .splashController.currentUser!.walletAmount! ||
                                                                          searchController.astrologerList[index].isFreeAvailable ==
                                                                              true) {
                                                                        await bottomNavigationController.checkAlreadyInReq(searchController
                                                                            .astrologerList[index]
                                                                            .id!);
                                                                        if (bottomNavigationController.isUserAlreadyInChatReq ==
                                                                            false) {
                                                                          if (searchController.astrologerList[index].chatStatus == "Online" ) {
                                                                            global.showOnlyLoaderDialog(context);

                                                                            if (searchController.astrologerList[index].chatWaitTime !=
                                                                                null) {
                                                                              if (searchController.astrologerList[index].chatWaitTime!.difference(DateTime.now()).inMinutes < 0) {
                                                                                await bottomNavigationController.changeOfflineStatus(searchController.astrologerList[index].id, "Online");
                                                                              }
                                                                            }
                                                                            await Get.to(() =>
                                                                                CallIntakeFormScreen(
                                                                                  type: type,
                                                                                  // index: index,
                                                                                  astrologerId: searchController.astrologerList[index].id!,
                                                                                  astrologerName: searchController.astrologerList[index].name!,
                                                                                  astrologerProfile: searchController.astrologerList[index].profileImage!,
                                                                                  isFreeAvailable: searchController.astrologerList[index].isFreeAvailable!,
                                                                                  rate: searchController.astrologerList[index].charge.toString()!,
                                                                                ));
                                                                            global.hideLoader();
                                                                          } else if (searchController.astrologerList[index].chatStatus ==
                                                                              "Offline"||
                                                                              searchController.astrologerList[index].chatStatus ==
                                                                                  "Wait Time"||
                                                                              searchController.astrologerList[index].chatStatus ==
                                                                                  "Busy") {
                                                                            bottomNavigationController.dialogForJoinInWaitList(
                                                                                context,
                                                                                searchController.astrologerList[index].name??"Astro",
                                                                                true,
                                                                                bottomNavigationController
                                                                                    .astrologerbyId[0].chatStatus.toString(),
                                                                                searchController.astrologerList[index].profileImage??""
                                                                            );
                                                                          }
                                                                        } else {
                                                                          bottomNavigationController
                                                                              .dialogForNotCreatingSession(context);
                                                                        }
                                                                      } else {
                                                                        global.showOnlyLoaderDialog(
                                                                            context);
                                                                        await walletController
                                                                            .getAmount();
                                                                        global
                                                                            .hideLoader();
                                                                        openBottomSheetRechrage(
                                                                            context,
                                                                            (charge * 5).toString(),
                                                                            'chat',
                                                                            '${searchController.astrologerList[index].name!}');
                                                                      }
                                                                    }
                                                                  }
                                                                },
                                                                child: searchController
                                                                    .astrologerList[index]
                                                                    .isFreeAvailable ==
                                                                    true
                                                                    ? Text(
                                                                  'FREE',
                                                                  style: Get
                                                                      .theme
                                                                      .textTheme
                                                                      .titleMedium!
                                                                      .copyWith(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight:
                                                                    FontWeight.w500,
                                                                    letterSpacing:
                                                                    0,
                                                                    color: Color.fromARGB(
                                                                        255,
                                                                        167,
                                                                        1,
                                                                        1),
                                                                  ),
                                                                ).tr()
                                                                    : Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                        Icon(CupertinoIcons.chat_bubble_fill,
                                                                          size:15,
                                                                          color: Colors.white,),
                                                                        Text(
                                                                          '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${searchController.astrologerList[index].charge}/min',
                                                                           style: Get
                                                                          .theme
                                                                          .primaryTextTheme
                                                                          .bodySmall!
                                                                          .copyWith(
                                                                              color:
                                                                                  Colors.white),
                                                                         ).tr(),
                                                                      ],
                                                                    ),
                                                              )
                                                            : SizedBox(
                                                                height: 80,
                                                                width: 80,
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                GetBuilder<CallController>(
                                                                              builder: (CallController controller) => InkWell(
                                                                                onTap: () async {
                                                                                  bool isLogin = await global.isLogin();
                                                                                  if (isLogin) {
                                                                                    if (type == 'Call') {
                                                                                      double charge = searchController.astrologerList[index].charge != null ? double.parse(searchController.astrologerList[index].charge.toString()) : 0;
                                                                                      if (charge * 5 <= global.splashController.currentUser!.walletAmount! || searchController.astrologerList[index].isFreeAvailable == true) {
                                                                                        await bottomNavigationController.checkAlreadyInReqForCall(searchController.astrologerList[index].id!);
                                                                                        if (bottomNavigationController.isUserAlreadyInCallReq == false) {
                                                                                          if (searchController.astrologerList[index].callStatus == "Online" ) {
                                                                                            global.showOnlyLoaderDialog(context);
                                                                                            if (searchController.astrologerList[index].callWaitTime != null) {
                                                                                              if (searchController.astrologerList[index].callWaitTime!.difference(DateTime.now()).inMinutes < 0) {
                                                                                                await bottomNavigationController.changeOfflineCallStatus(searchController.astrologerList[index].id, "Online");
                                                                                              }
                                                                                            }
                                                                                            await Get.to(() => CallIntakeFormScreen(
                                                                                                  astrologerProfile: searchController.astrologerList[index].profileImage ?? '',
                                                                                                  type: "Call",
                                                                                                  astrologerId: searchController.astrologerList[index].id!,
                                                                                                  astrologerName: searchController.astrologerList[index].name ?? '',
                                                                                                  isFreeAvailable: searchController.astrologerList[index].isFreeAvailable!,
                                                                                              rate:searchController.astrologerList[index].charge!.toString() ,
                                                                                                ));

                                                                                            global.hideLoader();
                                                                                          } else if (searchController.astrologerList[index].callStatus == "Offline"|| searchController.astrologerList[index].callStatus == "Wait Time" || searchController.astrologerList[index].callStatus == "Busy") {
                                                                                            bottomNavigationController.dialogForJoinInWaitList(
                                                                                                context,
                                                                                                searchController.astrologerList[index].name??"Astro",
                                                                                                true,
                                                                                                bottomNavigationController
                                                                                                    .astrologerbyId[0].callStatus.toString(),
                                                                                                searchController.astrologerList[index].profileImage??""
                                                                                            );
                                                                                          }
                                                                                        } else {
                                                                                          bottomNavigationController.dialogForNotCreatingSession(context);
                                                                                        }
                                                                                      } else {
                                                                                        global.showOnlyLoaderDialog(context);
                                                                                        await walletController.getAmount();
                                                                                        global.hideLoader();
                                                                                        openBottomSheetRechrage(context, (charge * 5).toString(), 'call', '${searchController.astrologerList[index].name!}');
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                },
                                                                                child: CircleAvatar(
                                                                                  radius: 18,
                                                                                  backgroundColor: searchController.astrologerList[index].callStatus == "Online" ? Colors.green : Colors.orangeAccent,
                                                                                  child: Center(
                                                                                    child: Icon(
                                                                                      Icons.call,
                                                                                      color: Colors.white,
                                                                                      size: 15,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                GetBuilder<CallController>(
                                                                              builder: (CallController controller) => InkWell(
                                                                                onTap: () async {
                                                                                  bool isLogin = await global.isLogin();
                                                                                  if (isLogin) {
                                                                                    if (type == 'Call') {
                                                                                      double charge = searchController.astrologerList[index].videoCallRate != null ? double.parse(searchController.astrologerList[index].videoCallRate.toString()) : 0;
                                                                                      if (charge * 5 <= global.splashController.currentUser!.walletAmount! || searchController.astrologerList[index].isFreeAvailable == true) {
                                                                                        await bottomNavigationController.checkAlreadyInReqForCall(searchController.astrologerList[index].id!);
                                                                                        if (bottomNavigationController.isUserAlreadyInCallReq == false) {
                                                                                          if (searchController.astrologerList[index].callStatus == "Online") {
                                                                                            global.showOnlyLoaderDialog(context);
                                                                                            if (searchController.astrologerList[index].callWaitTime != null) {
                                                                                              if (searchController.astrologerList[index].callWaitTime!.difference(DateTime.now()).inMinutes < 0) {
                                                                                                await bottomNavigationController.changeOfflineCallStatus(searchController.astrologerList[index].id, "Online");
                                                                                              }
                                                                                            }
                                                                                            await Get.to(() => CallIntakeFormScreen(
                                                                                                  astrologerProfile: searchController.astrologerList[index].profileImage ?? '',
                                                                                                  type: "Videocall",
                                                                                                  astrologerId: searchController.astrologerList[index].id!,
                                                                                                  astrologerName: searchController.astrologerList[index].name ?? '',
                                                                                                  isFreeAvailable: searchController.astrologerList[index].isFreeAvailable!,
                                                                                              rate: searchController.astrologerList[index].videoCallRate.toString()!,
                                                                                                ));

                                                                                            global.hideLoader();
                                                                                          } else if (searchController.astrologerList[index].callStatus == "Offline" || searchController.astrologerList[index].callStatus == "Busy" || searchController.astrologerList[index].callStatus == "Wait Time") {
                                                                                            bottomNavigationController.dialogForJoinInWaitList(
                                                                                                context,
                                                                                                searchController.astrologerList[index].name??"Astro",
                                                                                                true,
                                                                                                bottomNavigationController
                                                                                                    .astrologerbyId[0].callStatus.toString(),
                                                                                                searchController.astrologerList[index].profileImage??""
                                                                                            );
                                                                                          }
                                                                                        } else {
                                                                                          bottomNavigationController.dialogForNotCreatingSession(context);
                                                                                        }
                                                                                      } else {
                                                                                        global.showOnlyLoaderDialog(context);
                                                                                        await walletController.getAmount();
                                                                                        global.hideLoader();
                                                                                        openBottomSheetRechrage(context, (charge * 5).toString(), 'call', '${searchController.astrologerList[index].name!}');
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                },
                                                                                child: CircleAvatar(
                                                                                  radius: 18,
                                                                                  backgroundColor: searchController.astrologerList[index].callStatus == "Online" ? Colors.redAccent : Colors.orangeAccent,
                                                                                  child: Center(
                                                                                    child: Icon(
                                                                                      Icons.video_call,
                                                                                      color: Colors.white,
                                                                                      size: 15,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ]),
                                                              ),
                                                        type == "Chat"
                                                            ? (searchController
                                                                        .astrologerList[
                                                                            index]
                                                                        .chatStatus ==
                                                                    "Offline"
                                                                ? (Text(
                                                                    "Currently Offline",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            09),
                                                                  ).tr())
                                                                : searchController
                                                                            .astrologerList[
                                                                                index]
                                                                            .chatStatus ==
                                                                        "Wait Time"
                                                                    ? (Text(
                                                                        searchController.astrologerList[index].chatWaitTime!.difference(DateTime.now()).inMinutes >
                                                                                0
                                                                            ? "Wait till - ${searchController.astrologerList[index].chatWaitTime!.difference(DateTime.now()).inMinutes} min"
                                                                            : "Wait till",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: 09),
                                                                      )
                                                                        .tr())
                                                                    : searchController.astrologerList[index].chatStatus ==
                                                                            "Busy"
                                                                        ? Text(
                                                                            "Currently Busy",
                                                                            style:
                                                                                TextStyle(color: Colors.red, fontSize: 09),
                                                                          )
                                                                            .tr()
                                                                        : SizedBox())
                                                            : searchController
                                                                        .astrologerList[
                                                                            index]
                                                                        .callStatus ==
                                                                    "Offline"
                                                                ? (Text(
                                                                    "Currently Offline",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            09),
                                                                  ).tr())
                                                                : searchController
                                                                            .astrologerList[
                                                                                index]
                                                                            .callStatus ==
                                                                        "Wait Time"
                                                                    ? (Text(
                                                                        searchController.astrologerList[index].callWaitTime!.difference(DateTime.now()).inMinutes >
                                                                                0
                                                                            ? "Wait till - ${searchController.astrologerList[index].callWaitTime!.difference(DateTime.now()).inMinutes} min"
                                                                            : "Wait till",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: 09),
                                                                      )
                                                                        .tr())
                                                                    : searchController.astrologerList[index].callStatus ==
                                                                            "Busy"
                                                                        ? Text(
                                                                            "Currently Busy",
                                                                            style:
                                                                                TextStyle(color: Colors.red, fontSize: 09),
                                                                          ).tr()
                                                                        : SizedBox(),
                                                        RatingBar.builder(
                                                          initialRating: 0,
                                                          itemCount: 5,
                                                          allowHalfRating:
                                                          false,
                                                          itemSize: 15,
                                                          ignoreGestures: true,
                                                          itemBuilder:
                                                              (context, _) =>
                                                              Icon(
                                                                Icons.star,
                                                                color: Get.theme
                                                                    .primaryColor,
                                                              ),
                                                          onRatingUpdate:
                                                              (rating) {},
                                                        ),
                                                        searchController
                                                            .astrologerList[
                                                        index]
                                                            .totalOrder ==
                                                            0 ||
                                                            searchController
                                                                .astrologerList[
                                                            index]
                                                                .totalOrder ==
                                                                null
                                                            ? SizedBox()
                                                            : Text(
                                                          '${searchController.astrologerList[index].totalOrder} orders',
                                                          style: Get
                                                              .theme
                                                              .primaryTextTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                            fontWeight:
                                                            FontWeight
                                                                .w300,
                                                            fontSize: 9,
                                                          ),
                                                        ).tr()
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            searchController
                                                            .isMoreDataAvailable ==
                                                        true &&
                                                    !searchController
                                                        .isAllDataLoaded &&
                                                    searchController
                                                                .astrologerList
                                                                .length -
                                                            1 ==
                                                        index
                                                ? const CircularProgressIndicator()
                                                : const SizedBox(),
                                            if (index == 2 - 1)
                                              const SizedBox(
                                                height: 30,
                                              )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          )
                        : Expanded(
                            child: searchController.astroProduct.isEmpty
                                ? searchResultNotFound()
                                : ListView.builder(
                                    itemCount:
                                        searchController.astroProduct.length,
                                    shrinkWrap: true,
                                    controller: searchController
                                        .searchAstromallScrollController,
                                    padding: const EdgeInsets.all(10),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () async {
                                          AstromallController
                                              astromallController =
                                              Get.find<AstromallController>();
                                          global.showOnlyLoaderDialog(context);
                                          print(
                                              'selected product id:- ${searchController.astroProduct[index].id}');
                                          await astromallController
                                              .getproductById(searchController
                                                  .astroProduct[index].id);
                                          global.hideLoader();
                                          Get.to(() => ProductDetailScreen(
                                              index: index));
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 38,
                                                      backgroundColor: Get
                                                          .theme.primaryColor,
                                                      child: CircleAvatar(
                                                        radius: 35,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              '${global.imgBaseurl}${searchController.astroProduct[index].productImage}',
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              CircleAvatar(
                                                                  radius: 35,
                                                                  backgroundImage:
                                                                      imageProvider),
                                                          placeholder: (context,
                                                                  url) =>
                                                              const Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                            Images.deafultUser,
                                                            fit: BoxFit.cover,
                                                            height: 50,
                                                            width: 40,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(searchController
                                                                  .astroProduct[
                                                                      index]
                                                                  .name)
                                                              .tr(),
                                                          Text(
                                                            '${searchController.astroProduct[index].features}',
                                                            style: Get.textTheme
                                                                .bodySmall,
                                                          ).tr(),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Starting from: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)}${searchController.astroProduct[index].amount}/-',
                                                                style: Get
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ).tr(),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                child: Text(
                                                                        'Buy Now')
                                                                    .tr(),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            searchController.isMoreDataAvailableForAstromall ==
                                                        true &&
                                                    !searchController
                                                        .isAllDataLoadedForAstromall &&
                                                    searchController
                                                                .astroProduct
                                                                .length -
                                                            1 ==
                                                        index
                                                ? const CircularProgressIndicator()
                                                : const SizedBox(),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                  ],
                );
        }),
      ),
    );
  }

  Widget searchResultNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.red,
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text('oops! No result found').tr(),
          Text('try searching something else').tr(),
          Text(
            'Popular Searches',
            style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
          ).tr(),
          FittedBox(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopularSearchWidget(
                    icon: Icons.phone,
                    color: Color.fromARGB(255, 212, 228, 241),
                    text: 'Call',
                    onTap: () {
                      BottomNavigationController bottomNavigationController =
                          Get.find<BottomNavigationController>();
                      bottomNavigationController.setIndex(3, 0);
                      Get.to(() => BottomNavigationBarScreen(
                            index: 3,
                          ));
                    },
                  ),
                  PopularSearchWidget(
                    icon: Icons.chat,
                    color: Color.fromARGB(255, 238, 221, 236),
                    text: 'Chat',
                    onTap: () {
                      BottomNavigationController bottomNavigationController =
                          Get.find<BottomNavigationController>();
                      bottomNavigationController.setIndex(1, 0);
                      Get.to(() => BottomNavigationBarScreen(
                            index: 1,
                          ));
                    },
                  ),
                  PopularSearchWidget(
                    icon: Icons.live_tv,
                    color: Color.fromARGB(255, 235, 236, 221),
                    text: 'Live',
                    onTap: () {
                      Get.to(() => LiveAstrologerListScreen());
                    },
                  ),
                  PopularSearchWidget(
                      icon: Icons.shopping_bag,
                      color: Color.fromARGB(255, 223, 240, 221),
                      text: 'Shopping',
                      onTap: () {
                        Get.to(() => AstromallScreen());
                      })
                ]),
          ),
        ],
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
                                              'Tip:90% users recharge for 10 mins or more.',
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
