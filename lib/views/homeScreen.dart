import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/controllers/advancedPanchangController.dart';
import 'package:AstrowayCustomer/controllers/astrologerCategoryController.dart';
import 'package:AstrowayCustomer/controllers/astrologyBlogController.dart';
import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/dailyHoroscopeController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/controllers/liveController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/model/fastApiModel/UserModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/currentUserWalletModel.dart';

import 'package:AstrowayCustomer/model/kundli_model.dart';
import 'package:AstrowayCustomer/utils/AppColors.dart';
import 'package:AstrowayCustomer/utils/date_converter.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/addMoneyToWallet.dart';
import 'package:AstrowayCustomer/views/astroBlog/astrologyBlogListScreen.dart';
import 'package:AstrowayCustomer/views/astroBlog/astrologyDetailScreen.dart';
import 'package:AstrowayCustomer/views/astrologerNews.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/astrologerProfile.dart';
import 'package:AstrowayCustomer/views/astrologerVideo.dart';
import 'package:AstrowayCustomer/views/astromall/astromallScreen.dart';
import 'package:AstrowayCustomer/views/blog_screen.dart';
import 'package:AstrowayCustomer/views/call/call_history_detail_screen.dart';
import 'package:AstrowayCustomer/views/callScreen.dart';
import 'package:AstrowayCustomer/views/categoryScreen.dart';
import 'package:AstrowayCustomer/views/chat/chat_screen.dart';
import 'package:AstrowayCustomer/views/clientsReviewScreem.dart';
import 'package:AstrowayCustomer/views/kudali/kundliScreen.dart';
import 'package:AstrowayCustomer/views/kundliMatching/kundliMatchingScreen.dart';
import 'package:AstrowayCustomer/views/liveAstrologerList.dart';
import 'package:AstrowayCustomer/views/live_astrologer/live_astrologer_screen.dart';
import 'package:AstrowayCustomer/views/panchangScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/LoveCompatibilityInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/birthdayNumberInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/dailyPredictionInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/kundli_input_screen.dart';
import 'package:AstrowayCustomer/views/proKerela/planetInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/services.dart';
import 'package:AstrowayCustomer/views/searchAstrologerScreen.dart';
import 'package:AstrowayCustomer/views/settings/notificationScreen.dart';
import 'package:AstrowayCustomer/views/stories/viewStories.dart';
import 'package:AstrowayCustomer/views/wallet/walletRechargeScreen.dart';
import 'package:AstrowayCustomer/widget/drawerWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/IntakeController.dart';
import '../controllers/chatController.dart';
import '../controllers/settings_controller.dart';
import '../controllers/splashController.dart';
import '../controllers/walletController.dart';
import '../theme/appTheme.dart';
import '../utils/fonts.dart';
import '../utils/screenSize.dart';
import '../widget/videoPlayerWidget.dart';
import 'CustomText.dart';
import 'astromall/astroProductScreen.dart';
import 'customer_support/customerSupportChatScreen.dart';
import 'customer_support/customer_support_chat_screen.dart';
import 'daily_horoscope/dailyHoroscopeScreen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

  final homeController = Get.find<HomeController>();
  final astrologerCategoryController = Get.find<AstrologerCategoryController>();
  final bottomControllerMain = Get.find<BottomNavigationController>();
  final liveController = Get.find<LiveController>();
  final kundliController = Get.find<KundliController>();
  final panchangController = Get.find<PanchangController>();
  final splashController = Get.find<SplashController>();
  final walletController = Get.find<WalletController>();
  final astromallController = Get.find<AstromallController>();
  final _pageController = PageController();
  int _pageIndex = 0;
  final bottomNavigationController = Get.find<BottomNavigationController>();
  final chatController = Get.find<ChatController>();
  CurrentUserWalletModel? _wallet;
  UserModel? userDetails;
  String? userName;

  // AppEventsLogger logger = AppEventsLogger.newLogger(this);
  @override
  void initState() {
    super.initState();
    FastAPIServices().fetchCustomerDetails();
    FastAPIServices().fetchCurrentUserDetails();
    FastAPIServices().getAllWalletDetails();
    FastAPIServices().fetchCurrentWallet();
    _loadUserName();

    _fetchAllData();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name"); // read the saved name
    });
  }

  void _fetchAllData() async {
    final wallet = await FastAPIServices().fetchCurrentWallet();
    setState(() {
      _wallet = wallet;
    });

    final apiService = FastAPIServices();

    // Fetch wallets
    try {
      final wallets =
          await apiService.getAllWalletDetails(); // now properly awaited
      for (var wallet in wallets) {
        print(wallet); // prints each wallet
      }
    } catch (e) {
      print("❌ Error fetching wallets: $e");
    }

    // You can also fetch customers and current user here similarly
  }

  final wallet = FastAPIServices().fetchCurrentWallet();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool isExit = await homeController.onBackPressed();
        if (isExit) {
          exit(0);
        }
        return isExit;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: drawerKey,
        drawer: DrawerWidget(),
        appBar: AppBar(
          toolbarHeight:
              kIsWeb ? MediaQuery.of(context).size.height * 0.16 : null,
          elevation: 0,
          // backgroundColor: Colors.grey,
          title: Text(
            userName == null ? "User..." : "Hi $userName",
            style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
              fontSize: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.027
                  : MediaQuery.of(context).size.width * 0.040,
              fontWeight: FontWeight.normal,
              // color: appColor,
            ),
          ),

          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          leading: InkWell(
            onTap: () {
              if (kIsWeb) {
                if (MediaQuery.of(context).size.width <= 700) {
                  drawerKey.currentState!.isDrawerOpen
                      ? drawerKey.currentState!.closeDrawer()
                      : drawerKey.currentState!.openDrawer();
                }
              } else {
                drawerKey.currentState!.isDrawerOpen
                    ? drawerKey.currentState!.closeDrawer()
                    : drawerKey.currentState!.openDrawer();
              }
            },
            child: MediaQuery.of(context).size.width >= 700
                ? SizedBox()
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              "${global.imgBaseurl}${splashController.currentUser?.profile}")),
                      Positioned(
                        right: 2,
                        bottom: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.menu,
                            size: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          actions: kIsWeb
              ? [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GetBuilder<SettingsController>(
                              builder: (settingsController) {
                            return InkWell(
                              onTap: () async {
                                global.showOnlyLoaderDialog(context);
                                await settingsController.getNotification();
                                global.hideLoader();
                                Get.to(() => const NotificationScreen());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.w, vertical: 1.h),
                                child: Row(
                                  children: [
                                    CustomText(
                                      text: "Notification",
                                      fontWeight: FontWeight.w500,
                                      fontsize: 13.sp,
                                      color: Colors.black,
                                    ),
                                    Icon(
                                      Icons.notifications_none,
                                      size: 13.sp,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                          ),
                          InkWell(
                            onTap: () async {
                              bool isLogin = await global.isLogin();
                              global.showOnlyLoaderDialog(context);
                              await walletController.getAmount();
                              global.hideLoader();
                              if (isLogin) {
                                Get.to(() => AddmoneyToWallet());
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                children: [
                                  CustomText(
                                    text: "Wallet",
                                    fontWeight: FontWeight.w500,
                                    fontsize: 13.sp,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  Image.asset(
                                    Images.wallet,
                                    height: 18,
                                    width: 18,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                          ),
                          InkWell(
                            onTap: () async {
                              homeController.lan = [];
                              await Future.wait([
                                homeController.getLanguages(),
                                homeController.updateLanIndex()
                              ]);
                              //LANGUAGE DIALOG
                              print(homeController.lan);
                              global.checkBody().then((result) {
                                if (result) {
                                  // This is the updated showDialog block
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return GetBuilder<HomeController>(
                                        builder: (h) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            // Set contentPadding to zero, as inner Container will handle its own padding
                                            contentPadding: EdgeInsets.zero,
                                            // Add rounded corners to the AlertDialog itself
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  20.0), // More rounded corners for the dialog
                                            ),
                                            content: GetBuilder<HomeController>(
                                              builder: (h) {
                                                return Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min, // Make column wrap its children tightly
                                                  children: [
                                                    // Close button at the top right
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            size:
                                                                26), // Larger icon for better visibility
                                                        onPressed: () =>
                                                            Get.back(),
                                                        padding: EdgeInsets.all(
                                                            12), // Good padding for touch target
                                                        color: Colors.grey
                                                            .shade600, // Softer color for the icon
                                                      ),
                                                    ),
                                                    // Flexible and SingleChildScrollView to prevent bottom overflow
                                                    Flexible(
                                                      child:
                                                          SingleChildScrollView(
                                                        // This is the enhanced Container content from the previous turn
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      24,
                                                                  vertical:
                                                                      0), // Adjust vertical padding as IconButton takes care of top padding
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center, // Center horizontally
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min, // Ensure column takes minimum vertical space
                                                            children: [
                                                              // Language selection title
                                                              Text(
                                                                'Choose your app language',
                                                                textAlign: TextAlign
                                                                    .center, // Center the text
                                                                style: Get
                                                                    .textTheme
                                                                    .headlineSmall!
                                                                    .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .deepPurple
                                                                      .shade700,
                                                                  fontSize:
                                                                      22.0,
                                                                ),
                                                              ).tr(),
                                                              SizedBox(
                                                                  height:
                                                                      25), // Increased spacing after the title

                                                              // Language tiles
                                                              GetBuilder<
                                                                  HomeController>(
                                                                builder:
                                                                    (home) {
                                                                  return Padding(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                0),
                                                                    child: Wrap(
                                                                      spacing:
                                                                          15.0,
                                                                      runSpacing:
                                                                          15.0,
                                                                      alignment:
                                                                          WrapAlignment
                                                                              .center,
                                                                      children:
                                                                          List.generate(
                                                                        homeController
                                                                            .lan
                                                                            .length,
                                                                        (index) {
                                                                          bool isSelected = homeController
                                                                              .lan[index]
                                                                              .isSelected;
                                                                          return InkWell(
                                                                            onTap:
                                                                                () {
                                                                              homeController.updateLan(index);
                                                                              Locale newLocale;
                                                                              switch (index) {
                                                                                case 0:
                                                                                  newLocale = const Locale('en', 'US');
                                                                                  break;
                                                                                case 7:
                                                                                  newLocale = const Locale('ml', 'IN');
                                                                                  break;
                                                                                default:
                                                                                  newLocale = const Locale('ml', 'IN');
                                                                                  break;
                                                                              }
                                                                              context.setLocale(newLocale);
                                                                              Get.updateLocale(newLocale);
                                                                              refreshIt();
                                                                            },
                                                                            child:
                                                                                GetBuilder<HomeController>(
                                                                              builder: (h) {
                                                                                return AnimatedContainer(
                                                                                  duration: const Duration(milliseconds: 250),
                                                                                  curve: Curves.easeInOut,
                                                                                  height: 95,
                                                                                  width: 100,
                                                                                  alignment: Alignment.center,
                                                                                  margin: EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                                                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                                                  decoration: BoxDecoration(
                                                                                    color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                                                                                    border: Border.all(
                                                                                      color: isSelected ? Get.theme.primaryColor : Colors.grey.shade300,
                                                                                      width: isSelected ? 2.5 : 1.0,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                    boxShadow: isSelected
                                                                                        ? [
                                                                                            BoxShadow(
                                                                                              color: Colors.deepPurple.withOpacity(0.2),
                                                                                              spreadRadius: 2,
                                                                                              blurRadius: 8,
                                                                                              offset: Offset(0, 4),
                                                                                            ),
                                                                                          ]
                                                                                        : [
                                                                                            BoxShadow(
                                                                                              color: Colors.grey.withOpacity(0.1),
                                                                                              spreadRadius: 1,
                                                                                              blurRadius: 3,
                                                                                              offset: Offset(0, 2),
                                                                                            ),
                                                                                          ],
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text(
                                                                                        homeController.lan[index].title,
                                                                                        textAlign: TextAlign.center,
                                                                                        style: Get.textTheme.bodyLarge!.copyWith(
                                                                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                                                          color: isSelected ? Get.theme.primaryColor : Colors.black87,
                                                                                          fontSize: 16.0,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 6),
                                                                                      Text(
                                                                                        homeController.lan[index].subTitle,
                                                                                        textAlign: TextAlign.center,
                                                                                        style: Get.textTheme.bodySmall!.copyWith(
                                                                                          fontSize: 12.0,
                                                                                          color: isSelected ? Colors.deepPurple.shade600 : Colors.grey.shade600,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              SizedBox(
                                                                  height: 30),

                                                              // APPLY button
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  // primary: Get.theme.primaryColor,
                                                                  // onPrimary: Colors.white,
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          50,
                                                                      vertical:
                                                                          16),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  ),
                                                                  elevation: 8,
                                                                  shadowColor: Get
                                                                      .theme
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.4),
                                                                ),
                                                                child: Text(
                                                                  'APPLY',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                                ).tr(),
                                                              ),
                                                              SizedBox(
                                                                  height: 20),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                children: [
                                  CustomText(
                                    text: "Language",
                                    fontWeight: FontWeight.w500,
                                    fontsize: 13.sp,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  Icon(Icons.translate),
                                  // Image.asset(
                                  //   Images.translation,
                                  //   height: 18,
                                  //   width: 18,
                                  //   fit: BoxFit.fill,
                                  //   color: Colors.black,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(() => SearchAstrologerScreen());
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 13.sp,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 1.w, vertical: 1.h),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.solidCommentDots,
                                  size: 12.sp,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                FittedBox(
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  child: Text('Chat with Astrologer',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 12.sp))
                                      .tr(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 1.w, vertical: 1.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 12.sp,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                FittedBox(
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  child: Text('Call with Astrologer',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 12.sp))
                                      .tr(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ]
              : [
                  // GetBuilder<SettingsController>(builder: (settingsController) {
                  //   return InkWell(
                  //     onTap: () async {
                  //       global.showOnlyLoaderDialog(context);
                  //       await settingsController.getNotification();
                  //       global.hideLoader();
                  //       Get.to(() => const NotificationScreen());
                  //     },
                  //     child: Icon(
                  //       Icons.notifications_none,
                  //       size: 30,
                  //     ),
                  //   );
                  // }),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () async {
                      // bool isLogin = await global.isLogin();
                      // global.showOnlyLoaderDialog(context);
                      // await walletController.getAmount();
                      // global.hideLoader();
                      // if (isLogin) {
                      //   // Get.to(() => AddmoneyToWallet());

                      // }

                      Get.to(() => RechargeWalletScreen());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(2.w, 1.w, 2.w, 1.w),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/wallet1.png",
                              height: 20,
                              width: 20,
                            ),
                            // Icon(Icons.wallet_outlined, color: Colors.black,),
                            SizedBox(width: 8),
                            Text('',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                            Text(
                              _wallet != null
                                  ? "₹${_wallet!.amount}"
                                  : "Loading...",

                              //  "${splashController.currentUser!.walletAmount ?? "00"}",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.add_circle,
                              color: Colors.black,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1),
                  InkWell(
                    onTap: () async {
                      homeController.lan = [];
                      await Future.wait([
                        homeController.getLanguages(),
                        homeController.updateLanIndex()
                      ]);
                      //LANGUAGE DIALOG
                      print(homeController.lan);
                      global.checkBody().then((result) {
                        if (result) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return GetBuilder<HomeController>(builder: (h) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    contentPadding: EdgeInsets.zero,
                                    content: GetBuilder<HomeController>(
                                        builder: (h) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => Get.back(),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 2.w,
                                                top: 2.w,
                                              ),
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: const Icon(Icons.close),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              padding: EdgeInsets.all(6),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Choose your app language',
                                                      style: Get.textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ).tr(),
                                                    GetBuilder<HomeController>(
                                                        builder: (home) {
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 15),
                                                        child: Wrap(
                                                            children:
                                                                List.generate(
                                                                    homeController
                                                                        .lan
                                                                        .length,
                                                                    (index) {
                                                          return InkWell(onTap:
                                                              () {
                                                            //! LANGUAGE SET DILAOG
                                                            homeController
                                                                .updateLan(
                                                                    index);
                                                            switch (index) {
                                                              case 0:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'en',
                                                                        'US'); //ENGLISH

                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;
                                                              case 1:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'ml',
                                                                        'IN');
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;
                                                              case 2:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'hi',
                                                                        'IN'); //HINDI
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;
                                                              case 3:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'es',
                                                                        'ES'); //Spanish
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;
                                                              case 4:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'mr',
                                                                        'IN'); //marathi
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;
                                                              case 5:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'bn',
                                                                        'IN'); //bengali
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;

                                                              case 6:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'kn',
                                                                        'IN'); //kannad
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;

                                                              case 7:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'ml',
                                                                        'IN'); //malayalam
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;

                                                              case 8:
                                                                var newLocale =
                                                                    const Locale(
                                                                        'ta',
                                                                        'IN'); //tamil
                                                                context.setLocale(
                                                                    newLocale);
                                                                Get.updateLocale(
                                                                    newLocale);
                                                                refreshIt();

                                                                break;
                                                            }
                                                          }, child: GetBuilder<
                                                              HomeController>(
                                                            builder: (h) {
                                                              // Determine if the current language tile is selected
                                                              bool isSelected =
                                                                  homeController
                                                                      .lan[
                                                                          index]
                                                                      .isSelected;

                                                              return AnimatedContainer(
                                                                // Use AnimatedContainer for smooth visual transitions
                                                                duration: const Duration(
                                                                    milliseconds:
                                                                        250), // Duration of the animation
                                                                curve: Curves
                                                                    .easeInOut, // Easing curve for a smoother effect
                                                                // height: 120, // Increased height for better visual presence
                                                                width:
                                                                    120, // Increased width for better proportions
                                                                alignment: Alignment
                                                                    .center, // Center content within the container
                                                                // Adjust margin for overall spacing between the tiles in the Wrap widget
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            8),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            12), // Inner padding for text content
                                                                decoration:
                                                                    BoxDecoration(
                                                                  // Conditional background color based on selection state
                                                                  color: isSelected
                                                                      ? Colors.white // Light purple background for selected
                                                                      : Colors.white, // White background for unselected
                                                                  // Conditional border styling based on selection state
                                                                  border: Border
                                                                      .all(
                                                                    color: isSelected
                                                                        ? appYellow // Use primary color for selected border
                                                                        : Colors.grey.shade300, // Light grey for unselected border
                                                                    width: isSelected
                                                                        ? 2.5
                                                                        : 1.0, // Thicker border when selected
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15), // More rounded corners for a modern look
                                                                  // Conditional box shadow for visual depth and emphasis when selected
                                                                  boxShadow:
                                                                      isSelected
                                                                          ? [
                                                                              BoxShadow(
                                                                                color: Colors.deepPurple.withOpacity(0.25), // Softer, more transparent shadow
                                                                                spreadRadius: 2,
                                                                                blurRadius: 10, // Increased blur for a smoother shadow
                                                                                offset: Offset(0, 5), // Offset for a "lifted" effect
                                                                              ),
                                                                            ]
                                                                          : [
                                                                              // Subtle shadow for unselected tiles to give them some depth
                                                                              BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.1),
                                                                                spreadRadius: 1,
                                                                                blurRadius: 4,
                                                                                offset: Offset(0, 2),
                                                                              ),
                                                                            ],
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min, // Column takes minimum space required by its children
                                                                  children: [
                                                                    // Language Title (e.g., "English", "മലയാളം")
                                                                    Text(
                                                                      homeController
                                                                          .lan[
                                                                              index]
                                                                          .title,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center, // Center align the text
                                                                      style: Get
                                                                          .textTheme
                                                                          .titleMedium!
                                                                          .copyWith(
                                                                        // Use a slightly larger title style
                                                                        fontWeight: isSelected
                                                                            ? FontWeight.bold
                                                                            : FontWeight.w600, // Bold when selected, slightly bold when unselected
                                                                        color: isSelected
                                                                            ? appYellow
                                                                            : Colors.black87, // Primary color when selected, dark grey otherwise
                                                                        fontSize:
                                                                            15.0, // Slightly increased font size
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            6), // Spacing between title and subtitle
                                                                    // Language Subtitle (e.g., "ENGLISH", "MALAYALAM")
                                                                    Text(
                                                                      homeController
                                                                          .lan[
                                                                              index]
                                                                          .subTitle,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center, // Center align the text
                                                                      style: Get
                                                                          .textTheme
                                                                          .bodySmall!
                                                                          .copyWith(
                                                                        // Use a smaller body style for subtitle
                                                                        fontSize:
                                                                            12.0, // Appropriate font size for a subtitle
                                                                        color: isSelected
                                                                            ? Colors.deepPurple.shade600
                                                                            : Colors.grey.shade600, // Softer color for subtitle
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ));
                                                        })),
                                                      );
                                                    }),
                                                  ]))
                                        ],
                                      );
                                    }),
                                  );
                                });
                              });
                        }
                      });
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(
                          Icons.translate,
                          color: Colors.black,
                        )),
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.to(() => CustomerSupportChat());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image.asset(
                          "assets/images/support.png",
                          height: 25,
                          width: 25,
                        ),
                      ))
                ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // global.warningDialog(context);
            await homeController.getBanner();
            await homeController.getBlog();
            await homeController.getAstroNews();
            await homeController.getMyOrder();
            await homeController.getAstrologyVideos();
            await homeController.getClientsTestimonals();
            await homeController.getAllStories();
            await bottomControllerMain.getLiveAstrologerList();
            await astromallController.getAstromallCategory(false);
          },
          child: GetBuilder<BottomNavigationController>(
              builder: (bottomController) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => SearchAstrologerScreen());
                          },
                          child: SizedBox(
                            height: 8.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: FontSizes(context).height02()),
                              margin: EdgeInsets.symmetric(
                                  horizontal: FontSizes(context).width2(),
                                  vertical: FontSizes(context).height1()),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(
                                    FontSizes(context).width4()),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Search',
                                        style: Get
                                            .theme.primaryTextTheme.bodyLarge!
                                            .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Colors.black38,
                                        ),
                                      ).tr(),
                                    ),
                                    Icon(
                                      Icons.search,
                                      size: 20.sp,
                                      color: Color(0xff555555),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Get.to(() => AstrologyServicesPage());
                        },
                        child: Container(
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          width: double.infinity, // Fills the available width
                          // height: 100, // Set a fixed height

                          child: Image.asset(
                            "assets/images/banner2.png",
                            fit: BoxFit
                                .cover, // Makes the image fill the container
                          ),
                        ),
                      ),

                      ///freeservice
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 4.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        Get.to(DailyPredictionInputScreen());
                                        // Get.find<DailyHoroscopeController>()
                                        //     .selectZodic(0);
                                        // await Get.find<
                                        //         DailyHoroscopeController>()
                                        //     .getHoroscopeList(
                                        //         horoscopeId: Get.find<
                                        //                 DailyHoroscopeController>()
                                        //             .signId);
                                        // Get.to(() => DailyHoroscopeScreen());
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                              height: 8.h,
                                              width: 8.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appYellow,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 5.h,
                                                      width: 5.h,
                                                      child: ClipRRect(
                                                        clipBehavior: Clip.none,
                                                        child: Image.asset(
                                                            "assets/images/star.png"),
                                                        // child: CachedNetworkImage(
                                                        //   imageUrl:
                                                        //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.dailyHoroscope)}',
                                                        //   placeholder: (context,
                                                        //           url) =>
                                                        //       const Center(
                                                        //           child:
                                                        //               CircularProgressIndicator()),
                                                        //   errorWidget: (context,
                                                        //           url, error) =>
                                                        //       Icon(
                                                        //           Icons.no_accounts,
                                                        //           size: 20),
                                                        // ),
                                                      ),
                                                    ),
                                                  ),
                                                  // SizedBox(height: 2.w),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Daily\nHoroscope',
                                            textAlign: TextAlign.center,
                                            style: Get
                                                .theme.textTheme.titleSmall!
                                                .copyWith(
                                              height: 1,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0,
                                            ),
                                          ).tr(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),

                                // Column(
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () async {
                                //         Get.find<DailyHoroscopeController>()
                                //             .selectZodic(0);
                                //         await Get.find<
                                //                 DailyHoroscopeController>()
                                //             .getHoroscopeList(
                                //                 horoscopeId: Get.find<
                                //                         DailyHoroscopeController>()
                                //                     .signId);
                                //         Get.to(() => DailyHoroscopeScreen());
                                //       },
                                //       child: Container(
                                //         height: 55,
                                //         // child:
                                //         // FastCachedImage(
                                //         //   url:
                                //         //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.dailyHoroscope)}',
                                //         //   fit: BoxFit.cover,
                                //         //   fadeInDuration:
                                //         //       const Duration(seconds: 1),
                                //         //   errorBuilder:
                                //         //       (context, exception, stacktrace) {
                                //         //     return Icon(Icons.no_accounts);
                                //         //   },
                                //         // ),
                                //         child: CachedNetworkImage(
                                //           imageUrl:
                                //               '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.dailyHoroscope)}',
                                //           placeholder: (context, url) =>
                                //               const Center(
                                //                   child:
                                //                       CircularProgressIndicator()),
                                //           errorWidget: (context, url, error) =>
                                //               Icon(Icons.no_accounts, size: 20),
                                //         ),
                                //       ),
                                //     ),
                                //     Padding(
                                //       padding: const EdgeInsets.only(top: 8.0),
                                //       child: Text(
                                //         'Daily\nHoroscope',
                                //         textAlign: TextAlign.center,
                                //         style: Get.theme.textTheme.titleMedium!
                                //             .copyWith(
                                //           height: 1,
                                //           fontSize: 11,
                                //           fontWeight: FontWeight.w500,
                                //           color: Colors.black,
                                //           letterSpacing: 0,
                                //         ),
                                //       ).tr(),
                                //     ),
                                //   ],
                                // ),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                Column(
                                  children: [
                                    GetBuilder<KundliController>(
                                        builder: (kundliController) {
                                      return GestureDetector(
                                          onTap: () async {
                                            Get.to(KundliInputScreen());
                                            // bool isLogin =
                                            //     await global.isLogin();
                                            // if (isLogin) {
                                            //   global.showOnlyLoaderDialog(
                                            //       Get.context);
                                            //   await kundliController
                                            //       .getKundliList();
                                            //   global.hideLoader();
                                            //   Get.to(() => KundaliScreen());
                                            // }
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 8.h,
                                                width: 8.h,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appYellow,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/kundali.png",
                                                    ),
                                                    // CachedNetworkImage(
                                                    //   height: 5.h,
                                                    //   width: 5.h,
                                                    //   imageUrl:
                                                    //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.freeKundli)}',
                                                    //   placeholder: (context, url) =>
                                                    //       const Center(
                                                    //           child:
                                                    //               CircularProgressIndicator()),
                                                    //   errorWidget: (context, url,
                                                    //           error) =>
                                                    //       Icon(Icons.no_accounts,
                                                    //           size: 20),
                                                    // ),
                                                    // SizedBox(height: 2.w),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Detailed\nKundli', // <--- Changed to match the new key without \n
                                                textAlign: TextAlign.center,
                                                style: Get
                                                    .theme.textTheme.titleSmall!
                                                    .copyWith(
                                                  height: 1,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0,
                                                ),
                                              ).tr(),
                                            ],
                                          ));
                                    }),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  children: [
                                    GetBuilder<KundliController>(
                                        builder: (kundliController) {
                                      return GestureDetector(
                                          onTap: () async {
                                            global.showOnlyLoaderDialog(
                                                Get.context);
                                            await kundliController
                                                .getKundliList();
                                            global.hideLoader();
                                            Get.to(() =>
                                                LoveCompatibilityInputScreen());
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 8.h,
                                                width: 8.h,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appYellow,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        "assets/images/matching.png"),
                                                    // CachedNetworkImage(
                                                    //   height: 5.h,
                                                    //   width: 5.h,
                                                    //   imageUrl:
                                                    //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.kundliMatching)}',
                                                    //   placeholder: (context, url) =>
                                                    //       const Center(
                                                    //           child:
                                                    //               CircularProgressIndicator()),
                                                    //   errorWidget: (context, url,
                                                    //           error) =>
                                                    //       Icon(Icons.no_accounts,
                                                    //           size: 20),
                                                    // ),
                                                    // SizedBox(height: 2.w),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Love\nCompatibility',
                                                textAlign: TextAlign.center,
                                                style: Get
                                                    .theme.textTheme.titleSmall!
                                                    .copyWith(
                                                  height: 1,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0,
                                                ),
                                              ).tr(),
                                            ],
                                          ));
                                    }),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(PlanetInputScreen());
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                              height: 8.h,
                                              width: 8.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appYellow,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 5.h,
                                                      width: 5.h,
                                                      child: ClipRRect(
                                                        clipBehavior: Clip.none,
                                                        child: Icon(Icons.star),
                                                        // child: CachedNetworkImage(
                                                        //   imageUrl:
                                                        //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.dailyHoroscope)}',
                                                        //   placeholder: (context,
                                                        //           url) =>
                                                        //       const Center(
                                                        //           child:
                                                        //               CircularProgressIndicator()),
                                                        //   errorWidget: (context,
                                                        //           url, error) =>
                                                        //       Icon(
                                                        //           Icons.no_accounts,
                                                        //           size: 20),
                                                        // ),
                                                      ),
                                                    ),
                                                  ),
                                                  // SizedBox(height: 2.w),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Planet\nPosition',
                                            textAlign: TextAlign.center,
                                            style: Get
                                                .theme.textTheme.titleSmall!
                                                .copyWith(
                                              height: 1,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0,
                                            ),
                                          ).tr()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),

                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(BirthdayNumberInputScreen());
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                              height: 8.h,
                                              width: 8.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appYellow,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 5.h,
                                                      width: 5.h,
                                                      child: ClipRRect(
                                                        clipBehavior: Clip.none,
                                                        child: Icon(Icons
                                                            .calendar_month),
                                                        // child: CachedNetworkImage(
                                                        //   imageUrl:
                                                        //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.dailyHoroscope)}',
                                                        //   placeholder: (context,
                                                        //           url) =>
                                                        //       const Center(
                                                        //           child:
                                                        //               CircularProgressIndicator()),
                                                        //   errorWidget: (context,
                                                        //           url, error) =>
                                                        //       Icon(
                                                        //           Icons.no_accounts,
                                                        //           size: 20),
                                                        // ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Birthday\nNumber',
                                            textAlign: TextAlign.center,
                                            style: Get
                                                .theme.textTheme.titleSmall!
                                                .copyWith(
                                              height: 1,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0,
                                            ),
                                          ).tr(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Column(
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () async {
                                //         final AstromallController
                                //             astromallController =
                                //             Get.find<AstromallController>();
                                //         astromallController.astroCategory
                                //             .clear();
                                //         astromallController.isAllDataLoaded =
                                //             false;
                                //         astromallController.update();
                                //         global.showOnlyLoaderDialog(context);
                                //         await astromallController
                                //             .getAstromallCategory(false);
                                //         global.hideLoader();
                                //         Get.to(() => AstromallScreen());
                                //       },
                                //       child: Column(
                                //         children: [
                                //           Container(
                                //             height: 8.h,
                                //             width: 8.h,
                                //             decoration: BoxDecoration(
                                //               shape: BoxShape.circle,
                                //               color: appYellow,
                                //             ),
                                //             child: Column(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.center,
                                //               children: [
                                //                 Image.asset("assets/images/shopping.png", height : 30, width :30),
                                //                 SizedBox(height: 2.w),
                                //
                                //               ],
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //     SizedBox(
                                //       height: 10,
                                //     ),
                                //     Text(
                                //       'Shopping',
                                //       textAlign: TextAlign.center,
                                //       style: Get
                                //           .theme.textTheme.titleSmall!
                                //           .copyWith(
                                //         height: 1,
                                //         fontSize: 15.sp,
                                //         fontWeight: FontWeight.w400,
                                //         letterSpacing: 0,
                                //       ),
                                //     ).tr(),
                                //   ],
                                // ),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                // Column(
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () async {
                                //         Get.to(() => CategoryScreen());
                                //       },
                                //       child: Column(
                                //         children: [
                                //           Container(
                                //             height: 8.h,
                                //             width: 8.h,
                                //             decoration: BoxDecoration(
                                //               shape: BoxShape.circle,
                                //               color: appYellow,
                                //             ),
                                //             child: Column(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.center,
                                //               children: [
                                //
                                //                 Image.asset("assets/images/tag.png",
                                //                 height : 30, width :30),
                                //
                                //                 // CachedNetworkImage(
                                //                 //   height: 5.h,
                                //                 //   width: 5.h,
                                //                 //   imageUrl:
                                //                 //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.categories)}',
                                //                 //   placeholder: (context, url) =>
                                //                 //       const Center(
                                //                 //           child:
                                //                 //               CircularProgressIndicator()),
                                //                 //   errorWidget:
                                //                 //       (context, url, error) => Icon(
                                //                 //           Icons.no_accounts,
                                //                 //           size: 20),
                                //                 // ),
                                //                 SizedBox(height: 2.w),
                                //
                                //               ],
                                //             ),
                                //           ),
                                //           SizedBox(
                                //             height: 10,
                                //           ),
                                //           Text(
                                //             'Categories',
                                //             textAlign: TextAlign.center,
                                //             style: Get
                                //                 .theme.textTheme.titleSmall!
                                //                 .copyWith(
                                //               height: 1,
                                //               fontSize: 15.sp,
                                //               fontWeight: FontWeight.w400,
                                //               letterSpacing: 0,
                                //             ),
                                //           ).tr(),
                                //         ],
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                // Column(
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () async {
                                //         BlogController blogController =
                                //             Get.find<BlogController>();
                                //         global.showOnlyLoaderDialog(context);
                                //         blogController.astrologyBlogs = [];
                                //         blogController.astrologyBlogs.clear();
                                //         blogController.isAllDataLoaded = false;
                                //         blogController.update();
                                //         await blogController.getAstrologyBlog(
                                //             "", false);
                                //         global.hideLoader();
                                //         Get.to(() => AstrologyBlogScreen());
                                //       },
                                //       child: Column(
                                //         children: [
                                //           Container(
                                //             height: 8.h,
                                //             width: 8.h,
                                //             decoration: BoxDecoration(
                                //               shape: BoxShape.circle,
                                //               color: appYellow,
                                //             ),
                                //             child: Column(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.center,
                                //               children: [
                                //                 Image.asset("assets/images/blog.png" ,height : 30, width :30),
                                //                 // CachedNetworkImage(
                                //                 //   height: 5.h,
                                //                 //   width: 5.h,
                                //                 //   imageUrl:
                                //                 //       '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.bloc)}',
                                //                 //   placeholder: (context, url) =>
                                //                 //       const Center(
                                //                 //           child:
                                //                 //               CircularProgressIndicator()),
                                //                 //   errorWidget:
                                //                 //       (context, url, error) => Icon(
                                //                 //           Icons.no_accounts,
                                //                 //           size: 20),
                                //                 // ),
                                //                 SizedBox(height: 1.w),
                                //
                                //               ],
                                //             ),
                                //           ),
                                //
                                //           SizedBox(
                                //             height : 10,
                                //           ),
                                //           Text(
                                //             'Blog',
                                //             textAlign: TextAlign.center,
                                //             style: Get
                                //                 .theme.textTheme.titleSmall!
                                //                 .copyWith(
                                //               height: 1,
                                //               fontSize: 15.sp,
                                //               fontWeight: FontWeight.w400,
                                //               letterSpacing: 0,
                                //             ),
                                //           ).tr(),
                                //         ],
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      //--------------------------------------LIVE ASTROLOGER LIST---------------------------------
                      GetBuilder<BottomNavigationController>(builder: (c) {
                        return Get.find<BottomNavigationController>()
                                    .liveAstrologer
                                    .length ==
                                0
                            ? const SizedBox()
                            : SizedBox(
                                height: 38.h,
                                child: Card(
                                  elevation: 0,
                                  margin: EdgeInsets.only(top: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                          FontWeight.w500,
                                                    ),
                                                  ).tr(),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        global
                                                            .showOnlyLoaderDialog(
                                                                context);
                                                        await bottomControllerMain
                                                            .getLiveAstrologerList();
                                                        global.hideLoader();
                                                      },
                                                      child: const Icon(
                                                          Icons.refresh,
                                                          size: 20),
                                                    ),
                                                  ),
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
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.blue[500],
                                                  ),
                                                ).tr(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GetBuilder<BottomNavigationController>(
                                            builder: (c) {
                                          return Expanded(
                                            child: ListView.builder(
                                              itemCount:
                                                  c.liveAstrologer.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.only(
                                                  top: 10, left: 10),
                                              itemBuilder: (context, index) {
                                                final astrologer =
                                                    c.liveAstrologer[index];

                                                return GestureDetector(
                                                  onTap: () async {
                                                    print(
                                                        "📸 Requesting Camera Permission");
                                                    final permissionCamera =
                                                        await Permission.camera
                                                            .request();
                                                    print(
                                                        "🎤 Requesting Microphone Permission");
                                                    final permissionMic =
                                                        await Permission
                                                            .microphone
                                                            .request();

                                                    print(
                                                        "📸 Camera Permission: \${permissionCamera.status}");
                                                    print(
                                                        "🎤 Microphone Permission: \${permissionMic.status}");

                                                    if (!permissionCamera
                                                            .isGranted ||
                                                        !permissionMic
                                                            .isGranted) {
                                                      print(
                                                          "❌ Permission denied. Cannot proceed to LiveAstrologerScreen.");
                                                      Get.snackbar(
                                                          "Permission Required",
                                                          "Camera and Microphone are required for live call.");
                                                      return;
                                                    }
                                                    bottomControllerMain
                                                            .anotherLiveAstrologers =
                                                        c.liveAstrologer
                                                            .where((element) =>
                                                                element
                                                                    .astrologerId !=
                                                                astrologer
                                                                    .astrologerId)
                                                            .toList();
                                                    bottomControllerMain
                                                        .update();

                                                    print(
                                                        '🚀 Navigating to LiveAstrologerScreen');
                                                    print(
                                                        '📡 Channel: ${astrologer.channelName}');
                                                    print(
                                                        '🔐 Token: ${astrologer.token}');
                                                    print(
                                                        '🧙 Astrologer Name: ${astrologer.name}');
                                                    print(
                                                        '🖼️ Profile Image: ${astrologer.profileImage}');
                                                    print(
                                                        '🆔 Astrologer ID: ${astrologer.astrologerId}');
                                                    print(
                                                        '💰 Charge: ${astrologer.charge}');
                                                    print(
                                                        '🎥 Video Call Rate: ${astrologer.videoCallRate}');
                                                    print(
                                                        '❤️ Is Follow: ${astrologer.isFollow}');

                                                    print(
                                                        "🔍 Navigating with data: ${jsonEncode({
                                                          'token':
                                                              astrologer.token,
                                                          'channel': astrologer
                                                              .channelName,
                                                          'name':
                                                              astrologer.name,
                                                          'profile': astrologer
                                                              .profileImage,
                                                          'id': astrologer
                                                              .astrologerId,
                                                          'charge':
                                                              astrologer.charge,
                                                          'videoCallRate':
                                                              astrologer
                                                                  .videoCallRate,
                                                          'isFollow': astrologer
                                                              .isFollow,
                                                        })}");

                                                    await liveController
                                                        .getWaitList(astrologer
                                                            .channelName);
                                                    liveController
                                                            .isImInWaitList =
                                                        liveController.waitList
                                                            .any((e) =>
                                                                e.userId ==
                                                                global
                                                                    .currentUserId);

                                                    liveController
                                                      ..isImInLive = true
                                                      ..isJoinAsChat = false
                                                      ..isLeaveCalled = false
                                                      ..update();

                                                    if (await global
                                                        .isLogin()) {
                                                      Get.to(() =>
                                                          LiveAstrologerScreen(
                                                            token: astrologer
                                                                .token,
                                                            channel: astrologer
                                                                .channelName,
                                                            astrologerName:
                                                                astrologer.name,
                                                            astrologerProfile:
                                                                astrologer
                                                                    .profileImage,
                                                            astrologerId:
                                                                astrologer
                                                                    .astrologerId,
                                                            isFromHome: true,
                                                            charge: astrologer
                                                                .charge,
                                                            isForLiveCallAcceptDecline:
                                                                false,
                                                            isFromNotJoined:
                                                                false,
                                                            isFollow: astrologer
                                                                    .isFollow ??
                                                                false,
                                                            videoCallCharge:
                                                                astrologer
                                                                    .videoCallRate,
                                                          ));
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              FontSizes(context)
                                                                  .width2()),
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                FontSizes(
                                                                        context)
                                                                    .width1()),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius
                                                              .circular(FontSizes(
                                                                      context)
                                                                  .width2()),
                                                          child: astrologer
                                                                  .profileImage
                                                                  .isNotEmpty
                                                              ? Container(
                                                                  width: 120,
                                                                  height: 200,
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              4),
                                                                  child: Image
                                                                      .network(
                                                                    "${global.imgBaseurl}${astrologer.profileImage}",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    colorBlendMode:
                                                                        BlendMode
                                                                            .darken,
                                                                    color: Colors
                                                                        .black45,
                                                                    width: FontSizes(
                                                                            context)
                                                                        .width30(),
                                                                    height: FontSizes(
                                                                            context)
                                                                        .height20(),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  width: 120,
                                                                  height: 200,
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.3),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    border: Border.all(
                                                                        color: const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            214,
                                                                            214,
                                                                            214)),
                                                                    image:
                                                                        const DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: AssetImage(
                                                                          Images
                                                                              .deafultUser),
                                                                      colorFilter: ColorFilter.mode(
                                                                          Colors
                                                                              .black45,
                                                                          BlendMode
                                                                              .darken),
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                        Positioned(
                                                          right:
                                                              FontSizes(context)
                                                                  .width2(),
                                                          top:
                                                              FontSizes(context)
                                                                  .height01(),
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal: FontSizes(
                                                                        context)
                                                                    .width2()),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(FontSizes(
                                                                          context)
                                                                      .width2()),
                                                              color: Get.theme
                                                                  .primaryColor,
                                                            ),
                                                            child: CustomText(
                                                              text: "Live",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: whiteColor,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          left:
                                                              FontSizes(context)
                                                                  .width2(),
                                                          bottom:
                                                              FontSizes(context)
                                                                  .height1(),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              CustomText(
                                                                text: astrologer
                                                                    .name,
                                                                color:
                                                                    whiteColor,
                                                                maxLine: 1,
                                                                fontsize: FontSizes(
                                                                        context)
                                                                    .font4(),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                              CustomText(
                                                                text:
                                                                    "${astrologer.videoCallRate} /min",
                                                                color: Get.theme
                                                                    .primaryColor,
                                                                maxLine: 1,
                                                                fontsize: FontSizes(
                                                                        context)
                                                                    .font3(),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                      }),

                      bottomNavigationController.astrologerList.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Top 100 astrologers',
                                        style: Get
                                            .theme.primaryTextTheme.titleMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          bottomController.bottomNavIndex = 1;
                                          bottomController.update();
                                        },
                                        child: Text(
                                          'View All',
                                          style: Get
                                              .theme.primaryTextTheme.bodySmall!
                                              .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Offstage(),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      bottomNavigationController.astrologerList.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: SizedBox(
                                height: FontSizes(context).height20() *
                                    1, // Slightly taller container
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: bottomNavigationController
                                      .astrologerList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing:
                                        FontSizes(context).width2() *
                                            1, // Double the original spacing
                                    mainAxisExtent: FontSizes(context)
                                        .width30(), // Using your original width30
                                  ),
                                  itemBuilder: (context, index) {
                                    final astrologer =
                                        bottomNavigationController
                                            .astrologerList[index];
                                    return InkWell(
                                      onTap: () async {
                                        Get.find<ReviewController>()
                                            .getReviewData(astrologer.id!);
                                        global.showOnlyLoaderDialog(context);
                                        await bottomNavigationController
                                            .getAstrologerbyId(astrologer.id!);
                                        global.hideLoader();
                                        await Get.to(() =>
                                            AstrologerProfile(index: index));
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: FontSizes(context)
                                                    .width30() *
                                                0.8, // Slightly smaller than width30
                                            width:
                                                FontSizes(context).width30() *
                                                    0.8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      FontSizes(context)
                                                              .width30() /
                                                          2),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '${global.imgBaseurl}${astrologer.profileImage}',
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  Images.deafultUser,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            astrologer.name ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize:
                                                  FontSizes(context).font03(),
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Offstage(),
                      //---------- Categories  ----------------------------------------
                      // Container(
                      //   margin: EdgeInsets.symmetric(horizontal: 20),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Text(
                      //             'Categories',
                      //             style: Get.theme.primaryTextTheme.titleMedium!
                      //                 .copyWith(fontWeight: FontWeight.w500),
                      //           ).tr(),
                      //           GestureDetector(
                      //             onTap: () {
                      //               Get.to(() => CategoryScreen());
                      //             },
                      //             child: Text(
                      //               'View All',
                      //               style: Get.theme.primaryTextTheme.bodySmall!
                      //                   .copyWith(
                      //                 fontWeight: FontWeight.w400,
                      //                 color: Colors.black,
                      //               ),
                      //             ).tr(),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: FontSizes(context).height2(),
                      // ),
                      //
                      // GetBuilder<AstrologerCategoryController>(
                      //     builder: (astrologyCat) {
                      //       return Container(
                      //           height: 12.h,
                      //           margin: EdgeInsets.symmetric(
                      //               horizontal: FontSizes(context).width3()),
                      //           child: ListView.builder(
                      //               scrollDirection: Axis.horizontal,
                      //               itemCount: astrologyCat.categoryList.length,
                      //               shrinkWrap: true,
                      //               itemBuilder: (context, index) {
                      //                 return InkWell(
                      //                   onTap: () async {
                      //                     global.showOnlyLoaderDialog(context);
                      //                     bottomNavigationController
                      //                         .astrologerList = [];
                      //                     bottomNavigationController.astrologerList
                      //                         .clear();
                      //                     bottomNavigationController
                      //                         .isAllDataLoaded = false;
                      //                     bottomNavigationController.update();
                      //                     chatController.isSelected = index;
                      //                     chatController.update();
                      //                     await bottomNavigationController.astroCat(
                      //                         id: astrologyCat
                      //                             .categoryList[index].id!,
                      //                         isLazyLoading: false);
                      //                     global.hideLoader();
                      //                     Navigator.push(
                      //                         context,
                      //                         MaterialPageRoute(
                      //                             builder: (context) => CallScreen(
                      //                               flag: 1,
                      //                             )));
                      //                   },
                      //                   child: Container(
                      //                     alignment: Alignment.center,
                      //                     margin:
                      //                     EdgeInsets.symmetric(horizontal: 10),
                      //                     child: Column(
                      //                       crossAxisAlignment:
                      //                       CrossAxisAlignment.center,
                      //                       children: [
                      //                         CircleAvatar(
                      //                           backgroundColor: Colors.white,
                      //                           radius: FontSizes(context).width7(),
                      //                           backgroundImage: NetworkImage(
                      //                               "${global.imgBaseurl}${astrologyCat.categoryList[index].image}"),
                      //                         ),
                      //                         SizedBox(
                      //                           height:
                      //                           FontSizes(context).height1(),
                      //                         ),
                      //                         CustomText(
                      //                           text:
                      //                           "${astrologyCat.categoryList[index].name}",
                      //                           textAlign: TextAlign.center,
                      //                           maxLine: 2,
                      //                           fontWeight: FontWeight.w600,
                      //                           fontsize:
                      //                           FontSizes(context).font3(),
                      //                         )
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 );
                      //               }));
                      //     }),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// First Card (Chat With Astrologer)
                            GestureDetector(
                                onTap: () async {
                                  global.showOnlyLoaderDialog(context);
                                  bottomController.astrologerList = [];
                                  bottomController.isAllDataLoaded = false;
                                  bottomController.update();
                                  await bottomController.getAstrologerList(
                                      isLazyLoading: false);
                                  global.hideLoader();
                                  bottomController.setBottomIndex(1, 0);
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.27,
                                  constraints: BoxConstraints(
                                    maxWidth: 300,
                                    minWidth: 180,
                                  ),
                                  padding:
                                      EdgeInsets.all(16), // Increased padding
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: appYellow, width: 1.5),
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(
                                            0.2), // Stronger shadow
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center, // Center all content
                                    children: [
                                      // Text Section (Centered)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: appYellow.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6), // Better padding
                                        child: Text(
                                          "Live chat with",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12, // Larger font
                                            color: Colors.grey.shade800,
                                          ),
                                        ).tr(),
                                      ),
                                      SizedBox(height: 8), // Consistent spacing
                                      Text(
                                        "Astrologer",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 18, // Larger and bolder
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ).tr(),
                                      SizedBox(
                                          height:
                                              12), // More space before image
                                      // Centered Image
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        constraints: BoxConstraints(
                                            maxWidth: 70), // Larger image
                                        child: Image.asset(
                                          "assets/images/chat3.png",
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),

                            SizedBox(
                              width: 5,
                            ),

                            /// Second Column with 2 buttons
                            Expanded(
                              child: Column(
                                children: [
                                  GestureDetector(
                                      onTap: () async {
                                        global.showOnlyLoaderDialog(context);
                                        bottomController.astrologerList = [];
                                        bottomController.isAllDataLoaded =
                                            false;
                                        bottomController.update();
                                        await bottomController
                                            .getAstrologerList(
                                                isLazyLoading: false);
                                        global.hideLoader();
                                        bottomController.setBottomIndex(2, 0);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.27,
                                        constraints: BoxConstraints(
                                          maxWidth: 300,
                                          minWidth: 180,
                                        ),
                                        padding: EdgeInsets.all(
                                            16), // Increased padding for better spacing
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: appYellow, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.2), // Slightly stronger shadow
                                              spreadRadius: 1,
                                              blurRadius: 6, // Softer blur
                                              offset:
                                                  Offset(0, 3), // More depth
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center, // Center all content
                                          children: [
                                            // Text Section (Now Centered)
                                            Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    appYellow.withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              child: Text(
                                                "Talk to an",
                                                textAlign: TextAlign
                                                    .center, // Add this
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ).tr(),
                                            ),
                                            SizedBox(
                                                height:
                                                    8), // Consistent spacing
                                            Text(
                                              "Astrologer",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 18, // Slightly larger
                                                fontWeight: FontWeight
                                                    .w700, // Bold for emphasis
                                                color: Colors.black,
                                              ),
                                            ).tr(),
                                            SizedBox(
                                                height:
                                                    12), // More space before image
                                            // Centered Image
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      70), // Larger but constrained
                                              child: Image.asset(
                                                "assets/images/call1.jpg",
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  // GestureDetector(
                                  //   onTap: () {
                                  //     Get.to(() => AstrologyServicesPage());
                                  //   },
                                  //   child: Container(
                                  //     width: MediaQuery.of(context).size.width * 0.7,
                                  //
                                  //
                                  //
                                  //     decoration: BoxDecoration(
                                  //       border: Border.all(color: appYellow, width: 2),
                                  //       borderRadius: BorderRadius.circular(20),
                                  //     ),
                                  //
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.all(4),
                                  //       child: Column(
                                  //         crossAxisAlignment: CrossAxisAlignment.start,
                                  //         children: const [
                                  //           Text("Cosmic Insights" , style: TextStyle(
                                  //             fontSize:   14,
                                  //           ),),
                                  //           SizedBox(height: 5),
                                  //           Text(
                                  //             "All Services",
                                  //             style: TextStyle(
                                  //               fontSize: 14,
                                  //               fontWeight: FontWeight.bold,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        )),
                      ),

                      ///Stories

                      // GetBuilder<HomeController>(builder: (homeController) {
                      //   return Column(
                      //     children: [
                      //       homeController.allStories.length == 0
                      //           ? SizedBox()
                      //           : Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   vertical: 10, horizontal: 10),
                      //               child: Row(
                      //                 children: [
                      //                   Text(
                      //                     'Astro Stories',
                      //                     style: Get.theme.primaryTextTheme
                      //                         .titleMedium!
                      //                         .copyWith(
                      //                             fontWeight: FontWeight.w500),
                      //                   ).tr(),
                      //                 ],
                      //               ),
                      //             ),
                      //       homeController.allStories.length == 0
                      //           ? SizedBox()
                      //           : Container(
                      //               margin: EdgeInsets.only(left: 10),
                      //               height: 100,
                      //               child: ListView.builder(
                      //                   shrinkWrap: false,
                      //                   itemCount:
                      //                       homeController.allStories.length,
                      //                   scrollDirection: Axis.horizontal,
                      //                   itemBuilder: (context, index) {
                      //                     return Container(
                      //                       margin: EdgeInsets.only(left: 4),
                      //                       child: InkWell(
                      //                           onTap: () {
                      //                             homeController
                      //                                 .getAstroStory(
                      //                                     homeController
                      //                                         .allStories[index]
                      //                                         .astrologerId
                      //                                         .toString())
                      //                                 .then((value) {
                      //                               Navigator.of(context).push(
                      //                                 MaterialPageRoute(
                      //                                     builder: (context) =>
                      //                                         ViewStoriesScreen(
                      //                                           profile:
                      //                                               "${global.imgBaseurl}${homeController.allStories[index].profileImage}",
                      //                                           name: homeController
                      //                                               .allStories[
                      //                                                   index]
                      //                                               .name
                      //                                               .toString(),
                      //                                           isprofile:
                      //                                               false,
                      //                                           astroId: int.parse(homeController
                      //                                               .allStories[
                      //                                                   index]
                      //                                               .astrologerId
                      //                                               .toString()),
                      //                                         )),
                      //                               );
                      //                             });
                      //                           },
                      //                           child: Column(
                      //                             children: [
                      //                               CircleAvatar(
                      //                                 radius: 30,
                      //                                 backgroundColor: homeController
                      //                                             .allStories[
                      //                                                 index]
                      //                                             .allStoriesViewed
                      //                                             .toString() ==
                      //                                         "1"
                      //                                     ? Colors.grey
                      //                                     : Colors.red,
                      //                                 child: CircleAvatar(
                      //                                   radius: 27,
                      //                                   backgroundColor:
                      //                                       Colors.yellow,
                      //                                   backgroundImage:
                      //                                       NetworkImage(
                      //                                           "${global.imgBaseurl}${homeController.allStories[index].profileImage}"),
                      //                                 ),
                      //                               ),
                      //                               SizedBox(
                      //                                 width: 16.w,
                      //                                 child: Text(
                      //                                   homeController
                      //                                       .allStories[index]
                      //                                       .name
                      //                                       .toString(),
                      //                                   maxLines: 1,
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   style: TextStyle(
                      //                                       fontSize: 15.sp),
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           )),
                      //                     );
                      //                   }),
                      //             ),
                      //     ],
                      //   );
                      // }),
                      //--------------------------------------TOP BANNER-----------------------------------------------------------------------------
                      // Container(
                      //   margin: EdgeInsets.symmetric(
                      //       horizontal: FontSizes(context).width2()),
                      //   height: FontSizes(context).height23(),
                      //   child: PageView.builder(
                      //     controller: _pageController,
                      //     itemCount: 1,
                      //     onPageChanged: (page) {
                      //       setState(() {
                      //         _pageIndex = page;
                      //       });
                      //     },
                      //     itemBuilder: (context, index) {
                      //       return Container(
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(15),
                      //               border: Border.all(
                      //                   color: colorGrey.withOpacity(0.4))),
                      //           margin: EdgeInsets.only(
                      //               bottom: screenHeight(context) * 0.02,
                      //               top: screenHeight(context) * 0.01),
                      //           child: Image.network(
                      //             '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.TopBanner)}',
                      //             fit: BoxFit.fill,
                      //           ));
                      //     },
                      //   ),
                      // ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(
                            1,
                            (index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: _pageIndex == index
                                      ? Get.theme.primaryColor
                                      : colorGrey),
                            ),
                          )
                        ],
                      ),
                      //--------------------------------ASTROLOGER BLOCK------------------------------------------------------------------------------------
                      // GetBuilder<HomeController>(builder: (homeController) {
                      //   return homeController.bannerList.isEmpty
                      //       ? const SizedBox()
                      //       : Container(
                      //           margin: EdgeInsets.symmetric(horizontal: 10),
                      //           child: ImageSlideshow(
                      //             isLoop: true,
                      //             autoPlayInterval: 3000,
                      //             width: double.infinity,
                      //             height: 25.h,
                      //             initialPage: 0,
                      //             children: List.generate(
                      //                 homeController.bannerList.length,
                      //                 (index) {
                      //               return GestureDetector(
                      //                 onTap: () async {
                      //                   if (homeController
                      //                           .bannerList[index].bannerType ==
                      //                       'Astrologer') {
                      //                     global.showOnlyLoaderDialog(context);
                      //                     bottomController.astrologerList = [];
                      //                     bottomController.astrologerList
                      //                         .clear();
                      //                     bottomController.isAllDataLoaded =
                      //                         false;
                      //                     bottomController.update();
                      //                     await bottomController
                      //                         .getAstrologerList(
                      //                             isLazyLoading: false);
                      //                     global.hideLoader();
                      //                     bottomController.setBottomIndex(1, 0);
                      //                   } else if (homeController
                      //                           .bannerList[index].bannerType ==
                      //                       'Astroshop') {
                      //                     final AstromallController
                      //                         astromallController =
                      //                         Get.find<AstromallController>();
                      //                     astromallController.astroCategory
                      //                         .clear();
                      //                     astromallController.isAllDataLoaded =
                      //                         false;
                      //                     astromallController.update();
                      //                     global.showOnlyLoaderDialog(context);
                      //                     await astromallController
                      //                         .getAstromallCategory(false);
                      //                     global.hideLoader();
                      //                     Get.to(() => AstromallScreen());
                      //                   } else {}
                      //                 },
                      //                 //                       child:
                      //                 // FastCachedImage(
                      //                 //                         url:
                      //                 //                             '${global.imgBaseurl}${homeController.bannerList[index].bannerImage}',
                      //                 //                         fit: BoxFit.cover,
                      //                 //                         fadeInDuration:
                      //                 //                             const Duration(seconds: 1),
                      //                 //                         errorBuilder:
                      //                 //                             (context, exception, stacktrace) {
                      //                 //                           return Icon(Icons.no_accounts);
                      //                 //                         },
                      //                 //                       ),
                      //                 child: CachedNetworkImage(
                      //                   imageUrl: kIsWeb
                      //                       ? 'https://corsproxy.io/?${global.imgBaseurl}${homeController.bannerList[index].bannerImage}'
                      //                       : '${global.imgBaseurl}${homeController.bannerList[index].bannerImage}',
                      //                   imageBuilder: (context, imageProvider) {
                      //                     return homeController
                      //                             .checkBannerValid(
                      //                       startDate: homeController
                      //                           .bannerList[index].fromDate,
                      //                       endDate: homeController
                      //                           .bannerList[index].toDate,
                      //                     )
                      //                         ? Card(
                      //                             child: Container(
                      //                               height: Get.height * 0.2,
                      //                               width: Get.width,
                      //                               decoration: BoxDecoration(
                      //                                 borderRadius:
                      //                                     BorderRadius.circular(
                      //                                         10),
                      //                                 image: DecorationImage(
                      //                                   fit: BoxFit.cover,
                      //                                   image: imageProvider,
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                           )
                      //                         : Container(
                      //                             color: Colors.green,
                      //                           );
                      //                   },
                      //                   placeholder: (context, url) => Center(
                      //                       child: CircularProgressIndicator()),
                      //                   errorWidget: (context, url, error) =>
                      //                       Card(
                      //                           child: SizedBox(
                      //                     child: Container(
                      //                       color: Colors.grey.shade400,
                      //                       child: Center(
                      //                         child: Column(
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.center,
                      //                           children: [
                      //                             Icon(
                      //                               Icons.error,
                      //                               color: Colors.red,
                      //                               size: 30.sp,
                      //                             ),
                      //                             Text(
                      //                               'banner Loading error',
                      //                               style: TextStyle(
                      //                                 fontSize: 14.sp,
                      //                                 fontWeight:
                      //                                     FontWeight.w400,
                      //                               ),
                      //                             )
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   )),
                      //                 ),
                      //               );
                      //             }),
                      //           ),
                      //         );
                      // }),
                      GetBuilder<HomeController>(builder: (homeController) {
                        return homeController.myOrders.isEmpty
                            ? const SizedBox()
                            : SizedBox(
                                height: 160,
                                child: Card(
                                  elevation: 0,
                                  margin: EdgeInsets.only(top: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'My orders',
                                                    style: Get
                                                        .theme
                                                        .primaryTextTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                  ).tr(),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  final HistoryController
                                                      historyController =
                                                      Get.find<
                                                          HistoryController>();
                                                  global.showOnlyLoaderDialog(
                                                      context);
                                                  await historyController
                                                      .getPaymentLogs(
                                                          global.currentUserId!,
                                                          false);
                                                  historyController
                                                      .walletTransactionList = [];
                                                  historyController
                                                      .walletTransactionList
                                                      .clear();
                                                  historyController
                                                          .walletAllDataLoaded =
                                                      false;
                                                  historyController.update();
                                                  await historyController
                                                      .getWalletTransaction(
                                                          global.currentUserId!,
                                                          false);
                                                  historyController
                                                      .astroMallHistoryList = [];
                                                  historyController
                                                      .astroMallHistoryList
                                                      .clear();
                                                  historyController
                                                      .isAllDataLoaded = false;
                                                  historyController.update();
                                                  await historyController
                                                      .getAstroMall(
                                                          global.currentUserId!,
                                                          false);
                                                  historyController
                                                      .callHistoryList = [];
                                                  historyController
                                                      .callHistoryList
                                                      .clear();
                                                  historyController
                                                          .callAllDataLoaded =
                                                      false;
                                                  historyController.update();
                                                  await historyController
                                                      .getCallHistory(
                                                          global.currentUserId!,
                                                          false);
                                                  historyController
                                                      .chatHistoryList = [];
                                                  historyController
                                                      .chatHistoryList
                                                      .clear();
                                                  historyController
                                                          .chatAllDataLoaded =
                                                      false;
                                                  historyController.update();
                                                  await historyController
                                                      .getChatHistory(
                                                          global.currentUserId!,
                                                          false);
                                                  global.hideLoader();
                                                  bottomController
                                                      .setBottomIndex(4, 0);
                                                },
                                                child: Text(
                                                  'View All',
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.blue[500],
                                                  ),
                                                ).tr(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GetBuilder<HomeController>(
                                          builder: (c) {
                                            return Expanded(
                                              child: ListView.builder(
                                                itemCount: homeController
                                                    .myOrders.length,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding: EdgeInsets.only(
                                                    top: 5, left: 10),
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                      onTap: () async {
                                                        if (homeController
                                                                .myOrders[index]
                                                                .orderType ==
                                                            "call") {
                                                          if (homeController
                                                                  .myOrders[
                                                                      index]
                                                                  .callId !=
                                                              0) {
                                                            IntakeController
                                                                intakeController =
                                                                Get.find<
                                                                    IntakeController>();
                                                            HistoryController
                                                                historyController =
                                                                Get.find<
                                                                    HistoryController>();
                                                            global
                                                                .showOnlyLoaderDialog(
                                                                    context);
                                                            await intakeController
                                                                .getFormIntakeData();
                                                            await historyController
                                                                .getCallHistoryById(
                                                                    homeController
                                                                        .myOrders[
                                                                            index]
                                                                        .callId!);
                                                            global.hideLoader();
                                                            Get.to(() =>
                                                                CallHistoryDetailScreen(
                                                                  astrologerId: homeController
                                                                      .myOrders[
                                                                          index]
                                                                      .astrologerId!,
                                                                  astrologerProfile:
                                                                      homeController
                                                                              .myOrders[index]
                                                                              .profileImage ??
                                                                          "",
                                                                  index: index,
                                                                  callType: homeController
                                                                          .myOrders[
                                                                              index]
                                                                          .call_type ??
                                                                      0,
                                                                ));
                                                          }
                                                        } else if (homeController
                                                                .myOrders[index]
                                                                .orderType ==
                                                            "chat") {
                                                          if (homeController
                                                                  .myOrders[
                                                                      index]
                                                                  .firebaseChatId !=
                                                              "") {
                                                            ChatController
                                                                chatController =
                                                                Get.find<
                                                                    ChatController>();
                                                            global
                                                                .showOnlyLoaderDialog(
                                                                    context);
                                                            await chatController
                                                                .getuserReview(
                                                                    homeController
                                                                        .myOrders[
                                                                            index]
                                                                        .astrologerId!);
                                                            global.hideLoader();
                                                            Get.to(() =>
                                                                AcceptChatScreen(
                                                                  flagId: 0,
                                                                  profileImage:
                                                                      homeController
                                                                              .myOrders[index]
                                                                              .profileImage ??
                                                                          "",
                                                                  astrologerName: homeController
                                                                          .myOrders[
                                                                              index]
                                                                          .astrologerName ??
                                                                      "Astrologer",
                                                                  fireBasechatId: homeController
                                                                      .myOrders[
                                                                          index]
                                                                      .firebaseChatId!,
                                                                  astrologerId: homeController
                                                                      .myOrders[
                                                                          index]
                                                                      .astrologerId!,
                                                                  chatId: homeController
                                                                      .myOrders[
                                                                          index]
                                                                      .id!,
                                                                  duration: int.parse(homeController
                                                                              .myOrders[index]
                                                                              .totalMin ??
                                                                          "100")
                                                                      .toString(),
                                                                ));
                                                          } else {
                                                            log("firbaseid null");
                                                          }
                                                        }
                                                      },
                                                      child: Card(
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height: 65,
                                                              width: 65,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Get
                                                                        .theme
                                                                        .primaryColor),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 35,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                child: homeController
                                                                            .myOrders[
                                                                                index]
                                                                            .profileImage ==
                                                                        ""
                                                                    ? Image
                                                                        .asset(
                                                                        Images
                                                                            .deafultUser,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        height:
                                                                            50,
                                                                        width:
                                                                            40,
                                                                      )
                                                                    : CachedNetworkImage(
                                                                        imageUrl:
                                                                            '${global.imgBaseurl}${homeController.myOrders[index].profileImage}',
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const Center(child: CircularProgressIndicator()),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
                                                                          Images
                                                                              .deafultUser,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              40,
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text('${homeController.myOrders[index].astrologerName}')
                                                                      .tr(),
                                                                  Text(
                                                                    DateConverter.dateTimeStringToDateOnly(homeController
                                                                        .myOrders[
                                                                            index]
                                                                        .createdAt
                                                                        .toString()),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            10),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 1.h,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          if (homeController.myOrders[index].orderType ==
                                                                              "call") {
                                                                            if (homeController.myOrders[index].callId !=
                                                                                0) {
                                                                              IntakeController intakeController = Get.find<IntakeController>();
                                                                              HistoryController historyController = Get.find<HistoryController>();
                                                                              global.showOnlyLoaderDialog(context);
                                                                              await intakeController.getFormIntakeData();
                                                                              await historyController.getCallHistoryById(homeController.myOrders[index].callId!);
                                                                              global.hideLoader();
                                                                              Get.to(() => CallHistoryDetailScreen(
                                                                                    astrologerId: homeController.myOrders[index].astrologerId!,
                                                                                    astrologerProfile: homeController.myOrders[index].profileImage ?? "",
                                                                                    index: index,
                                                                                    callType: homeController.myOrders[index].call_type ?? 10,
                                                                                  ));
                                                                            }
                                                                          } else if (homeController.myOrders[index].orderType ==
                                                                              "chat") {
                                                                            if (homeController.myOrders[index].firebaseChatId !=
                                                                                "") {
                                                                              ChatController chatController = Get.find<ChatController>();
                                                                              global.showOnlyLoaderDialog(context);
                                                                              await chatController.getuserReview(homeController.myOrders[index].astrologerId!);
                                                                              global.hideLoader();
                                                                              Get.to(() => AcceptChatScreen(
                                                                                    flagId: 0,
                                                                                    profileImage: homeController.myOrders[index].profileImage ?? "",
                                                                                    astrologerName: homeController.myOrders[index].astrologerName ?? "Astrologer",
                                                                                    fireBasechatId: homeController.myOrders[index].firebaseChatId!,
                                                                                    astrologerId: homeController.myOrders[index].astrologerId!,
                                                                                    chatId: homeController.myOrders[index].id!,
                                                                                    duration: int.parse(homeController.myOrders[index].totalMin ?? "100").toString(),
                                                                                  ));
                                                                            }
                                                                          }
                                                                        },
                                                                        child: CircleAvatar(
                                                                            radius:
                                                                                13,
                                                                            child: homeController.myOrders[index].orderType == "call"
                                                                                ? Icon(Icons.play_arrow, size: 13)
                                                                                : Icon(Icons.message, size: 13)),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            global.showOnlyLoaderDialog(context);
                                                                            final BottomNavigationController
                                                                                bottomNavigationController =
                                                                                Get.find<BottomNavigationController>();
                                                                            Get.find<ReviewController>().getReviewData(homeController.myOrders[index].astrologerId ??
                                                                                0);
                                                                            await bottomNavigationController.getAstrologerbyId(homeController.myOrders[index].astrologerId ??
                                                                                0);
                                                                            global.hideLoader();
                                                                            if (bottomNavigationController.astrologerbyId.isNotEmpty) {
                                                                              Get.to(() => AstrologerProfile(
                                                                                    index: index,
                                                                                  ));
                                                                            }
                                                                          },
                                                                          child:
                                                                              CircleAvatar(
                                                                            radius:
                                                                                13,
                                                                            child:
                                                                                Icon(
                                                                              Icons.call,
                                                                              size: 13,
                                                                            ),
                                                                          )),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ));
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
                      //--------------------------------------LIVE ASTROLOGER LIST---------------------------------
                      GetBuilder<BottomNavigationController>(builder: (c) {
                        return Get.find<BottomNavigationController>()
                                    .liveAstrologer
                                    .length ==
                                0
                            ? const SizedBox()
                            : SizedBox(
                                height: 38.h,
                                child: Card(
                                  elevation: 0,
                                  margin: EdgeInsets.only(top: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                                FontWeight
                                                                    .w500),
                                                  ).tr(),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        global
                                                            .showOnlyLoaderDialog(
                                                                context);
                                                        await bottomControllerMain
                                                            .getLiveAstrologerList();
                                                        global.hideLoader();
                                                      },
                                                      child: Icon(
                                                        Icons.refresh,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () async {
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
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.blue[500],
                                                  ),
                                                ).tr(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GetBuilder<BottomNavigationController>(
                                          builder: (c) {
                                            return Expanded(
                                              child: ListView.builder(
                                                itemCount: Get.find<
                                                        BottomNavigationController>()
                                                    .liveAstrologer
                                                    .length,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding: EdgeInsets.only(
                                                    top: 10, left: 10),
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                      onTap: () async {
                                                        bottomControllerMain
                                                            .anotherLiveAstrologers = Get
                                                                .find<
                                                                    BottomNavigationController>()
                                                            .liveAstrologer
                                                            .where((element) =>
                                                                element
                                                                    .astrologerId !=
                                                                Get.find<
                                                                        BottomNavigationController>()
                                                                    .liveAstrologer[
                                                                        index]
                                                                    .astrologerId)
                                                            .toList();
                                                        bottomControllerMain
                                                            .update();
                                                        print("channel name");
                                                        print(
                                                            "${Get.find<BottomNavigationController>().liveAstrologer[index].channelName}");
                                                        await liveController
                                                            .getWaitList(Get.find<
                                                                    BottomNavigationController>()
                                                                .liveAstrologer[
                                                                    index]
                                                                .channelName);
                                                        int index2 = liveController
                                                            .waitList
                                                            .indexWhere((element) =>
                                                                element
                                                                    .userId ==
                                                                global
                                                                    .currentUserId);
                                                        if (index2 != -1) {
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
                                                            .isImInLive = true;
                                                        liveController
                                                                .isJoinAsChat =
                                                            false;
                                                        liveController
                                                                .isLeaveCalled =
                                                            false;
                                                        liveController.update();
                                                        bool isLogin =
                                                            await global
                                                                .isLogin();
                                                        if (isLogin) {
                                                          Get.to(
                                                            () =>
                                                                LiveAstrologerScreen(
                                                              token: Get.find<
                                                                      BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .token,
                                                              channel: Get.find<
                                                                      BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .channelName,
                                                              astrologerName: Get
                                                                      .find<
                                                                          BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .name,
                                                              astrologerProfile: Get
                                                                      .find<
                                                                          BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .profileImage,
                                                              astrologerId: Get
                                                                      .find<
                                                                          BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .astrologerId,
                                                              isFromHome: true,
                                                              charge: Get.find<
                                                                      BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .charge,
                                                              isForLiveCallAcceptDecline:
                                                                  false,
                                                              isFromNotJoined:
                                                                  false,
                                                              isFollow: Get.find<
                                                                      BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .isFollow!,
                                                              videoCallCharge: Get
                                                                      .find<
                                                                          BottomNavigationController>()
                                                                  .liveAstrologer[
                                                                      index]
                                                                  .videoCallRate,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(FontSizes(
                                                                          context)
                                                                      .width2())),
                                                          margin: EdgeInsets.symmetric(
                                                              horizontal:
                                                                  FontSizes(
                                                                          context)
                                                                      .width1()),
                                                          child: Stack(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: BorderRadius
                                                                    .circular(FontSizes(
                                                                            context)
                                                                        .width2()),
                                                                child: Get.find<BottomNavigationController>()
                                                                            .liveAstrologer[index]
                                                                            .profileImage !=
                                                                        ""
                                                                    ? Container(
                                                                        width:
                                                                            120,
                                                                        height:
                                                                            200,
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                4),
                                                                        child:
                                                                            Image(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          colorBlendMode:
                                                                              BlendMode.darken,
                                                                          color:
                                                                              Colors.black45,
                                                                          width:
                                                                              FontSizes(context).width30(),
                                                                          height:
                                                                              FontSizes(context).height20(),
                                                                          image:
                                                                              NetworkImage(
                                                                            "${global.imgBaseurl}${Get.find<BottomNavigationController>().liveAstrologer[index].profileImage}",
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        //NO image then it will set
                                                                        width:
                                                                            120,
                                                                        height:
                                                                            200,
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                4),
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
                                                              ),
                                                              Positioned(
                                                                right: FontSizes(
                                                                        context)
                                                                    .width2(),
                                                                top: FontSizes(
                                                                        context)
                                                                    .height01(),
                                                                child:
                                                                    Container(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal: FontSizes(context)
                                                                                .width2()),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(FontSizes(context)
                                                                                .width2()),
                                                                            color: Get
                                                                                .theme.primaryColor),
                                                                        child:
                                                                            CustomText(
                                                                          text:
                                                                              "Live",
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              whiteColor,
                                                                        )),
                                                              ),
                                                              Positioned(
                                                                left: FontSizes(
                                                                        context)
                                                                    .width2(),
                                                                bottom: FontSizes(
                                                                        context)
                                                                    .height1(),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    CustomText(
                                                                      text:
                                                                          "${Get.find<BottomNavigationController>().liveAstrologer[index].name}",
                                                                      color:
                                                                          whiteColor,
                                                                      maxLine:
                                                                          1,
                                                                      fontsize:
                                                                          FontSizes(context)
                                                                              .font4(),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                    CustomText(
                                                                      text:
                                                                          "${Get.find<BottomNavigationController>().liveAstrologer[index].videoCallRate} /min",
                                                                      color: Get
                                                                          .theme
                                                                          .primaryColor,
                                                                      maxLine:
                                                                          1,
                                                                      fontsize:
                                                                          FontSizes(context)
                                                                              .font3(),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          )));
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

                      //---------- ASTROLOGERS BLOCK----------------------------------------

                      // GetBuilder<BottomNavigationController>(
                      //     builder: (bottomNavigationController) {
                      //       return bottomNavigationController.astrologerList.isEmpty
                      //           ? const SizedBox()
                      //           : SizedBox(
                      //         height: 34.h,
                      //         child: Card(
                      //           elevation: 0,
                      //           margin: EdgeInsets.only(top: 6),
                      //           shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.zero),
                      //           child: Padding(
                      //             padding: const EdgeInsets.only(
                      //                 top: 10, bottom: 5),
                      //             child: Column(
                      //               crossAxisAlignment:
                      //               CrossAxisAlignment.start,
                      //               children: [
                      //                 Padding(
                      //                   padding: const EdgeInsets.symmetric(
                      //                       horizontal: 10),
                      //                   child: Row(
                      //                     mainAxisAlignment:
                      //                     MainAxisAlignment.spaceBetween,
                      //                     children: [
                      //                       Container(
                      //                         margin: EdgeInsets.symmetric(
                      //                             horizontal:
                      //                             FontSizes(context)
                      //                                 .width3()),
                      //                         child: Column(
                      //                           crossAxisAlignment:
                      //                           CrossAxisAlignment.start,
                      //                           children: [
                      //                             Text(
                      //                               'Astrologers',
                      //                               style: Get
                      //                                   .theme
                      //                                   .primaryTextTheme
                      //                                   .titleMedium!
                      //                                   .copyWith(
                      //                                   fontWeight:
                      //                                   FontWeight
                      //                                       .w500),
                      //                             ).tr(),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       GestureDetector(
                      //                         onTap: () {
                      //                           bottomController
                      //                               .bottomNavIndex = 1;
                      //                           bottomController.update();
                      //                         },
                      //                         child: Text(
                      //                           'View All',
                      //                           style: Get
                      //                               .theme
                      //                               .primaryTextTheme
                      //                               .bodySmall!
                      //                               .copyWith(
                      //                             fontWeight: FontWeight.w400,
                      //                             color: Colors.black,
                      //                           ),
                      //                         ).tr(),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 SizedBox(
                      //                   height: 2.w,
                      //                 ),
                      //                 Container(
                      //                   decoration: BoxDecoration(
                      //                       border: Border.all(
                      //                         color: Colors.black,
                      //                       )
                      //                   ),
                      //                   height: FontSizes(context).height15(),
                      //                   child: GridView.builder(
                      //                       scrollDirection: Axis.horizontal,
                      //                       shrinkWrap: true,
                      //                       itemCount:
                      //                       bottomNavigationController
                      //                           .astrologerList.length,
                      //                       gridDelegate:
                      //                       SliverGridDelegateWithFixedCrossAxisCount(
                      //                         crossAxisSpacing:
                      //                         FontSizes(context)
                      //                             .height01(),
                      //                         mainAxisSpacing:
                      //                         FontSizes(context).width2(),
                      //                         mainAxisExtent:
                      //                         FontSizes(context)
                      //                             .width70(),
                      //                         crossAxisCount: 1,
                      //                       ),
                      //                       itemBuilder: (context, index) {
                      //                         return InkWell(
                      //                           onTap: () async {
                      //                             Get.find<ReviewController>()
                      //                                 .getReviewData(
                      //                                 bottomNavigationController
                      //                                     .astrologerList[
                      //                                 index]
                      //                                     .id!);
                      //                             global.showOnlyLoaderDialog(
                      //                                 context);
                      //                             await bottomNavigationController
                      //                                 .getAstrologerbyId(
                      //                                 bottomNavigationController
                      //                                     .astrologerList[
                      //                                 index]
                      //                                     .id!);
                      //                             global.hideLoader();
                      //                             await Get.to(
                      //                                     () => AstrologerProfile(
                      //                                   index: index,
                      //                                 ));
                      //                           },
                      //                           child: Container(
                      //                             child: Row(
                      //                               crossAxisAlignment:
                      //                               CrossAxisAlignment
                      //                                   .start,
                      //                               children: [
                      //                                 Container(
                      //                                     width:
                      //                                     FontSizes(context)
                      //                                         .width25(),
                      //                                     decoration: BoxDecoration(
                      //                                         borderRadius: BorderRadius
                      //                                             .circular(FontSizes(
                      //                                             context)
                      //                                             .width4()),
                      //                                         color: lightGrey),
                      //                                     child: ClipRRect(
                      //                                       borderRadius: BorderRadius
                      //                                           .circular(FontSizes(
                      //                                           context)
                      //                                           .width4()),
                      //                                       child:
                      //                                       CachedNetworkImage(
                      //                                         imageUrl:
                      //                                         '${global.imgBaseurl}${bottomNavigationController.astrologerList[index].profileImage}',
                      //                                         placeholder: (context,
                      //                                             url) =>
                      //                                         const Center(
                      //                                             child:
                      //                                             CircularProgressIndicator()),
                      //                                         errorWidget: (context,
                      //                                             url,
                      //                                             error) =>
                      //                                             Image.asset(
                      //                                               Images
                      //                                                   .deafultUser,
                      //                                               fit: BoxFit
                      //                                                   .cover,
                      //                                               height: 50,
                      //                                               width: 40,
                      //                                             ),
                      //                                       ),
                      //                                     )),
                      //                                 SizedBox(
                      //                                   width:
                      //                                   FontSizes(context)
                      //                                       .width2(),
                      //                                 ),
                      //                                 Expanded(
                      //                                   child: Column(
                      //                                     crossAxisAlignment:
                      //                                     CrossAxisAlignment
                      //                                         .start,
                      //                                     children: [
                      //                                       CustomText(
                      //                                         text: bottomNavigationController
                      //                                             .astrologerList[
                      //                                         index]
                      //                                             .name!,
                      //                                         fontWeight:
                      //                                         FontWeight
                      //                                             .w600,
                      //                                         overflow:
                      //                                         TextOverflow
                      //                                             .ellipsis,
                      //                                         color: blackColor,
                      //                                         fontsize: FontSizes(
                      //                                             context)
                      //                                             .font04(),
                      //                                         maxLine: 1,
                      //                                       ),
                      //                                       CustomText(
                      //                                         text:
                      //                                         '${bottomNavigationController.astrologerList[index].primarySkill}',
                      //                                         fontWeight:
                      //                                         FontWeight
                      //                                             .w500,
                      //                                         color: colorGrey,
                      //                                         overflow:
                      //                                         TextOverflow
                      //                                             .ellipsis,
                      //                                         fontsize: FontSizes(
                      //                                             context)
                      //                                             .font03(),
                      //                                         maxLine: 1,
                      //                                       ),
                      //                                       CustomText(
                      //                                         text:
                      //                                         '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${bottomNavigationController.astrologerList[index].charge}/min',
                      //                                         decoration:
                      //                                         TextDecoration
                      //                                             .lineThrough,
                      //                                         fontWeight:
                      //                                         FontWeight
                      //                                             .w500,
                      //                                         color: colorGrey,
                      //                                         overflow:
                      //                                         TextOverflow
                      //                                             .ellipsis,
                      //                                         fontsize: FontSizes(
                      //                                             context)
                      //                                             .font03(),
                      //                                         maxLine: 1,
                      //                                       ),
                      //                                       SizedBox(
                      //                                         height: FontSizes(
                      //                                             context)
                      //                                             .height1(),
                      //                                       ),
                      //                                       Row(
                      //                                         mainAxisAlignment:
                      //                                         MainAxisAlignment
                      //                                             .spaceBetween,
                      //                                         children: [
                      //                                           CustomText(
                      //                                             text:
                      //                                             '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${bottomNavigationController.astrologerList[index].charge}/min',
                      //                                             fontWeight:
                      //                                             FontWeight
                      //                                                 .w500,
                      //                                             color:
                      //                                             greenColor,
                      //                                             overflow:
                      //                                             TextOverflow
                      //                                                 .ellipsis,
                      //                                             fontsize: FontSizes(
                      //                                                 context)
                      //                                                 .font4(),
                      //                                             maxLine: 1,
                      //                                           ),
                      //                                           Container(
                      //                                             decoration: BoxDecoration(
                      //                                                 color:
                      //                                                 greenColor,
                      //                                                 borderRadius:
                      //                                                 BorderRadius.circular(
                      //                                                     FontSizes(context).width6())),
                      //                                             padding: EdgeInsets.symmetric(
                      //                                                 vertical:
                      //                                                 FontSizes(context)
                      //                                                     .height1(),
                      //                                                 horizontal:
                      //                                                 FontSizes(context)
                      //                                                     .width6()),
                      //                                             child:
                      //                                             CustomText(
                      //                                               text:
                      //                                               "Connect",
                      //                                               fontsize: FontSizes(
                      //                                                   context)
                      //                                                   .font03(),
                      //                                               fontWeight:
                      //                                               FontWeight
                      //                                                   .w400,
                      //                                               color:
                      //                                               whiteColor,
                      //                                             ),
                      //                                           )
                      //                                         ],
                      //                                       )
                      //                                     ],
                      //                                   ),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           ),
                      //                         );
                      //                       }),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }),

                      // GetBuilder<AstromallController>(
                      //     builder: (astromallController) {
                      //   return astromallController.astroCategory.length == 0
                      //       ? SizedBox()
                      //       : SizedBox(
                      //           height: 200,
                      //           child: Card(
                      //             elevation: 0,
                      //             margin: EdgeInsets.only(top: 6),
                      //             shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.zero),
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(
                      //                   top: 10, bottom: 1),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Padding(
                      //                     padding: const EdgeInsets.symmetric(
                      //                         horizontal: 10),
                      //                     child: Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.spaceBetween,
                      //                       children: [
                      //                         Container(
                      //                           margin: EdgeInsets.symmetric(
                      //                               horizontal: 5),
                      //                           child: Column(
                      //                             crossAxisAlignment:
                      //                                 CrossAxisAlignment.start,
                      //                             children: [
                      //                               Text(
                      //                                 'Shop Now',
                      //                                 style: Get
                      //                                     .theme
                      //                                     .primaryTextTheme
                      //                                     .titleMedium!
                      //                                     .copyWith(
                      //                                         fontWeight:
                      //                                             FontWeight
                      //                                                 .w500),
                      //                               ).tr(),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                         GestureDetector(
                      //                           onTap: () async {
                      //                             final AstromallController
                      //                                 astromallController =
                      //                                 Get.find<
                      //                                     AstromallController>();
                      //                             astromallController
                      //                                 .astroCategory
                      //                                 .clear();
                      //                             astromallController
                      //                                 .isAllDataLoaded = false;
                      //                             astromallController.update();
                      //                             global.showOnlyLoaderDialog(
                      //                                 context);
                      //                             await astromallController
                      //                                 .getAstromallCategory(
                      //                                     false);
                      //                             global.hideLoader();
                      //                             Get.to(
                      //                                 () => AstromallScreen());
                      //                           },
                      //                           child: Text(
                      //                             'View All',
                      //                             style: Get
                      //                                 .theme
                      //                                 .primaryTextTheme
                      //                                 .bodySmall!
                      //                                 .copyWith(
                      //                               fontWeight: FontWeight.w400,
                      //                               color: Colors.blue[500],
                      //                             ),
                      //                           ).tr(),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                   Expanded(
                      //                       child: ListView.builder(
                      //                     itemCount: astromallController
                      //                         .astroCategory.length,
                      //                     shrinkWrap: true,
                      //                     scrollDirection: Axis.horizontal,
                      //                     padding: EdgeInsets.only(
                      //                         top: 10,
                      //                         left: 10,
                      //                         bottom: 2,
                      //                         right: 10),
                      //                     itemBuilder: (context, index) {
                      //                       return GestureDetector(
                      //                         onTap: () async {
                      //                           global.showOnlyLoaderDialog(
                      //                               context);
                      //                           astromallController.astroProduct
                      //                               .clear();
                      //                           astromallController
                      //                                   .isAllDataLoadedForProduct =
                      //                               false;
                      //                           astromallController
                      //                                   .productCatId =
                      //                               astromallController
                      //                                   .astroCategory[index]
                      //                                   .id;
                      //                           astromallController.update();
                      //                           await astromallController
                      //                               .getAstromallProduct(
                      //                                   astromallController
                      //                                       .astroCategory[
                      //                                           index]
                      //                                       .id,
                      //                                   false);
                      //                           global.hideLoader();
                      //                           Get.to(
                      //                             () => AstroProductScreen(
                      //                               appbarTitle:
                      //                                   astromallController
                      //                                       .astroCategory[
                      //                                           index]
                      //                                       .name,
                      //                               productCategoryId:
                      //                                   astromallController
                      //                                       .astroCategory[
                      //                                           index]
                      //                                       .id,
                      //                               sliderImage:
                      //                                   "${global.imgBaseurl}${astromallController.astroCategory[index].categoryImage}",
                      //                             ),
                      //                           );
                      //                         },
                      //                         child: Container(
                      //                           width: 90,
                      //                           margin: const EdgeInsets.only(
                      //                               top: 4,
                      //                               bottom: 1,
                      //                               right: 5),
                      //                           child: Column(
                      //                             mainAxisSize:
                      //                                 MainAxisSize.min,
                      //                             children: [
                      //                               Expanded(
                      //                                   child: CircleAvatar(
                      //                                 backgroundColor:
                      //                                     Colors.white,
                      //                                 radius: 35.sp,
                      //                                 backgroundImage: NetworkImage(
                      //                                     "${global.imgBaseurl}${astromallController.astroCategory[index].categoryImage}"),
                      //                               )),
                      //                               Container(
                      //                                 color: Colors.white,
                      //                                 width: Get.width,
                      //                                 height: 45,
                      //                                 alignment:
                      //                                     Alignment.center,
                      //                                 padding:
                      //                                     const EdgeInsets.all(
                      //                                         8),
                      //                                 child: Text(
                      //                                   astromallController
                      //                                       .astroCategory[
                      //                                           index]
                      //                                       .name,
                      //                                   textAlign:
                      //                                       TextAlign.center,
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   style: Get.textTheme
                      //                                       .bodyMedium!
                      //                                       .copyWith(
                      //                                           fontSize: 11,
                      //                                           color: Colors
                      //                                               .black,
                      //                                           fontWeight:
                      //                                               FontWeight
                      //                                                   .w500),
                      //                                 ).tr(),
                      //                               )
                      //                             ],
                      //                           ),
                      //                         ),
                      //                       );
                      //                     },
                      //                   ))
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      // }),
                      //---------- LATEST BLOG ----------------------------------------
                      // SizedBox(
                      //   height: FontSizes(context).height1(),
                      // ),
                      // GetBuilder<HomeController>(
                      //   builder: (homeController) {
                      //     return homeController.blogList.length == 0
                      //         ? SizedBox()
                      //         : SizedBox(
                      //             height: 250,
                      //             child: Card(
                      //               elevation: 0,
                      //               margin: EdgeInsets.only(top: 6),
                      //               shape: RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.zero),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.only(
                      //                     top: 10, bottom: 5),
                      //                 child: Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.start,
                      //                   children: [
                      //                     Padding(
                      //                       padding: const EdgeInsets.symmetric(
                      //                           horizontal: 10),
                      //                       child: Row(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment
                      //                                 .spaceBetween,
                      //                         children: [
                      //                           Text(
                      //                             'Latest from blog',
                      //                             style: Get
                      //                                 .theme
                      //                                 .primaryTextTheme
                      //                                 .titleMedium!
                      //                                 .copyWith(
                      //                                     fontWeight:
                      //                                         FontWeight.w500),
                      //                           ).tr(),
                      //                           GestureDetector(
                      //                             onTap: () async {
                      //                               BlogController
                      //                                   blogController =
                      //                                   Get.find<
                      //                                       BlogController>();
                      //                               global.showOnlyLoaderDialog(
                      //                                   context);
                      //                               blogController
                      //                                   .astrologyBlogs = [];
                      //                               blogController
                      //                                   .astrologyBlogs
                      //                                   .clear();
                      //                               blogController
                      //                                       .isAllDataLoaded =
                      //                                   false;
                      //                               blogController.update();
                      //                               await blogController
                      //                                   .getAstrologyBlog(
                      //                                       "", false);
                      //                               global.hideLoader();
                      //                               Get.to(() =>
                      //                                   AstrologyBlogScreen());
                      //                             },
                      //                             child: Text(
                      //                               'View All',
                      //                               style: Get
                      //                                   .theme
                      //                                   .primaryTextTheme
                      //                                   .bodySmall!
                      //                                   .copyWith(
                      //                                 fontWeight:
                      //                                     FontWeight.w400,
                      //                                 color: Colors.blue[500],
                      //                               ),
                      //                             ).tr(),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                     Expanded(child:
                      //                         GetBuilder<HomeController>(
                      //                             builder: (homeControllerr) {
                      //                       return ListView.builder(
                      //                         itemCount: homeController
                      //                             .blogList.length,
                      //                         shrinkWrap: true,
                      //                         scrollDirection: Axis.horizontal,
                      //                         padding: const EdgeInsets.only(
                      //                             top: 10,
                      //                             left: 10,
                      //                             bottom: 10),
                      //                         itemBuilder: (context, index) {
                      //                           return GestureDetector(
                      //                             onTap: () async {
                      //                               global.showOnlyLoaderDialog(
                      //                                   context);
                      //                               await homeController
                      //                                   .incrementBlogViewer(
                      //                                       homeController
                      //                                           .blogList[index]
                      //                                           .id);
                      //                               homeController
                      //                                   .homeBlogVideo(
                      //                                       homeController
                      //                                           .blogList[index]
                      //                                           .blogImage);
                      //                               global.hideLoader();
                      //                               Get.to(() =>
                      //                                   AstrologyBlogDetailScreen(
                      //                                     image:
                      //                                         "${homeController.blogList[index].blogImage}",
                      //                                     title: homeController
                      //                                         .blogList[index]
                      //                                         .title,
                      //                                     description:
                      //                                         homeController
                      //                                             .blogList[
                      //                                                 index]
                      //                                             .description!,
                      //                                     extension:
                      //                                         homeController
                      //                                             .blogList[
                      //                                                 index]
                      //                                             .extension!,
                      //                                     controller: homeController
                      //                                         .homeVideoPlayerController,
                      //                                   ));
                      //                             },
                      //                             child: Card(
                      //                               elevation: 4,
                      //                               margin:
                      //                                   const EdgeInsets.only(
                      //                                       right: 12),
                      //                               shape:
                      //                                   RoundedRectangleBorder(
                      //                                 borderRadius:
                      //                                     BorderRadius.circular(
                      //                                         20),
                      //                               ),
                      //                               child: Container(
                      //                                 width: 200,
                      //                                 decoration: BoxDecoration(
                      //                                   color: Colors.white,
                      //                                   borderRadius:
                      //                                       BorderRadius
                      //                                           .circular(20),
                      //                                 ),
                      //                                 child: Column(
                      //                                   crossAxisAlignment:
                      //                                       CrossAxisAlignment
                      //                                           .start,
                      //                                   mainAxisSize:
                      //                                       MainAxisSize.min,
                      //                                   children: [
                      //                                     Stack(children: [
                      //                                       ClipRRect(
                      //                                           borderRadius:
                      //                                               const BorderRadius
                      //                                                   .only(
                      //                                             topLeft: Radius
                      //                                                 .circular(
                      //                                                     10),
                      //                                             topRight: Radius
                      //                                                 .circular(
                      //                                                     10),
                      //                                           ),
                      //                                           child: homeController.blogList[index].extension ==
                      //                                                       'mp4' ||
                      //                                                   homeController.blogList[index].extension ==
                      //                                                       'gif'
                      //                                               ? Stack(
                      //                                                   alignment:
                      //                                                       Alignment.center,
                      //                                                   children: [
                      //                                                     CachedNetworkImage(
                      //                                                       imageUrl:
                      //                                                           '${global.imgBaseurl}${homeController.blogList[index].previewImage}',
                      //                                                       imageBuilder: (context, imageProvider) =>
                      //                                                           Container(
                      //                                                         height: 110,
                      //                                                         width: Get.width,
                      //                                                         decoration: BoxDecoration(
                      //                                                           borderRadius: BorderRadius.circular(10),
                      //                                                           image: DecorationImage(
                      //                                                             fit: BoxFit.fill,
                      //                                                             image: imageProvider,
                      //                                                           ),
                      //                                                         ),
                      //                                                       ),
                      //                                                       placeholder: (context, url) =>
                      //                                                           const Center(child: CircularProgressIndicator()),
                      //                                                       errorWidget: (context, url, error) =>
                      //                                                           Image.asset(
                      //                                                         Images.blog,
                      //                                                         height: Get.height * 0.15,
                      //                                                         width: Get.width,
                      //                                                         fit: BoxFit.fill,
                      //                                                       ),
                      //                                                     ),
                      //                                                     Icon(
                      //                                                       Icons.play_arrow,
                      //                                                       size:
                      //                                                           40,
                      //                                                       color:
                      //                                                           Colors.white,
                      //                                                     ),
                      //                                                   ],
                      //                                                 )
                      //                                               : CachedNetworkImage(
                      //                                                   imageUrl:
                      //                                                       '${global.imgBaseurl}${homeController.blogList[index].blogImage}',
                      //                                                   imageBuilder:
                      //                                                       (context, imageProvider) =>
                      //                                                           Container(
                      //                                                     height:
                      //                                                         110,
                      //                                                     width:
                      //                                                         Get.width,
                      //                                                     decoration:
                      //                                                         BoxDecoration(
                      //                                                       borderRadius:
                      //                                                           BorderRadius.circular(10),
                      //                                                       image:
                      //                                                           DecorationImage(
                      //                                                         fit: BoxFit.fill,
                      //                                                         image: imageProvider,
                      //                                                       ),
                      //                                                     ),
                      //                                                   ),
                      //                                                   placeholder:
                      //                                                       (context, url) =>
                      //                                                           const Center(child: CircularProgressIndicator()),
                      //                                                   errorWidget: (context,
                      //                                                           url,
                      //                                                           error) =>
                      //                                                       Image.asset(
                      //                                                     Images
                      //                                                         .blog,
                      //                                                     height:
                      //                                                         Get.height * 0.15,
                      //                                                     width:
                      //                                                         Get.width,
                      //                                                     fit: BoxFit
                      //                                                         .fill,
                      //                                                   ),
                      //                                                 )),
                      //                                       Positioned(
                      //                                         right: 7,
                      //                                         child:
                      //                                             ElevatedButton(
                      //                                                 style: ElevatedButton
                      //                                                     .styleFrom(
                      //                                                   padding:
                      //                                                       EdgeInsets.zero,
                      //                                                   backgroundColor: Colors
                      //                                                       .white
                      //                                                       .withOpacity(0.5),
                      //                                                   elevation:
                      //                                                       0,
                      //                                                   minimumSize: const Size(
                      //                                                       50,
                      //                                                       30), //height
                      //                                                   maximumSize: const Size(
                      //                                                       60,
                      //                                                       30), //width
                      //                                                   shape: RoundedRectangleBorder(
                      //                                                       borderRadius:
                      //                                                           BorderRadius.circular(50.0)),
                      //                                                 ),
                      //                                                 onPressed:
                      //                                                     () {},
                      //                                                 child:
                      //                                                     Row(
                      //                                                   mainAxisAlignment:
                      //                                                       MainAxisAlignment.center,
                      //                                                   crossAxisAlignment:
                      //                                                       CrossAxisAlignment.center,
                      //                                                   children: [
                      //                                                     const Icon(
                      //                                                       Icons.visibility,
                      //                                                       size:
                      //                                                           20,
                      //                                                       color:
                      //                                                           Colors.black,
                      //                                                     ),
                      //                                                     Padding(
                      //                                                       padding:
                      //                                                           EdgeInsets.only(left: 5.0),
                      //                                                       child:
                      //                                                           Text(
                      //                                                         "${homeController.blogList[index].viewer}",
                      //                                                         style: TextStyle(fontSize: 12, color: Colors.black),
                      //                                                       ),
                      //                                                     )
                      //                                                   ],
                      //                                                 )),
                      //                                       )
                      //                                     ]),
                      //                                     Padding(
                      //                                       padding:
                      //                                           const EdgeInsets
                      //                                               .only(
                      //                                               left: 5,
                      //                                               right: 5,
                      //                                               top: 3,
                      //                                               bottom: 3),
                      //                                       child: Column(
                      //                                         crossAxisAlignment:
                      //                                             CrossAxisAlignment
                      //                                                 .start,
                      //                                         mainAxisSize:
                      //                                             MainAxisSize
                      //                                                 .min,
                      //                                         children: [
                      //                                           SizedBox(
                      //                                             height: 42,
                      //                                             child:
                      //                                                 Padding(
                      //                                               padding: const EdgeInsets
                      //                                                   .only(
                      //                                                   bottom:
                      //                                                       8.0),
                      //                                               child: Text(
                      //                                                 homeController
                      //                                                     .blogList[
                      //                                                         index]
                      //                                                     .title,
                      //                                                 textAlign:
                      //                                                     TextAlign
                      //                                                         .start,
                      //                                                 style: Get
                      //                                                     .theme
                      //                                                     .textTheme
                      //                                                     .titleMedium!
                      //                                                     .copyWith(
                      //                                                   fontSize:
                      //                                                       13,
                      //                                                   fontWeight:
                      //                                                       FontWeight.w500,
                      //                                                   letterSpacing:
                      //                                                       0,
                      //                                                 ),
                      //                                               ).tr(),
                      //                                             ),
                      //                                           ),
                      //                                           Row(
                      //                                             mainAxisAlignment:
                      //                                                 MainAxisAlignment
                      //                                                     .spaceBetween,
                      //                                             children: [
                      //                                               SizedBox(
                      //                                                 child:
                      //                                                     Text(
                      //                                                   homeController
                      //                                                       .blogList[index]
                      //                                                       .author,
                      //                                                   textAlign:
                      //                                                       TextAlign.center,
                      //                                                   style: Get
                      //                                                       .theme
                      //                                                       .textTheme
                      //                                                       .titleMedium!
                      //                                                       .copyWith(
                      //                                                     fontSize:
                      //                                                         10,
                      //                                                     fontWeight:
                      //                                                         FontWeight.w500,
                      //                                                     color:
                      //                                                         Colors.grey[700],
                      //                                                     letterSpacing:
                      //                                                         0,
                      //                                                   ),
                      //                                                 ).tr(),
                      //                                               ),
                      //                                               Text(
                      //                                                 "${DateFormat("MMM d,yyyy").format(DateTime.parse(homeController.blogList[index].createdAt))}",
                      //                                                 textAlign:
                      //                                                     TextAlign
                      //                                                         .center,
                      //                                                 style: Get
                      //                                                     .theme
                      //                                                     .textTheme
                      //                                                     .titleMedium!
                      //                                                     .copyWith(
                      //                                                   fontSize:
                      //                                                       10,
                      //                                                   fontWeight:
                      //                                                       FontWeight.w500,
                      //                                                   color: Colors
                      //                                                       .grey[700],
                      //                                                   letterSpacing:
                      //                                                       0,
                      //                                                 ),
                      //                                               ),
                      //                                             ],
                      //                                           ),
                      //                                         ],
                      //                                       ),
                      //                                     ),
                      //                                   ],
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                           );
                      //                         },
                      //                       );
                      //                     }))
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //   },
                      // ),
                      //---------------------BEHIND THE SCHENE-------------------------------
                      // GetBuilder<HomeController>(builder: (homeController) {
                      //   return SizedBox(
                      //     height: 34.h,
                      //     child: Card(
                      //       elevation: 0,
                      //       margin: EdgeInsets.only(top: 6),
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.zero),
                      //       child: Padding(
                      //         padding: const EdgeInsets.only(top: 2, bottom: 5),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Container(
                      //               margin:
                      //                   EdgeInsets.symmetric(horizontal: 20),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     'Behind the scene',
                      //                     style: Get.theme.primaryTextTheme
                      //                         .titleMedium!
                      //                         .copyWith(
                      //                             fontWeight: FontWeight.w500),
                      //                   ).tr(),
                      //                 ],
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               height: 190,
                      //               width: Get.width,
                      //               child: Stack(
                      //                 alignment: Alignment.center,
                      //                 children: [
                      //                   homeController.videoPlayerController!
                      //                           .value.isInitialized
                      //                       ? Card(
                      //                           margin: EdgeInsets.only(
                      //                               left: 10,
                      //                               right: 10,
                      //                               top: 10),
                      //                           elevation: 5,
                      //                           shape: RoundedRectangleBorder(
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       15)),
                      //                           child: SizedBox(
                      //                             height: 200,
                      //                             width: Get.width,
                      //                             child: ClipRRect(
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       10),
                      //                               child: AspectRatio(
                      //                                 aspectRatio: homeController
                      //                                     .videoPlayerController!
                      //                                     .value
                      //                                     .aspectRatio,
                      //                                 child: VideoPlayerWidget(
                      //                                   controller: homeController
                      //                                       .videoPlayerController!,
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         )
                      //                       : SizedBox(),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // }),

                      GestureDetector(
                        onTap: () {
                          Get.to(AddmoneyToWallet());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            decoration: BoxDecoration(
                              color: appYellow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Wrap text in Flexible to avoid overflow
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        4.0), // You can adjust the padding as needed
                                    child: Text(
                                      "Recharge your wallet to speak with an astrologer",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ).tr(), // Assuming you're using easy_localization
                                  ),
                                ),

                                Icon(Icons.double_arrow),
                              ],
                            ),
                          ),
                        ),
                      ),

                      ///Customer experience
                      GetBuilder<HomeController>(builder: (homeController) {
                        return homeController.clientReviews.length == 0
                            ? SizedBox()
                            : Container(
                                // height: 50.h,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Customer's Experience",
                                            style: Get.theme.primaryTextTheme
                                                .titleMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ).tr(),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal:
                                              FontSizes(context).width3()),
                                      height: FontSizes(context).height37(),
                                      child: GridView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: homeController
                                              .clientReviews.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisSpacing:
                                                FontSizes(context).height01(),
                                            mainAxisSpacing:
                                                FontSizes(context).width2(),
                                            mainAxisExtent:
                                                FontSizes(context).width70(),
                                            crossAxisCount: 2,
                                          ),
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: EdgeInsets.only(
                                                top: FontSizes(context)
                                                    .height01(),
                                                bottom: FontSizes(context)
                                                    .height01(),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: FontSizes(context)
                                                      .width2(),
                                                  vertical: FontSizes(context)
                                                      .height1()),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          FontSizes(context)
                                                              .width4()),
                                                  color: whiteColor,
                                                  border: Border.all(
                                                      color: Get
                                                          .theme.primaryColor,
                                                      width: 0.1),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Get
                                                            .theme.primaryColor
                                                            .withOpacity(0.7),
                                                        offset: Offset(
                                                          0.1,
                                                          0.1,
                                                        ),
                                                        blurRadius: 0.1,
                                                        spreadRadius: 0.1),
                                                  ]),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      homeController
                                                                      .clientReviews[
                                                                          index]
                                                                      .profile
                                                                      .toString() ==
                                                                  "" ||
                                                              homeController
                                                                      .clientReviews[
                                                                          index]
                                                                      .profile
                                                                      .toString() ==
                                                                  "null"
                                                          ? CircleAvatar(
                                                              radius: FontSizes(
                                                                      context)
                                                                  .width10(),
                                                              backgroundImage:
                                                                  AssetImage(Images
                                                                      .deafultUser))
                                                          : CircleAvatar(
                                                              radius: FontSizes(
                                                                      context)
                                                                  .width10(),
                                                              backgroundImage: CachedNetworkImageProvider(
                                                                  "${global.imgBaseurl}${homeController.clientReviews[index].profile}",
                                                                  errorListener: (e) =>
                                                                      AssetImage(
                                                                          Images
                                                                              .deafultUser)),
                                                            ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: FontSizes(context)
                                                        .width2(),
                                                  ),
                                                  Expanded(
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
                                                            CustomText(
                                                              text:
                                                                  "${homeController.clientReviews[index].name}",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color: blackColor,
                                                              fontsize: FontSizes(
                                                                      context)
                                                                  .font04(),
                                                              maxLine: 1,
                                                            ),
                                                            Icon(
                                                              Icons.more_vert,
                                                              color: blackColor,
                                                              size: FontSizes(
                                                                      context)
                                                                  .width4(),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              FontSizes(context)
                                                                  .height1(),
                                                        ),
                                                        CustomText(
                                                          text:
                                                              "${homeController.clientReviews[index].review}",
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: blackColor,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontsize:
                                                              FontSizes(context)
                                                                  .font04(),
                                                          maxLine: 2,
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              FontSizes(context)
                                                                  .height1(),
                                                        ),
                                                        InkWell(
                                                          onTap: () async {
                                                            global
                                                                .showOnlyLoaderDialog(
                                                                    context);
                                                            await homeController
                                                                .getClientsTestimonals();
                                                            global.hideLoader();
                                                            Get.to(() =>
                                                                ClientsReviewScreen());
                                                          },
                                                          child: CustomText(
                                                            text: "More",
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                orangeColor,
                                                            color: Get.theme
                                                                .primaryColor,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontsize: FontSizes(
                                                                    context)
                                                                .font04(),
                                                            maxLine: 2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              );
                      }),

                      ///astro in news
                      // GetBuilder<HomeController>(builder: (homeController) {
                      //   return homeController.astroNews.length == 0
                      //       ? SizedBox()
                      //       : SizedBox(
                      //           height: 266,
                      //           child: Card(
                      //             elevation: 0,
                      //             margin: EdgeInsets.only(top: 6),
                      //             shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.zero),
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(
                      //                   top: 10, bottom: 5),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Padding(
                      //                     padding: const EdgeInsets.symmetric(
                      //                         horizontal: 10),
                      //                     child: Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.spaceBetween,
                      //                       children: [
                      //                         Container(
                      //                           margin: EdgeInsets.symmetric(
                      //                               horizontal: 10),
                      //                           child: Column(
                      //                             crossAxisAlignment:
                      //                                 CrossAxisAlignment.start,
                      //                             children: [
                      //                               Text(
                      //                                 '${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)} in News',
                      //                                 style: Get
                      //                                     .theme
                      //                                     .primaryTextTheme
                      //                                     .titleMedium!
                      //                                     .copyWith(
                      //                                         fontWeight:
                      //                                             FontWeight
                      //                                                 .w500),
                      //                               ).tr(),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                         GestureDetector(
                      //                           onTap: () {
                      //                             Get.to(() =>
                      //                                 AstrologerNewsScreen());
                      //                           },
                      //                           child: Text(
                      //                             'View All',
                      //                             style: Get
                      //                                 .theme
                      //                                 .primaryTextTheme
                      //                                 .bodySmall!
                      //                                 .copyWith(
                      //                               fontWeight: FontWeight.w400,
                      //                               color: Colors.blue[500],
                      //                             ),
                      //                           ).tr(),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                   Expanded(
                      //                       child: ListView.builder(
                      //                     itemCount:
                      //                         homeController.astroNews.length,
                      //                     shrinkWrap: true,
                      //                     scrollDirection: Axis.horizontal,
                      //                     padding: EdgeInsets.only(
                      //                         top: 10, left: 10, bottom: 10),
                      //                     itemBuilder: (context, index) {
                      //                       return GestureDetector(
                      //                         onTap: () {
                      //                           Get.to(() => BlogScreen(
                      //                                 link: homeController
                      //                                     .astroNews[index]
                      //                                     .link,
                      //                               ));
                      //                         },
                      //                         child: Card(
                      //                           elevation: 4,
                      //                           margin:
                      //                               EdgeInsets.only(right: 12),
                      //                           shape: RoundedRectangleBorder(
                      //                             borderRadius:
                      //                                 BorderRadius.circular(20),
                      //                           ),
                      //                           child: Container(
                      //                             width: 190,
                      //                             decoration: BoxDecoration(
                      //                               color: Colors.white,
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       20),
                      //                             ),
                      //                             child: Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment
                      //                                       .start,
                      //                               children: [
                      //                                 ClipRRect(
                      //                                   borderRadius:
                      //                                       BorderRadius.only(
                      //                                     topLeft:
                      //                                         Radius.circular(
                      //                                             20),
                      //                                     topRight:
                      //                                         Radius.circular(
                      //                                             20),
                      //                                   ),
                      //                                   child:
                      //                                       CachedNetworkImage(
                      //                                     imageUrl:
                      //                                         '${global.imgBaseurl}${homeController.astroNews[index].bannerImage}',
                      //                                     imageBuilder: (context,
                      //                                             imageProvider) =>
                      //                                         Container(
                      //                                       height: 110,
                      //                                       width: Get.width,
                      //                                       decoration:
                      //                                           BoxDecoration(
                      //                                         borderRadius:
                      //                                             BorderRadius
                      //                                                 .circular(
                      //                                                     10),
                      //                                         image:
                      //                                             DecorationImage(
                      //                                           fit:
                      //                                               BoxFit.fill,
                      //                                           image:
                      //                                               imageProvider,
                      //                                         ),
                      //                                       ),
                      //                                     ),
                      //                                     placeholder: (context,
                      //                                             url) =>
                      //                                         const Center(
                      //                                             child:
                      //                                                 CircularProgressIndicator()),
                      //                                     errorWidget: (context,
                      //                                             url, error) =>
                      //                                         Image.asset(
                      //                                       Images.blog,
                      //                                       height: Get.height *
                      //                                           0.15,
                      //                                       width: Get.width,
                      //                                       fit: BoxFit.fill,
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                                 Padding(
                      //                                   padding:
                      //                                       const EdgeInsets
                      //                                           .only(
                      //                                           left: 5,
                      //                                           right: 5,
                      //                                           top: 3,
                      //                                           bottom: 3),
                      //                                   child: Column(
                      //                                     crossAxisAlignment:
                      //                                         CrossAxisAlignment
                      //                                             .start,
                      //                                     children: [
                      //                                       Container(
                      //                                         height: 55,
                      //                                         child: Text(
                      //                                           homeController
                      //                                               .astroNews[
                      //                                                   index]
                      //                                               .description,
                      //                                           textAlign:
                      //                                               TextAlign
                      //                                                   .start,
                      //                                           maxLines: 2,
                      //                                           style: Get
                      //                                               .theme
                      //                                               .textTheme
                      //                                               .titleMedium!
                      //                                               .copyWith(
                      //                                             fontSize: 13,
                      //                                             fontWeight:
                      //                                                 FontWeight
                      //                                                     .w500,
                      //                                             letterSpacing:
                      //                                                 0,
                      //                                           ),
                      //                                         ).tr(),
                      //                                       ),
                      //                                       Row(
                      //                                         mainAxisAlignment:
                      //                                             MainAxisAlignment
                      //                                                 .spaceBetween,
                      //                                         children: [
                      //                                           Text(
                      //                                             homeController
                      //                                                 .astroNews[
                      //                                                     index]
                      //                                                 .channel,
                      //                                             textAlign:
                      //                                                 TextAlign
                      //                                                     .center,
                      //                                             style: Get
                      //                                                 .theme
                      //                                                 .textTheme
                      //                                                 .titleMedium!
                      //                                                 .copyWith(
                      //                                               fontSize:
                      //                                                   11,
                      //                                               fontWeight:
                      //                                                   FontWeight
                      //                                                       .w500,
                      //                                               color: Colors
                      //                                                       .grey[
                      //                                                   700],
                      //                                               letterSpacing:
                      //                                                   0,
                      //                                             ),
                      //                                           ).tr(),
                      //                                           Text(
                      //                                             "${DateFormat("MMM d, yyyy").format(DateTime.parse(homeController.astroNews[index].newsDate.toString()))}",
                      //                                             textAlign:
                      //                                                 TextAlign
                      //                                                     .center,
                      //                                             style: Get
                      //                                                 .theme
                      //                                                 .textTheme
                      //                                                 .titleMedium!
                      //                                                 .copyWith(
                      //                                               fontSize:
                      //                                                   11,
                      //                                               fontWeight:
                      //                                                   FontWeight
                      //                                                       .w500,
                      //                                               color: Colors
                      //                                                       .grey[
                      //                                                   700],
                      //                                               letterSpacing:
                      //                                                   0,
                      //                                             ),
                      //                                           ),
                      //                                         ],
                      //                                       ),
                      //                                     ],
                      //                                   ),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       );
                      //                     },
                      //                   ))
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      // }),
                      // Card(
                      //   elevation: 0,
                      //   margin: EdgeInsets.only(top: 6),
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.zero),
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: 10, horizontal: 10),
                      //     child: SizedBox(
                      //       height: 110,
                      //       child: Stack(
                      //         children: [
                      //           GestureDetector(
                      //             onTap: () async {
                      //               DateTime dateBasic = DateTime.now();
                      //               int formattedYear = int.parse(
                      //                   DateFormat('yyyy').format(dateBasic));
                      //               int formattedDay = int.parse(
                      //                   DateFormat('dd').format(dateBasic));
                      //               int formattedMonth = int.parse(
                      //                   DateFormat('MM').format(dateBasic));
                      //               int formattedHour = int.parse(
                      //                   DateFormat('HH').format(dateBasic));
                      //               int formattedMint = int.parse(
                      //                   DateFormat('mm').format(dateBasic));
                      //
                      //               global.showOnlyLoaderDialog(context);
                      //               await kundliController
                      //                   .getBasicPanchangDetail(
                      //                       day: formattedDay,
                      //                       hour: formattedHour,
                      //                       min: formattedMint,
                      //                       month: formattedMonth,
                      //                       year: formattedYear,
                      //                       lat: 21.1255,
                      //                       lon: 73.1122,
                      //                       tzone: 5);
                      //               panchangController
                      //                   .getPanchangVedic(DateTime.now());
                      //               global.hideLoader();
                      //               Get.to(() => PanchangScreen());
                      //             },
                      //             child: Container(
                      //               width: Get.width,
                      //               decoration: BoxDecoration(
                      //                 color: Get.theme.primaryColor,
                      //                 borderRadius: BorderRadius.circular(10),
                      //               ),
                      //               padding: EdgeInsets.only(right: 20),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.end,
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.center,
                      //                 children: [
                      //                   Text(
                      //                     "Today's Panchang",
                      //                     style: TextStyle(color: Colors.white),
                      //                   ).tr(),
                      //                   Container(
                      //                     height: 25,
                      //                     width: 90,
                      //                     margin: EdgeInsets.only(
                      //                         right: 35, top: 5),
                      //                     padding: EdgeInsets.symmetric(
                      //                         horizontal: 5),
                      //                     decoration: BoxDecoration(
                      //                       color: Colors.black,
                      //                       borderRadius:
                      //                           BorderRadius.circular(7),
                      //                     ),
                      //                     alignment: Alignment.center,
                      //                     child: Text(
                      //                       'Check Now',
                      //                       style: TextStyle(
                      //                         fontSize: 10,
                      //                         fontWeight: FontWeight.w500,
                      //                         color: Colors.white,
                      //                         letterSpacing: -0.2,
                      //                         wordSpacing: 0,
                      //                       ),
                      //                     ).tr(),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //           Container(
                      //             height: 110,
                      //             width: 130,
                      //             child: ClipRRect(
                      //               borderRadius: BorderRadius.only(
                      //                 topRight: Radius.circular(45),
                      //                 bottomRight: Radius.circular(45),
                      //                 topLeft: Radius.circular(10),
                      //                 bottomLeft: Radius.circular(10),
                      //               ),
                      //               child: CachedNetworkImage(
                      //                 imageUrl:
                      //                     '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.todayPanchang)}',
                      //                 imageBuilder: (context, imageProvider) =>
                      //                     Image.network(
                      //                   '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.todayPanchang)}',
                      //                   fit: BoxFit.fill,
                      //                 ),
                      //                 placeholder: (context, url) =>
                      //                     const Center(
                      //                         child:
                      //                             CircularProgressIndicator()),
                      //                 errorWidget: (context, url, error) =>
                      //                     Icon(Icons.no_accounts, size: 20),
                      //               ),
                      //             ),
                      //             decoration: BoxDecoration(
                      //                 color: Colors.black,
                      //                 borderRadius: BorderRadius.only(
                      //                   topRight: Radius.circular(45),
                      //                   bottomRight: Radius.circular(45),
                      //                   topLeft: Radius.circular(10),
                      //                   bottomLeft: Radius.circular(10),
                      //                 )),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // GetBuilder<HomeController>(builder: (homeController) {
                      //   return homeController.astrologyVideo.length == 0
                      //       ? SizedBox()
                      //       : SizedBox(
                      //           height: 250,
                      //           child: Card(
                      //             elevation: 0,
                      //             margin: EdgeInsets.only(top: 6),
                      //             shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.zero),
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(
                      //                   top: 10, bottom: 5),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Padding(
                      //                     padding: const EdgeInsets.symmetric(
                      //                         horizontal: 10),
                      //                     child: Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.spaceBetween,
                      //                       children: [
                      //                         Container(
                      //                           margin: EdgeInsets.symmetric(
                      //                               horizontal: 10),
                      //                           child: Column(
                      //                             crossAxisAlignment:
                      //                                 CrossAxisAlignment.start,
                      //                             children: [
                      //                               Text(
                      //                                 'Watch Astrology Videos',
                      //                                 style: Get
                      //                                     .theme
                      //                                     .primaryTextTheme
                      //                                     .titleMedium!
                      //                                     .copyWith(
                      //                                         fontWeight:
                      //                                             FontWeight
                      //                                                 .w500),
                      //                               ).tr(),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                         GestureDetector(
                      //                           onTap: () {
                      //                             Get.to(() =>
                      //                                 AstrologerVideoScreen());
                      //                           },
                      //                           child: Text(
                      //                             'View All',
                      //                             style: Get
                      //                                 .theme
                      //                                 .primaryTextTheme
                      //                                 .bodySmall!
                      //                                 .copyWith(
                      //                               fontWeight: FontWeight.w400,
                      //                               color: Colors.blue[500],
                      //                             ),
                      //                           ).tr(),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                   Expanded(
                      //                       child: ListView.builder(
                      //                     itemCount: homeController
                      //                         .astrologyVideo.length,
                      //                     shrinkWrap: true,
                      //                     scrollDirection: Axis.horizontal,
                      //                     padding: EdgeInsets.only(
                      //                         top: 10, left: 10, bottom: 10),
                      //                     itemBuilder: (context, index) {
                      //                       return GestureDetector(
                      //                         onTap: () async {
                      //                           global.showOnlyLoaderDialog(
                      //                               context);
                      //                           await homeController.youtubPlay(
                      //                               homeController
                      //                                   .astrologyVideo[index]
                      //                                   .youtubeLink);
                      //                           global.hideLoader();
                      //                           Get.to(() => BlogScreen(
                      //                                 link: homeController
                      //                                     .astrologyVideo[index]
                      //                                     .youtubeLink,
                      //                                 title: 'Video',
                      //                                 controller: homeController
                      //                                     .youtubePlayerController,
                      //                                 date:
                      //                                     '${DateFormat("MMM d,yyyy").format(DateTime.parse(homeController.astrologyVideo[index].createdAt))}',
                      //                                 videoTitle: homeController
                      //                                     .astrologyVideo[index]
                      //                                     .videoTitle,
                      //                               ));
                      //                         },
                      //                         child: Card(
                      //                           elevation: 4,
                      //                           margin:
                      //                               EdgeInsets.only(right: 12),
                      //                           shape: RoundedRectangleBorder(
                      //                             borderRadius:
                      //                                 BorderRadius.circular(20),
                      //                           ),
                      //                           child: Container(
                      //                             width: 230,
                      //                             decoration: BoxDecoration(
                      //                               color: Colors.white,
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       20),
                      //                             ),
                      //                             child: Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment
                      //                                       .start,
                      //                               mainAxisSize:
                      //                                   MainAxisSize.min,
                      //                               children: [
                      //                                 Stack(
                      //                                   alignment:
                      //                                       Alignment.center,
                      //                                   children: [
                      //                                     ClipRRect(
                      //                                       borderRadius:
                      //                                           BorderRadius
                      //                                               .only(
                      //                                         topLeft: Radius
                      //                                             .circular(20),
                      //                                         topRight: Radius
                      //                                             .circular(20),
                      //                                       ),
                      //                                       child:
                      //                                           CachedNetworkImage(
                      //                                         imageUrl:
                      //                                             '${global.imgBaseurl}${homeController.astrologyVideo[index].coverImage}',
                      //                                         imageBuilder:
                      //                                             (context,
                      //                                                     imageProvider) =>
                      //                                                 Container(
                      //                                           height: 110,
                      //                                           width:
                      //                                               Get.width,
                      //                                           decoration:
                      //                                               BoxDecoration(
                      //                                             borderRadius:
                      //                                                 BorderRadius
                      //                                                     .circular(
                      //                                                         10),
                      //                                             image:
                      //                                                 DecorationImage(
                      //                                               fit: BoxFit
                      //                                                   .fill,
                      //                                               image:
                      //                                                   imageProvider,
                      //                                             ),
                      //                                           ),
                      //                                         ),
                      //                                         placeholder: (context,
                      //                                                 url) =>
                      //                                             const Center(
                      //                                                 child:
                      //                                                     CircularProgressIndicator()),
                      //                                         errorWidget: (context,
                      //                                                 url,
                      //                                                 error) =>
                      //                                             Image.asset(
                      //                                           Images.blog,
                      //                                           height:
                      //                                               Get.height *
                      //                                                   0.15,
                      //                                           width:
                      //                                               Get.width,
                      //                                           fit:
                      //                                               BoxFit.fill,
                      //                                         ),
                      //                                       ),
                      //                                     ),
                      //                                     Positioned(
                      //                                       child: Image.asset(
                      //                                         Images.youtube,
                      //                                         height: 40,
                      //                                         width: 40,
                      //                                       ),
                      //                                     )
                      //                                   ],
                      //                                 ),
                      //                                 Padding(
                      //                                   padding:
                      //                                       const EdgeInsets
                      //                                           .only(
                      //                                           left: 5,
                      //                                           right: 5,
                      //                                           top: 3,
                      //                                           bottom: 3),
                      //                                   child: Column(
                      //                                     crossAxisAlignment:
                      //                                         CrossAxisAlignment
                      //                                             .start,
                      //                                     children: [
                      //                                       Container(
                      //                                         height: 43,
                      //                                         child: Text(
                      //                                           homeController
                      //                                               .astrologyVideo[
                      //                                                   index]
                      //                                               .videoTitle,
                      //                                           textAlign:
                      //                                               TextAlign
                      //                                                   .start,
                      //                                           maxLines: 2,
                      //                                           overflow:
                      //                                               TextOverflow
                      //                                                   .ellipsis,
                      //                                           style: Get
                      //                                               .theme
                      //                                               .textTheme
                      //                                               .titleMedium!
                      //                                               .copyWith(
                      //                                             fontSize: 13,
                      //                                             fontWeight:
                      //                                                 FontWeight
                      //                                                     .w500,
                      //                                             letterSpacing:
                      //                                                 0,
                      //                                           ),
                      //                                         ).tr(),
                      //                                       ),
                      //                                       Row(
                      //                                         mainAxisAlignment:
                      //                                             MainAxisAlignment
                      //                                                 .end,
                      //                                         children: [
                      //                                           Text(
                      //                                             "${DateFormat("MMM d, yyyy").format(DateTime.parse(homeController.astrologyVideo[index].createdAt))}",
                      //                                             textAlign:
                      //                                                 TextAlign
                      //                                                     .center,
                      //                                             style: Get
                      //                                                 .theme
                      //                                                 .textTheme
                      //                                                 .titleMedium!
                      //                                                 .copyWith(
                      //                                               fontSize:
                      //                                                   10,
                      //                                               fontWeight:
                      //                                                   FontWeight
                      //                                                       .w500,
                      //                                               color: Colors
                      //                                                       .grey[
                      //                                                   700],
                      //                                               letterSpacing:
                      //                                                   0,
                      //                                             ),
                      //                                           ),
                      //                                         ],
                      //                                       ),
                      //                                     ],
                      //                                   ),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       );
                      //                     },
                      //                   ))
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      // }),
                      // GetBuilder<HomeController>(builder: (homeController) {
                      //   return Card(
                      //     elevation: 0,
                      //     margin: EdgeInsets.only(top: 6),
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.zero),
                      //     child: Container(
                      //       margin: EdgeInsets.symmetric(
                      //           horizontal: 30, vertical: 10),
                      //       decoration: BoxDecoration(
                      //         color: Colors.grey[200],
                      //         borderRadius: BorderRadius.circular(15),
                      //       ),
                      //       padding: EdgeInsets.all(10),
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             'I am the Product Manager',
                      //             style: Get.theme.primaryTextTheme.titleMedium!
                      //                 .copyWith(
                      //               fontWeight: FontWeight.w500,
                      //               fontSize: 17.sp,
                      //             ),
                      //           ).tr(),
                      //           Text(
                      //             'share your feedback to help us improve the app',
                      //             style: TextStyle(
                      //               fontSize: 15.sp,
                      //             ),
                      //           ).tr(),
                      //           SizedBox(
                      //             height: 10,
                      //           ),
                      //           TextFormField(
                      //             style: TextStyle(fontSize: 15.sp),
                      //             controller: homeController.feedbackController,
                      //             maxLines: 8,
                      //             keyboardType: TextInputType.text,
                      //             decoration: InputDecoration(
                      //               contentPadding: EdgeInsets.all(5),
                      //               border: InputBorder.none,
                      //               filled: true,
                      //               fillColor: Colors.white,
                      //               hintText: 'Start typing here..',
                      //               hintStyle: TextStyle(
                      //                 fontWeight: FontWeight.w600,
                      //                 color: Colors.grey[500],
                      //                 fontSize: 15.sp,
                      //               ),
                      //             ),
                      //           ),
                      //           Align(
                      //             alignment: Alignment.center,
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(
                      //                   top: 15, bottom: 5),
                      //               child: SizedBox(
                      //                 height: 35,
                      //                 child: TextButton(
                      //                   style: ButtonStyle(
                      //                     padding: MaterialStateProperty.all(
                      //                         EdgeInsets.all(0)),
                      //                     fixedSize: MaterialStateProperty.all(
                      //                         Size.fromWidth(Get.width / 2)),
                      //                     backgroundColor:
                      //                         MaterialStateProperty.all(
                      //                             Get.theme.primaryColor),
                      //                     shape: MaterialStateProperty.all(
                      //                       RoundedRectangleBorder(
                      //                         borderRadius:
                      //                             BorderRadius.circular(7),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   onPressed: () async {
                      //                     bool isLogin = await global.isLogin();
                      //                     if (isLogin) {
                      //                       if (homeController
                      //                               .feedbackController.text ==
                      //                           "") {
                      //                         global.showToast(
                      //                           message:
                      //                               'Please enter feedback',
                      //                           textColor: global.textColor,
                      //                           bgColor:
                      //                               global.toastBackGoundColor,
                      //                         );
                      //                       } else {
                      //                         global.showOnlyLoaderDialog(
                      //                             context);
                      //                         await homeController.addFeedback(
                      //                             homeController
                      //                                 .feedbackController.text);
                      //                         global.hideLoader();
                      //                       }
                      //                     }
                      //                   },
                      //                   child: Text(
                      //                     'Send Feedback',
                      //                     style: Get
                      //                         .theme.primaryTextTheme.bodySmall!
                      //                         .copyWith(color: Colors.white),
                      //                   ).tr(),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   );
                      // }),
                      // Card(
                      //   elevation: 0,
                      //   margin: EdgeInsets.only(top: 6),
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.zero),
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //             vertical: 15, horizontal: 10)
                      //         .copyWith(bottom: 65),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //       children: [
                      //         Column(
                      //           children: [
                      //             Container(
                      //               height: 70,
                      //               width: 70,
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(7),
                      //                 color: Colors.grey[200],
                      //               ),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(10),
                      //                 child: Image.asset(
                      //                   Images.confidential,
                      //                   height: 45,
                      //                 ),
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               height: 15,
                      //             ),
                      //             Text(
                      //               'Private &\nConfidential',
                      //               textAlign: TextAlign.center,
                      //               style: Get.theme.textTheme.titleMedium!
                      //                   .copyWith(
                      //                 fontSize: 16.sp,
                      //                 fontWeight: FontWeight.w400,
                      //                 letterSpacing: 0.5,
                      //               ),
                      //             ).tr(),
                      //           ],
                      //         ),
                      //         Column(
                      //           children: [
                      //             Container(
                      //               height: 70,
                      //               width: 70,
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(7),
                      //                 color: Colors.grey[200],
                      //               ),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(10),
                      //                 child: Image.asset(
                      //                   Images.verifiedAccount,
                      //                   height: 45,
                      //                 ),
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               height: 15,
                      //             ),
                      //             Text(
                      //               'Verified\nAstrologers',
                      //               textAlign: TextAlign.center,
                      //               style: Get.theme.textTheme.titleMedium!
                      //                   .copyWith(
                      //                 fontSize: 16.sp,
                      //                 fontWeight: FontWeight.w400,
                      //                 letterSpacing: 0.5,
                      //               ),
                      //             ).tr(),
                      //           ],
                      //         ),
                      //         Column(
                      //           children: [
                      //             Container(
                      //               height: 70,
                      //               width: 70,
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(7),
                      //                 color: Colors.grey[200],
                      //               ),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(10),
                      //                 child: Image.asset(
                      //                   Images.payment,
                      //                   height: 45,
                      //                 ),
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               height: 15,
                      //             ),
                      //             Text(
                      //               'Secure\nPayments',
                      //               textAlign: TextAlign.center,
                      //               style: Get.theme.textTheme.titleMedium!
                      //                   .copyWith(
                      //                 fontSize: 16.sp,
                      //                 fontWeight: FontWeight.w500,
                      //                 letterSpacing: 0.5,
                      //               ),
                      //             ).tr(),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                //-----------------------CHAT WITH ASTROLOGER BUTTON----------------------------------
                // Container(
                //   margin: EdgeInsets.only(top: 6, bottom: 4),
                //   width: 100.w,
                //   height: 6.h,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       InkWell(
                //         onTap: () async {
                //           global.showOnlyLoaderDialog(context);
                //           bottomController.astrologerList = [];
                //           bottomController.astrologerList.clear();
                //           bottomController.isAllDataLoaded = false;
                //           bottomController.update();
                //           await bottomController.getAstrologerList(
                //               isLazyLoading: false);
                //           global.hideLoader();
                //           bottomController.setBottomIndex(1, 0);
                //         },
                //         child: Container(
                //             width: Adaptive.w(43),
                //             decoration: BoxDecoration(
                //               color: Get.theme.primaryColor,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(4.w),
                //               ),
                //             ),
                //             child: Container(
                //               padding: EdgeInsets.only(left: 1.5.w),
                //               height: 6.h,
                //               child: Row(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Icon(
                //                     FontAwesomeIcons.solidCommentDots,
                //                     size: 14.sp,
                //                     color: Colors.white,
                //                   ),
                //                   Padding(
                //                     padding: EdgeInsets.only(left: 2.w),
                //                     child: FittedBox(
                //                       fit: BoxFit.contain,
                //                       alignment: Alignment.center,
                //                       child: Text('Chat with Astrologer',
                //                               style: TextStyle(
                //                                   fontWeight: FontWeight.w500,
                //                                   color: Colors.white,
                //                                   fontSize: 14.sp))
                //                           .tr(),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             )),
                //       ),
                //       SizedBox(
                //         width: 2.w,
                //       ),
                //       InkWell(
                //         onTap: () async {
                //           global.showOnlyLoaderDialog(context);
                //           bottomController.astrologerList = [];
                //           bottomController.astrologerList.clear();
                //           bottomController.isAllDataLoaded = false;
                //           bottomController.update();
                //           await bottomController.getAstrologerList(
                //               isLazyLoading: false);
                //           global.hideLoader();
                //           bottomController.setBottomIndex(3, 0);
                //         },
                //         child: Container(
                //             width: Adaptive.w(43),
                //             decoration: BoxDecoration(
                //               color: Get.theme.primaryColor,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(4.w),
                //               ),
                //             ),
                //             child: Container(
                //               padding: EdgeInsets.only(left: 1.5.w),
                //               height: 6.h,
                //               child: Row(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Icon(
                //                     Icons.phone,
                //                     size: 14.sp,
                //                     color: Colors.white,
                //                   ),
                //                   Padding(
                //                     padding: EdgeInsets.only(left: 2.w),
                //                     child: FittedBox(
                //                       child: Text('Talk to Astrologer',
                //                               style: TextStyle(
                //                                   fontWeight: FontWeight.w500,
                //                                   color: Colors.white,
                //                                   fontSize: 14.sp))
                //                           .tr(),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             )),
                //       ),
                //     ],
                //   ),
                // )
              ],
            );
          }),
        ),
        // floatingActionButton: InkWell(
        //   onTap: () {
        //      global.warningDialog(context);
        //   },
        //   child: Container(
        //     margin: EdgeInsets.symmetric(vertical: 6.h),
        //     child: CircleAvatar(
        //       radius: 20.sp,
        //       backgroundColor: Colors.black,
        //       backgroundImage: AssetImage(
        //         "assets/images/warning.png",
        //       ),
        //     ),
        //   ),
        // ),
        //  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void refreshIt() async {
    // global.warningDialog(context);
    splashController.currentLanguageCode =
        homeController.lan[homeController.selectedIndex].lanCode;
    splashController.update();
    global.spLanguage = await SharedPreferences.getInstance();
    global.spLanguage!
        .setString('currentLanguage', splashController.currentLanguageCode);
    homeController.refresh();

    Get.back();
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 100);
    path.lineTo(250, 100);
    path.lineTo(0, 100);
    path.lineTo(200, 300);
    path.lineTo(90, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
