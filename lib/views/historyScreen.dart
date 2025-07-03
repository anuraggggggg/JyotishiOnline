// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:AstrowayCustomer/controllers/IntakeController.dart';
import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/addMoneyToWallet.dart';
import 'package:AstrowayCustomer/views/call/call_history_detail_screen.dart';
import 'package:AstrowayCustomer/views/chat/chat_screen.dart';
import 'package:AstrowayCustomer/views/view_report.dart';
import 'package:AstrowayCustomer/widget/customAppbarWidget.dart';
import 'package:AstrowayCustomer/widget/drawerWidget.dart';
import 'package:AstrowayCustomer/widget/recommendedAstrologerWidget.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/bottomNavigationController.dart';
import '../controllers/walletController.dart';

class HistoryScreen extends StatefulWidget {
  int currentIndex;
  HistoryScreen({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

  final ReviewController reviewController = Get.find<ReviewController>();
  HistoryController historyController = Get.find<HistoryController>();
  AstromallController astromallController = Get.find<AstromallController>();
  CallController callController = Get.find<CallController>();
  ScrollController callScrollController = ScrollController();
  ScrollController walletScrollController = ScrollController();
  ScrollController paymentScrollController = ScrollController();
  ScrollController historyScrollController = ScrollController();
  ScrollController reportScrollController = ScrollController();
  ScrollController chatScrollController = ScrollController();
  bool isWalletDataLoadedOnce = false;
  final WalletController walletcontroller = Get.find<WalletController>();

  int index = 0;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    index = widget.currentIndex;
    if (index != 0) {
      callController.setTabIndex(index);
      index = 0;
    }
  }

  void paginateTask() {
    callScrollController.addListener(() async {
      if (callScrollController.position.pixels ==
              callScrollController.position.maxScrollExtent &&
          !historyController.callAllDataLoaded) {
        historyController.callMoreDataAvailable = true;
        historyController.update();
        await historyController.getCallHistory(global.currentUserId!, true);
      }
      historyController.update();
    });
    walletScrollController.addListener(() async {
      if ((walletScrollController.position.pixels ==
              walletScrollController.position.maxScrollExtent) &&
          (!historyController.walletAllDataLoaded)) {
        historyController.walletMoreDataAvailable = true;
        historyController.update();
        if (isWalletDataLoadedOnce == false) {
          setState(() {
            isWalletDataLoadedOnce = true;
          });

          await historyController.getWalletTransaction(
              global.currentUserId!, true);
          setState(() {
            isWalletDataLoadedOnce = false;
          });
        }
      }
      historyController.update();
    });
    paymentScrollController.addListener(() async {
      if (paymentScrollController.position.pixels ==
              paymentScrollController.position.maxScrollExtent &&
          !historyController.paymentAllDataLoaded) {
        historyController.paymentMoreDataAvailable = true;
        historyController.update();
        await historyController.getPaymentLogs(global.currentUserId!, true);
      }
      historyController.update();
    });
    historyScrollController.addListener(() async {
      if (historyScrollController.position.pixels ==
              historyScrollController.position.maxScrollExtent &&
          !historyController.isAllDataLoaded) {
        historyController.isMoreDataAvailable = true;
        historyController.update();
        await historyController.getAstroMall(global.currentUserId!, true);
      }
      historyController.update();
    });
    reportScrollController.addListener(() async {
      if (reportScrollController.position.pixels ==
              reportScrollController.position.maxScrollExtent &&
          !historyController.reportAllDataLoaded) {
        historyController.reportMoreDataAvailable = true;
        historyController.update();
        await historyController.getReportHistory(global.currentUserId!, true);
      }
      historyController.update();
    });
    chatScrollController.addListener(() async {
      if (chatScrollController.position.pixels ==
              chatScrollController.position.maxScrollExtent &&
          !historyController.chatAllDataLoaded) {
        historyController.chatMoreDataAvailable = true;
        historyController.update();
        await historyController.getChatHistory(global.currentUserId!, true);
      }
      historyController.update();
    });
  }

  @override
  Widget build(BuildContext context) {
    paginateTask();
    return WillPopScope(
      onWillPop: () async {
        final BottomNavigationController bottomNavigationController =
            Get.find<BottomNavigationController>();
        bottomNavigationController.setBottomIndex(0, 1);
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          key: drawerKey,
          drawer: DrawerWidget(),
          appBar: CustomAppBar(
            onBackPressed: () {},
            scaffoldKey: drawerKey,
            title: 'History',
            titleStyle: Get.theme.primaryTextTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.normal, color: Colors.black),
            bgColor: Colors.white,
            actions: [],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                GetBuilder<CallController>(builder: (c) {
                  return TabBar(
                    controller: callController.tabController,
                    isScrollable: true,
                    indicatorColor: Get.theme.primaryColor,
                    labelStyle: Get.theme.primaryTextTheme.titleMedium,
                    unselectedLabelStyle: Get
                        .theme.primaryTextTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.w300),
                    labelPadding: EdgeInsets.symmetric(horizontal: 15),
                    onTap: (index) async {
                      callController.setTabIndex(index);
                      await historyController.getChatHistory(
                          global.currentUserId!, false);
                      if (index == 0) {
                        global.showOnlyLoaderDialog(context);
                        await global.splashController.getCurrentUserData();
                        historyController.paymentAllDataLoaded = false;
                        historyController.update();
                        await historyController.getPaymentLogs(
                            global.currentUserId!, true);
                        historyController.walletTransactionList = [];
                        historyController.walletAllDataLoaded = false;
                        historyController.update();
                        await historyController.getWalletTransaction(
                            global.currentUserId!, false);
                        global.hideLoader();
                      }
                      if (index == 1) {
                        // }
                        global.showOnlyLoaderDialog(context);
                        await global.splashController.getCurrentUserData();
                        global.hideLoader();
                      } else if (index == 3) {
                        if (historyController.chatHistoryList.isNotEmpty) {
                        } else {
                          Get.bottomSheet(
                            RecommendedAstrologerWidget(astrologerList: []),
                          );
                        }
                      }

                      global.showOnlyLoaderDialog(Get.context);
                      historyController.callHistoryList = [];
                      historyController.callHistoryList.clear();
                      historyController.callAllDataLoaded = false;
                      historyController.update();
                      await historyController.getCallHistory(
                          global.currentUserId!, false);
                      historyController.chatHistoryList = [];
                      historyController.chatHistoryList.clear();
                      historyController.chatAllDataLoaded = false;
                      historyController.update();
                      await historyController.getChatHistory(
                          global.currentUserId!, false);
                      historyController.astroMallHistoryList = [];
                      historyController.astroMallHistoryList.clear();
                      historyController.isAllDataLoaded = false;
                      historyController.update();
                      await historyController.getAstroMall(
                          global.currentUserId!, false);
                      historyController.update();

                      historyController.reportHistoryList = [];
                      historyController.reportHistoryList.clear();
                      historyController.reportAllDataLoaded = false;
                      historyController.update();
                      await historyController.getReportHistory(
                          global.currentUserId!, false);
                      historyController.update();
                      global.hideLoader();
                    },
                    tabs: [
                      Tab(
                        text: tr('Wallet'),
                      ),
                      Tab(
                        text: 'Call',
                      ),
                      Tab(
                        text: tr('Chat'),
                      ),
                      // Tab(
                      //   text: tr('Shopping'),
                      // ),
                      Tab(
                        text: tr('Report'),
                      ),
                    ],
                  );
                }),
                Container(
                  height: Get.height * 0.7,
                  child: SingleChildScrollView(
                    child: GetBuilder<CallController>(builder: (c) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: callController.tabController!.index == 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Available Balance',
                                    style: Get.theme.primaryTextTheme.bodySmall!
                                        .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[700],
                                    ),
                                  ).tr(),
                                  GetBuilder<SplashController>(
                                      builder: (splashContro) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        global.splashController.currentUser
                                                    ?.walletAmount !=
                                                null
                                            ? Text(
                                                '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)}${global.splashController.currentUser?.walletAmount?.toStringAsFixed(2)}',
                                                style: Get
                                                    .theme
                                                    .primaryTextTheme
                                                    .headlineSmall,
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          height: 30,
                                          child: TextButton(
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.all(4)),
                                              fixedSize:
                                                  MaterialStateProperty.all(
                                                      Size.fromWidth(90)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      appYellow),
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  side: BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 189, 189, 189),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onPressed: () async {
                                              global.showOnlyLoaderDialog(
                                                  context);
                                              await walletcontroller
                                                  .getAmount();
                                              global.hideLoader();
                                              Get.to(() => AddmoneyToWallet());
                                            },
                                            child: Text(
                                              'Recharge',
                                              style: Get.theme.primaryTextTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                            ).tr(),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  SizedBox(height: 15),
                                  TabBar(
                                    controller:
                                        historyController.tabControllerHistory,
                                    indicator: BubbleTabIndicator(
                                      indicatorColor: appYellow,
                                    ),
                                    // indicatorColor: Get.theme.primaryColor),
                                    unselectedLabelStyle:
                                        TextStyle(color: Colors.black),
                                    labelColor: Colors.black,
                                    onTap: (i) async {
                                      global.showOnlyLoaderDialog(context);

                                      historyController.paymentAllDataLoaded =
                                          false;
                                      historyController.update();
                                      await historyController.getPaymentLogs(
                                          global.currentUserId!, false);
                                      historyController.walletTransactionList =
                                          [];
                                      historyController.walletAllDataLoaded =
                                          false;
                                      historyController.update();
                                      await historyController
                                          .getWalletTransaction(
                                              global.currentUserId!, false);
                                      global.hideLoader();
                                    },
                                    tabs: [
                                      Tab(
                                        child: Text(
                                          'Wallet Transaction',
                                          style: TextStyle(fontSize: 14.sp),
                                        ).tr(),
                                      ),
                                      Tab(
                                        child: Text(
                                          'Payment Logs',
                                          style: TextStyle(fontSize: 14.sp),
                                        ).tr(),
                                      ),
                                    ],
                                  ),
                                  GetBuilder<HistoryController>(
                                    builder: (history) {
                                      return GetBuilder<HistoryController>(
                                          builder: (walletHistory) {
                                        return Container(
                                          height: Get.height - 314,
                                          child: TabBarView(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              controller: historyController
                                                  .tabControllerHistory,
                                              children: [
                                                historyController
                                                        .walletTransactionList
                                                        .isNotEmpty
                                                    ? RefreshIndicator(
                                                        onRefresh: () async {
                                                          historyController
                                                              .walletTransactionList = [];
                                                          historyController
                                                              .walletTransactionList
                                                              .clear();
                                                          historyController
                                                                  .walletAllDataLoaded =
                                                              false;
                                                          historyController
                                                              .update();
                                                          await historyController
                                                              .getWalletTransaction(
                                                                  global
                                                                      .currentUserId!,
                                                                  false);
                                                        },
                                                        child: ListView.builder(
                                                          controller:
                                                              walletScrollController,
                                                          shrinkWrap: false,
                                                          itemCount:
                                                              historyController
                                                                  .walletTransactionList
                                                                  .length,
                                                          itemBuilder:
                                                              (context, i) {
                                                            return Column(
                                                              children: [
                                                                Card(
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
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              width: Get.width - 110,
                                                                              child: Text(
                                                                                historyController.walletTransactionList[i].transactionType == 'astromallOrder'
                                                                                    ? '${historyController.walletTransactionList[i].transactionType}'
                                                                                    : historyController.walletTransactionList[i].transactionType == 'Gift'
                                                                                        ? 'Send ${historyController.walletTransactionList[i].transactionType} to ${historyController.walletTransactionList[i].name}'
                                                                                        : historyController.walletTransactionList[i].transactionType == 'Report'
                                                                                            ? 'Report Request to ${historyController.walletTransactionList[i].name}'
                                                                                            : historyController.walletTransactionList[i].transactionType == 'KundliView'
                                                                                                ? '${historyController.walletTransactionList[i].transactionType}'
                                                                                                : historyController.walletTransactionList[i].transactionType == "Cashback"
                                                                                                    ? "${historyController.walletTransactionList[i].transactionType}"
                                                                                                    : '${historyController.walletTransactionList[i].transactionType} with ${historyController.walletTransactionList[i].name} for ${historyController.walletTransactionList[i].totalMin} minutes',
                                                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                                              ).tr(),
                                                                            ),
                                                                            historyController.walletTransactionList[i].isCredit!
                                                                                ? Expanded(
                                                                                    child: Text(
                                                                                      '+ ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.walletTransactionList[i].amount}',
                                                                                      style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  )
                                                                                : Expanded(
                                                                                    child: Text(
                                                                                      '- ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.walletTransactionList[i].amount}',
                                                                                      style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  )
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          '${global.formatter.format(historyController.walletTransactionList[i].createdAt!)}',
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                historyController.walletMoreDataAvailable ==
                                                                            true &&
                                                                        !historyController
                                                                            .walletAllDataLoaded &&
                                                                        historyController.walletTransactionList.length -
                                                                                1 ==
                                                                            i
                                                                    ? const CircularProgressIndicator()
                                                                    : const SizedBox(),
                                                                i == historyController.walletTransactionList.length - 1
                                                                    ? const SizedBox(
                                                                        height:
                                                                            50,
                                                                      )
                                                                    : const SizedBox()
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : Center(
                                                        child: Image.asset(
                                                            Images.noData)),
                                                historyController
                                                            .paymentLogsList
                                                            .isNotEmpty ||
                                                        historyController
                                                                .paymentLogsList
                                                                .length !=
                                                            0
                                                    ? Container(
                                                        child: RefreshIndicator(
                                                        onRefresh: () async {
                                                          historyController
                                                              .paymentLogsList = [];
                                                          historyController
                                                              .paymentLogsList
                                                              .clear();
                                                          historyController
                                                                  .paymentAllDataLoaded =
                                                              false;
                                                          historyController
                                                              .update();
                                                          await historyController
                                                              .getPaymentLogs(
                                                                  global
                                                                      .currentUserId!,
                                                                  false);
                                                        },
                                                        child: ListView.builder(
                                                          controller:
                                                              paymentScrollController,
                                                          itemCount:
                                                              historyController
                                                                  .paymentLogsList
                                                                  .length,
                                                          itemBuilder:
                                                              (context, ind) {
                                                            return Column(
                                                              children: [
                                                                Card(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              'Recharge',
                                                                              style: TextStyle(fontSize: 12),
                                                                            ).tr(),
                                                                            Text(
                                                                              '+${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.paymentLogsList[ind].amount}',
                                                                              style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              '${global.formatter.format(historyController.paymentLogsList[ind].createdAt!)}',
                                                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                                                            ),
                                                                            Text(
                                                                              'GST: ${global.getSystemFlagValue(global.systemFlagNameList.gst)}',
                                                                              style: TextStyle(fontSize: 10, color: Colors.grey),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Icon(
                                                                              historyController.paymentLogsList[ind].paymentStatus == "failed" || historyController.paymentLogsList[ind].paymentStatus == "Failed" ? Icons.error : Icons.check_circle,
                                                                              size: 13,
                                                                              color: historyController.paymentLogsList[ind].paymentStatus == "failed" || historyController.paymentLogsList[ind].paymentStatus == "Failed" ? Colors.red : Colors.green,
                                                                            ),
                                                                            Text(
                                                                              historyController.paymentLogsList[ind].paymentStatus!,
                                                                              style: TextStyle(fontSize: 12, color: historyController.paymentLogsList[ind].paymentStatus == "failed" || historyController.paymentLogsList[ind].paymentStatus == "Failed" ? Colors.red : Colors.green),
                                                                            ).tr()
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                historyController.paymentMoreDataAvailable ==
                                                                            true &&
                                                                        !historyController
                                                                            .paymentAllDataLoaded &&
                                                                        historyController.paymentLogsList.length -
                                                                                1 ==
                                                                            ind
                                                                    ? const CircularProgressIndicator()
                                                                    : const SizedBox(),
                                                                ind ==
                                                                        historyController.paymentLogsList.length -
                                                                            1
                                                                    ? const SizedBox(
                                                                        height:
                                                                            50,
                                                                      )
                                                                    : const SizedBox()
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ))
                                                    : Center(
                                                        child: Image.asset(
                                                            Images.noData))
                                              ]),
                                        );
                                      });
                                    },
                                  )
                                ],
                              )
                            : callController.tabController!.index == 1
                                ? Column(
                                    children: [
                                      GetBuilder<HistoryController>(
                                        builder: (history) {
                                          return historyController
                                                  .callHistoryList.isNotEmpty
                                              ? Container(
                                                  height: Get.height - 197,
                                                  child: RefreshIndicator(
                                                    onRefresh: () async {
                                                      historyController
                                                          .callHistoryList = [];
                                                      historyController
                                                          .callHistoryList
                                                          .clear();
                                                      historyController
                                                              .callAllDataLoaded =
                                                          false;
                                                      historyController
                                                          .update();
                                                      await historyController
                                                          .getCallHistory(
                                                              global
                                                                  .currentUserId!,
                                                              false);
                                                    },
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      controller:
                                                          callScrollController,
                                                      itemCount:
                                                          historyController
                                                              .callHistoryList
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                          onTap: () async {
                                                            IntakeController
                                                                intakeController =
                                                                Get.find<
                                                                    IntakeController>();
                                                            global
                                                                .showOnlyLoaderDialog(
                                                                    context);
                                                            await intakeController
                                                                .getFormIntakeData();
                                                            await historyController
                                                                .getCallHistoryById(
                                                                    historyController
                                                                        .callHistoryList[
                                                                            index]
                                                                        .id!);
                                                            global.hideLoader();
                                                            Get.to(() =>
                                                                CallHistoryDetailScreen(
                                                                  astrologerId: historyController
                                                                      .callHistoryList[
                                                                          index]
                                                                      .astrologerId!,
                                                                  astrologerProfile:
                                                                      historyController
                                                                              .callHistoryList[index]
                                                                              .profileImage ??
                                                                          "",
                                                                  index: index,
                                                                  callType: historyController
                                                                      .callHistoryList[
                                                                          index]
                                                                      .callType,
                                                                ));
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Card(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [],
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                width: 50.w,
                                                                                child: Text(
                                                                                  '${global.formatter.format(historyController.callHistoryList[index].createdAt!)}', //${DateFormat().add_jm().format(historyController.callHistoryList[index].createdAt!)}
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                width: 30.w,
                                                                                child: Text(
                                                                                  historyController.callHistoryList[index].callStatus!,
                                                                                  style: TextStyle(
                                                                                      fontSize: 12,
                                                                                      color: historyController.callHistoryList[index].callStatus == "rejected" || historyController.callHistoryList[index].callStatus == "Rejected"
                                                                                          ? Colors.red
                                                                                          : historyController.callHistoryList[index].callStatus == "pending" || historyController.callHistoryList[index].callStatus == "Pending"
                                                                                              ? Colors.yellow
                                                                                              : Colors.green),
                                                                                ).tr(),
                                                                              ),
                                                                              Container(
                                                                                width: 50.w,
                                                                                child: Text.rich(TextSpan(text: tr('Call type:'), children: [
                                                                                  TextSpan(
                                                                                    text: historyController.callHistoryList[index].isFreeSession == true
                                                                                        ? 'FREE Session'
                                                                                        : '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.callHistoryList[index].callRate == null ? '0' : historyController.callHistoryList[index].callRate == "" ? "0" : historyController.callHistoryList[index].callRate}/min',
                                                                                    style: Get.textTheme.bodyLarge!.copyWith(fontSize: 12, color: Colors.red),
                                                                                  )
                                                                                ])),
                                                                              ),
                                                                              Container(
                                                                                width: 30.w,
                                                                                child: Text(
                                                                                  'Rate: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.callHistoryList[index].callRate == null ? '0' : historyController.callHistoryList[index].callRate == "" ? "0" : historyController.callHistoryList[index].callRate}/min',
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ).tr(),
                                                                              ),
                                                                              Container(
                                                                                width: 30.w,
                                                                                child: Text(
                                                                                  'Duration: ${historyController.callHistoryList[index].totalMin == null ? '0' : historyController.callHistoryList[index].totalMin == "" ? "0" : historyController.callHistoryList[index].totalMin} minutes',
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ).tr(),
                                                                              ),
                                                                              Container(
                                                                                width: 30.w,
                                                                                child: Text(
                                                                                  'Deduction: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.callHistoryList[index].deduction}',
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ).tr(),
                                                                              ),
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  global.createAndShareLinkForHistoryChatCall();
                                                                                },
                                                                                child: Container(
                                                                                  width: 50.w,
                                                                                  margin: const EdgeInsets.only(top: 6),
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                                                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Image.asset(
                                                                                        Images.whatsapp,
                                                                                        height: 30,
                                                                                        width: 30,
                                                                                      ),
                                                                                      Text(
                                                                                        "Share with your friends",
                                                                                        style: Get.textTheme.bodyMedium!.copyWith(fontSize: 12),
                                                                                      ).tr()
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Column(
                                                                              children: [
                                                                                Text(
                                                                                  historyController.callHistoryList[index].astrologerName!,
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                                                                                ).tr(),
                                                                                SizedBox(height: 12),
                                                                                Container(
                                                                                  height: 65,
                                                                                  width: 65,
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Get.theme.primaryColor)),
                                                                                  child: CircleAvatar(
                                                                                    radius: 35,
                                                                                    backgroundColor: Colors.white,
                                                                                    child: CachedNetworkImage(
                                                                                      imageUrl: '${global.imgBaseurl}${historyController.callHistoryList[index].profileImage}',
                                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                                        height: 65,
                                                                                        width: 65,
                                                                                        decoration: BoxDecoration(image: DecorationImage(image: imageProvider)),
                                                                                      ),
                                                                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                      errorWidget: (context, url, error) => Image.asset(
                                                                                        Images.deafultUser,
                                                                                        fit: BoxFit.cover,
                                                                                        height: 50,
                                                                                        width: 40,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  // ignore: unrelated_type_equality_checks
                                                                                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.callHistoryList[index].charge == null ? '0' : historyController.callHistoryList[index].charge == "" ? "0" : historyController.callHistoryList[index].charge}/min',
                                                                                  style: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey, fontSize: 10),
                                                                                ).tr(),
                                                                                Container(
                                                                                  margin: const EdgeInsets.only(top: 6),
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                                                                                  child: Text(
                                                                                    'CALL: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.callHistoryList[index].callRate == null ? '0' : historyController.callHistoryList[index].callRate == "" ? "0" : historyController.callHistoryList[index].callRate}/min',
                                                                                    style: Get.textTheme.bodyLarge!.copyWith(fontSize: 11, color: Colors.grey),
                                                                                  ).tr(),
                                                                                ),
                                                                              ])
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              historyController
                                                                              .callMoreDataAvailable ==
                                                                          true &&
                                                                      !historyController
                                                                          .callAllDataLoaded &&
                                                                      historyController.callHistoryList.length -
                                                                              1 ==
                                                                          index
                                                                  ? const CircularProgressIndicator()
                                                                  : const SizedBox(),
                                                              index ==
                                                                      historyController
                                                                              .callHistoryList
                                                                              .length -
                                                                          1
                                                                  ? const SizedBox(
                                                                      height:
                                                                          50,
                                                                    )
                                                                  : const SizedBox()
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: Get.height - 197,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Center(
                                                        child: Image.asset(
                                                          Images.noDataFound,
                                                          height: 150,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Call history not available',
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ).tr()
                                                    ],
                                                  ),
                                                );
                                        },
                                      )
                                    ],
                                  )
                                : callController.tabController!.index == 2
                                    ? GetBuilder<HistoryController>(
                                        builder: (historyController) {
                                        return Column(children: [
                                          historyController
                                                  .chatHistoryList.isNotEmpty
                                              ? Container(
                                                  height: Get.height - 197,
                                                  child: RefreshIndicator(
                                                    onRefresh: () async {
                                                      historyController
                                                          .chatHistoryList = [];
                                                      historyController
                                                          .chatHistoryList
                                                          .clear();
                                                      historyController
                                                              .chatAllDataLoaded =
                                                          false;
                                                      historyController
                                                          .update();
                                                      await historyController
                                                          .getChatHistory(
                                                              global
                                                                  .currentUserId!,
                                                              false);
                                                    },
                                                    child: ListView.builder(
                                                      controller:
                                                          chatScrollController,
                                                      itemCount:
                                                          historyController
                                                              .chatHistoryList
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                          onTap: () async {
                                                            ChatController
                                                                chatController =
                                                                Get.find<
                                                                    ChatController>();
                                                            global
                                                                .showOnlyLoaderDialog(
                                                                    context);
                                                            await chatController
                                                                .getuserReview(
                                                                    historyController
                                                                        .chatHistoryList[
                                                                            index]
                                                                        .astrologerId!);
                                                            global.hideLoader();
                                                            Get.to(() =>
                                                                AcceptChatScreen(
                                                                  flagId: 0,
                                                                  profileImage: historyController
                                                                      .chatHistoryList[
                                                                          index]
                                                                      .profileImage!,
                                                                  astrologerName: historyController
                                                                      .chatHistoryList[
                                                                          index]
                                                                      .astrologerName!,
                                                                  fireBasechatId: historyController
                                                                      .chatHistoryList[
                                                                          index]
                                                                      .chatId!,
                                                                  astrologerId: historyController
                                                                      .chatHistoryList[
                                                                          index]
                                                                      .astrologerId!,
                                                                  chatId: historyController
                                                                      .chatHistoryList[
                                                                          index]
                                                                      .id!,
                                                                  duration: historyController
                                                                      .chatHistoryList[
                                                                          index]
                                                                      .duration!,
                                                                ));
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Card(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(width: 50.w, child: Text('${global.formatter.format(historyController.chatHistoryList[index].createdAt!)}')),
                                                                              Container(
                                                                                width: 50.w,
                                                                                child: Text(
                                                                                  historyController.chatHistoryList[index].chatStatus!,
                                                                                  style: TextStyle(
                                                                                      fontSize: 12,
                                                                                      color: historyController.chatHistoryList[index].chatStatus == "rejected" || historyController.chatHistoryList[index].chatStatus == "Rejected"
                                                                                          ? Colors.red
                                                                                          : historyController.chatHistoryList[index].chatStatus == "pending" || historyController.chatHistoryList[index].chatStatus == "Pending"
                                                                                              ? Colors.yellow
                                                                                              : Colors.green),
                                                                                ).tr(),
                                                                              ),
                                                                              Container(
                                                                                width: 30.w,
                                                                                child: Text.rich(TextSpan(text: 'Chat type: ', children: [
                                                                                  TextSpan(
                                                                                    text: historyController.chatHistoryList[index].isFreeSession == true
                                                                                        ? 'FREE Session'
                                                                                        : '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.chatHistoryList[index].chatRate == null ? '0' : historyController.chatHistoryList[index].chatRate == "" ? "0" : historyController.chatHistoryList[index].chatRate}/min',
                                                                                    style: Get.textTheme.bodyLarge!.copyWith(fontSize: 12, color: Colors.red),
                                                                                  )
                                                                                ])),
                                                                              ),
                                                                              Container(
                                                                                width: 30.w,
                                                                                child: Text(
                                                                                  'Rate: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.chatHistoryList[index].chatRate == null ? '0' : historyController.chatHistoryList[index].chatRate == "" ? "0" : historyController.chatHistoryList[index].chatRate}/min',
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ).tr(),
                                                                              ),
                                                                              Container(
                                                                                width: 50.w,
                                                                                child: Text(
                                                                                  'Duration: ${historyController.chatHistoryList[index].totalMin == null ? '0' : historyController.chatHistoryList[index].totalMin == "" ? "0" : historyController.chatHistoryList[index].totalMin} minutes',
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ).tr(),
                                                                              ),
                                                                              Container(
                                                                                width: 50.w,
                                                                                child: Text(
                                                                                  'Deduction: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.chatHistoryList[index].deduction}',
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ).tr(),
                                                                              ),
                                                                              Container(
                                                                                width: 50.w,
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    ChatController chatController = Get.find<ChatController>();
                                                                                    global.showOnlyLoaderDialog(context);
                                                                                    chatController.shareChat(historyController.chatHistoryList[index].chatId ?? '', historyController.chatHistoryList[index].astrologerName ?? '');
                                                                                    global.hideLoader();
                                                                                  },
                                                                                  child: Container(
                                                                                    margin: const EdgeInsets.only(top: 6),
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                                                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Image.asset(
                                                                                          Images.whatsapp,
                                                                                          height: 30,
                                                                                          width: 30,
                                                                                        ),
                                                                                        Text(
                                                                                          "Share with your friends",
                                                                                          style: Get.textTheme.bodyMedium!.copyWith(fontSize: 12),
                                                                                        ).tr()
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Column(
                                                                              children: [
                                                                                Text(
                                                                                  historyController.chatHistoryList[index].astrologerName!,
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                                                                                ).tr(),
                                                                                SizedBox(height: 12),
                                                                                Container(
                                                                                  height: 65,
                                                                                  width: 65,
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Get.theme.primaryColor)),
                                                                                  child: CircleAvatar(
                                                                                    radius: 35,
                                                                                    backgroundColor: Colors.white,
                                                                                    child: CachedNetworkImage(
                                                                                      imageUrl: '${global.imgBaseurl}${historyController.chatHistoryList[index].profileImage}',
                                                                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                      errorWidget: (context, url, error) => Image.asset(
                                                                                        Images.deafultUser,
                                                                                        fit: BoxFit.cover,
                                                                                        height: 50,
                                                                                        width: 40,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  // ignore: unrelated_type_equality_checks
                                                                                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.chatHistoryList[index].charge == null ? '0' : historyController.chatHistoryList[index].charge == "" ? "0" : historyController.chatHistoryList[index].charge}/min',
                                                                                  style: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey, fontSize: 10),
                                                                                ),
                                                                                Container(
                                                                                  margin: const EdgeInsets.only(top: 6),
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                                                                                  child: Text(
                                                                                    'CHAT: ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.chatHistoryList[index].chatRate == null ? '0' : historyController.chatHistoryList[index].chatRate == "" ? "0" : historyController.chatHistoryList[index].chatRate}/min',
                                                                                    style: Get.textTheme.bodyLarge!.copyWith(fontSize: 11, color: Colors.grey),
                                                                                  ).tr(),
                                                                                ),
                                                                              ])
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              historyController
                                                                              .chatMoreDataAvailable ==
                                                                          true &&
                                                                      !historyController
                                                                          .chatAllDataLoaded &&
                                                                      historyController.chatHistoryList.length -
                                                                              1 ==
                                                                          index
                                                                  ? const CircularProgressIndicator()
                                                                  : const SizedBox(),
                                                              index ==
                                                                      historyController
                                                                              .chatHistoryList
                                                                              .length -
                                                                          1
                                                                  ? const SizedBox(
                                                                      height:
                                                                          50,
                                                                    )
                                                                  : const SizedBox()
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: Get.height - 197,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Center(
                                                        child: Image.asset(
                                                          Images.noDataFound,
                                                          height: 150,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Chat history not available',
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ).tr()
                                                    ],
                                                  ),
                                                )
                                        ]);
                                      })
                                    : callController.tabController!.index == 3
                                        ? GetBuilder<HistoryController>(
                                            builder: (hist) {
                                            return Column(children: [
                                              historyController
                                                      .astroMallHistoryList
                                                      .isNotEmpty
                                                  ? Container(
                                                      height: Get.height - 197,
                                                      child: RefreshIndicator(
                                                        onRefresh: () async {
                                                          historyController
                                                              .astroMallHistoryList = [];
                                                          historyController
                                                              .astroMallHistoryList
                                                              .clear();
                                                          historyController
                                                                  .isAllDataLoaded =
                                                              false;
                                                          historyController
                                                              .update();
                                                          await historyController
                                                              .getAstroMall(
                                                                  global
                                                                      .currentUserId!,
                                                                  false);
                                                        },
                                                        child: ListView.builder(
                                                          controller:
                                                              historyScrollController,
                                                          itemCount:
                                                              historyController
                                                                  .astroMallHistoryList
                                                                  .length,
                                                          itemBuilder:
                                                              (context, inx) {
                                                            return Column(
                                                              children: [
                                                                Card(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  width: 40.w,
                                                                                  child: Text(
                                                                                    historyController.astroMallHistoryList[inx].productName!,
                                                                                    style: Get.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                                                                  ).tr(),
                                                                                ),
                                                                                Text(
                                                                                  '${historyController.astroMallHistoryList[inx].orderAddressName}',
                                                                                ).tr(),
                                                                                Text(
                                                                                  '${global.formatter.format(historyController.astroMallHistoryList[inx].createdAt!)}',
                                                                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                                                                ).tr(),
                                                                                Text(
                                                                                  '${historyController.astroMallHistoryList[inx].flatNo} ${historyController.astroMallHistoryList[inx].city} ${historyController.astroMallHistoryList[inx].state} ${historyController.astroMallHistoryList[inx].country} ${historyController.astroMallHistoryList[inx].pincode}',
                                                                                  overflow: TextOverflow.clip,
                                                                                  style: TextStyle(fontSize: 12),
                                                                                ).tr(),
                                                                                Text(
                                                                                  'GST: ${global.getSystemFlagValue(global.systemFlagNameList.gst)}',
                                                                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                                                                ),
                                                                                Text(
                                                                                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.astroMallHistoryList[inx].totalPayable}',
                                                                                  style: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey, fontSize: 13),
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Order Status: ',
                                                                                      style: Get.textTheme.bodyMedium!.copyWith(fontSize: 13),
                                                                                    ).tr(),
                                                                                    Text(
                                                                                      historyController.astroMallHistoryList[inx].orderStatus!.toUpperCase(),
                                                                                      style: TextStyle(
                                                                                          fontSize: 13,
                                                                                          color: historyController.astroMallHistoryList[inx].orderStatus! == "Cancelled"
                                                                                              ? Colors.yellow
                                                                                              : historyController.astroMallHistoryList[inx].orderStatus! == "Pending"
                                                                                                  ? Colors.red
                                                                                                  : Colors.green),
                                                                                    ).tr(),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    historyController.astroMallHistoryList[inx].orderStatus == 'Pending' || historyController.astroMallHistoryList[inx].orderStatus == "Confirmed"
                                                                                        ? ElevatedButton(
                                                                                            onPressed: () async {
                                                                                              global.showOnlyLoaderDialog(context);
                                                                                              await historyController.cancleOrder(historyController.astroMallHistoryList[inx].id!);
                                                                                              global.hideLoader();
                                                                                            },
                                                                                            child: Text(
                                                                                              "Cancel Order",
                                                                                              style: TextStyle(color: Colors.white),
                                                                                            ).tr())
                                                                                        : const SizedBox(),
                                                                                    InkWell(
                                                                                        onTap: () async {
                                                                                          if (await canLaunch("${historyController.astroMallHistoryList[inx].invoice_link}")) {
                                                                                            await launchUrl(Uri.parse("${historyController.astroMallHistoryList[inx].invoice_link}"));
                                                                                          } else {
                                                                                            print("error in laucnhing url");
                                                                                          }
                                                                                        },
                                                                                        child: Icon(Icons.download))
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                            Column(children: [
                                                                              SizedBox(
                                                                                width: Get.width * 0.3,
                                                                                child: Text(
                                                                                  historyController.astroMallHistoryList[inx].productName!,
                                                                                  style: Get.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                                                                                ).tr(),
                                                                              ),
                                                                              SizedBox(height: 12),
                                                                              Container(
                                                                                height: 65,
                                                                                width: 65,
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Get.theme.primaryColor)),
                                                                                child: CircleAvatar(
                                                                                  radius: 35,
                                                                                  backgroundColor: Colors.white,
                                                                                  child: CachedNetworkImage(
                                                                                    imageUrl: '${global.imgBaseurl}${historyController.astroMallHistoryList[inx].productImage}',
                                                                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                    errorWidget: (context, url, error) => Image.asset(
                                                                                      Images.deafultUser,
                                                                                      fit: BoxFit.cover,
                                                                                      height: 50,
                                                                                      width: 40,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ])
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                historyController.isMoreDataAvailable ==
                                                                            true &&
                                                                        !historyController
                                                                            .isAllDataLoaded &&
                                                                        historyController.astroMallHistoryList.length -
                                                                                1 ==
                                                                            inx
                                                                    ? const CircularProgressIndicator()
                                                                    : const SizedBox(),
                                                                inx ==
                                                                        historyController.astroMallHistoryList.length -
                                                                            1
                                                                    ? const SizedBox(
                                                                        height:
                                                                            50,
                                                                      )
                                                                    : const SizedBox()
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: Get.height - 197,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Center(
                                                            child: Image.asset(
                                                              Images
                                                                  .noDataFound,
                                                              height: 150,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Shopping history not available',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          ).tr()
                                                        ],
                                                      ),
                                                    )
                                            ]);
                                          })
                                        : callController.tabController!.index ==
                                                4
                                            ? GetBuilder<HistoryController>(
                                                builder: (c) {
                                                return Column(
                                                  children: [
                                                    historyController
                                                            .reportHistoryList
                                                            .isNotEmpty
                                                        ? Container(
                                                            height: Get.height -
                                                                197,
                                                            child:
                                                                RefreshIndicator(
                                                              onRefresh:
                                                                  () async {
                                                                historyController
                                                                    .reportHistoryList = [];
                                                                historyController
                                                                    .reportHistoryList
                                                                    .clear();
                                                                historyController
                                                                        .reportAllDataLoaded =
                                                                    false;
                                                                historyController
                                                                    .update();
                                                                await historyController
                                                                    .getReportHistory(
                                                                        global
                                                                            .currentUserId!,
                                                                        false);
                                                              },
                                                              child: ListView
                                                                  .builder(
                                                                controller:
                                                                    reportScrollController,
                                                                itemCount:
                                                                    historyController
                                                                        .reportHistoryList
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Column(
                                                                    children: [
                                                                      Card(
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        "${DateFormat("dd MMM yy, hh:mm a").format(DateTime.parse(historyController.reportHistoryList[index].createdAt))}",
                                                                                      ),
                                                                                      Text(
                                                                                        '${historyController.reportHistoryList[index].firstName} ${historyController.reportHistoryList[index].lastName}',
                                                                                        style: Get.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                                                                      ).tr(),
                                                                                      Text(
                                                                                        historyController.reportHistoryList[index].contactNo!,
                                                                                      ).tr(),
                                                                                      Text(
                                                                                        '${historyController.reportHistoryList[index].title}',
                                                                                        style: TextStyle(color: Colors.grey),
                                                                                      ).tr(),
                                                                                      Text(
                                                                                        '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.reportHistoryList[index].reportRate == null ? '0' : historyController.reportHistoryList[index].reportRate == null ? 0 : historyController.reportHistoryList[index].reportRate}',
                                                                                        style: Get.textTheme.bodyLarge!.copyWith(
                                                                                          color: Colors.grey,
                                                                                          fontSize: 12,
                                                                                        ),
                                                                                      ),
                                                                                      historyController.reportHistoryList[index].isFileUpload!
                                                                                          ? ElevatedButton(
                                                                                              onPressed: () {
                                                                                                Get.to(() => ViewReportScreen(index: index));
                                                                                              },
                                                                                              child: Text(
                                                                                                "View Report",
                                                                                                style: TextStyle(color: Colors.white),
                                                                                              ).tr())
                                                                                          : const SizedBox()
                                                                                    ],
                                                                                  ),
                                                                                  Column(children: [
                                                                                    Text(
                                                                                      '${historyController.reportHistoryList[index].astrologerName}',
                                                                                      style: Get.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                                                                    ).tr(),
                                                                                    const SizedBox(
                                                                                      height: 12,
                                                                                    ),
                                                                                    Center(
                                                                                      child: Container(
                                                                                        height: 65,
                                                                                        width: 65,
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Get.theme.primaryColor)),
                                                                                        child: CircleAvatar(
                                                                                          radius: 35,
                                                                                          backgroundColor: Colors.white,
                                                                                          child: CachedNetworkImage(
                                                                                            imageUrl: '${global.imgBaseurl}${historyController.reportHistoryList[index].profileImage}',
                                                                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                            errorWidget: (context, url, error) => Image.asset(
                                                                                              Images.deafultUser,
                                                                                              fit: BoxFit.cover,
                                                                                              height: 50,
                                                                                              width: 40,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      'Rate ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${historyController.reportHistoryList[index].reportRate == null ? '0' : historyController.reportHistoryList[index].reportRate == null ? 0 : historyController.reportHistoryList[index].reportRate}',
                                                                                      style: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey, fontSize: 10),
                                                                                    ).tr(),
                                                                                  ])
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      historyController.reportMoreDataAvailable == true &&
                                                                              !historyController.reportAllDataLoaded &&
                                                                              historyController.reportHistoryList.length - 1 == index
                                                                          ? const CircularProgressIndicator()
                                                                          : const SizedBox(),
                                                                      index ==
                                                                              historyController.reportHistoryList.length - 1
                                                                          ? const SizedBox(
                                                                              height: 50,
                                                                            )
                                                                          : const SizedBox()
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            height: Get.height -
                                                                197,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Center(
                                                                  child: Image
                                                                      .asset(
                                                                    Images
                                                                        .noDataFound,
                                                                    height: 150,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Report history not available',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey),
                                                                ).tr()
                                                              ],
                                                            ),
                                                          )
                                                  ],
                                                );
                                              })
                                            : Column(
                                                children: [
                                                  Container(height: 100),
                                                  Image.asset(Images.noData,
                                                      height: 150, width: 150),
                                                  Text(
                                                    'Uh - oh!',
                                                  ).tr(),
                                                ],
                                              ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
