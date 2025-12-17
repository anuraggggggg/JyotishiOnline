import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:AstrowayCustomer/controllers/advancedPanchangController.dart';
import 'package:AstrowayCustomer/controllers/astrologerCategoryController.dart';
import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/fastApiProvider/GetAllAstrologerProvider.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/controllers/liveController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/model/fastApiModel/UserModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/allAstrologerModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/currentUserWalletModel.dart';
import 'package:AstrowayCustomer/utils/AppColors.dart';
import 'package:AstrowayCustomer/utils/date_converter.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/addMoneyToWallet.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/astrologerProfile.dart';
import 'package:AstrowayCustomer/views/call/call_history_detail_screen.dart';
import 'package:AstrowayCustomer/views/chat/chat_screen.dart';
import 'package:AstrowayCustomer/views/clientsReviewScreem.dart';
import 'package:AstrowayCustomer/views/liveAstrologerList.dart';
import 'package:AstrowayCustomer/views/live_astrologer/live_astrologer_screen.dart';
import 'package:AstrowayCustomer/views/notification.dart';
import 'package:AstrowayCustomer/views/proKerela/LoveCompatibilityInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/birthdayNumberInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/dailyPredictionInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/kundli_input_screen.dart';
import 'package:AstrowayCustomer/views/proKerela/planetInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/services.dart';
import 'package:AstrowayCustomer/views/searchAstrologerScreen.dart';
import 'package:AstrowayCustomer/views/settings/notificationScreen.dart';
import 'package:AstrowayCustomer/views/wallet/walletRechargeScreen.dart';
import 'package:AstrowayCustomer/widget/drawerWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/IntakeController.dart';
import '../controllers/chatController.dart';
import '../controllers/fastApiProvider/GetOnlineAstrologerProvider.dart';
import '../controllers/fastApiProvider/LiveAstrologerProvider.dart';
import '../controllers/fastApiProvider/cosmic_services_provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/splashController.dart';
import '../controllers/walletController.dart';
import '../model/fastApiModel/CustomerDetailModel.dart';
import '../model/fastApiModel/LiveAstrologerModel.dart';
import '../model/fastApiModel/OnlineAstrologerModel.dart';
import '../theme/appTheme.dart';
import '../utils/fonts.dart';
import 'CustomText.dart';
import 'astrologerProfile/FastApi/allAstrologer.dart';
import 'astrologerProfile/FastApi/astroProfile.dart';
import 'live_astrologer/newAstrologerLive.dart';

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
  // String? userName;
  CustomerDetail? _customerDetail;
  String? userName;
  String? profileImageUrl;
  bool _isLoadingUser = true;
  List<Map<String, dynamic>> banners = [];

  // AppEventsLogger logger = AppEventsLogger.newLogger(this);
  @override
  void initState() {
    super.initState();
    FastAPIServices().fetchCustomerDetails();
    FastAPIServices().fetchCurrentUserDetails();
    FastAPIServices().getAllWalletDetails();
    FastAPIServices().fetchCurrentWallet();
    FastAPIServices().fetchAllAstrologers();
    FastAPIServices().fetchCurrentUserDetails();
    loadBanners();
    FastAPIServices().fetchOnlineAstrologers();


    Provider.of<LiveAstrologerProvider>(context, listen: false)
        .fetchLiveAstrologers();

    _fetchUserProfile();

    _fetchAllData();




    Future.microtask(() =>
        Provider.of<GetAllAstrologerProvider>(context, listen: false)
            .getAstrologers());

    Provider.of<GetOnlineAstrologerProvider>(context, listen: false)
        .fetchOnlineAstrologers();
  }


  Future<void> loadBanners() async {
    banners = await FastAPIServices().getHomeBanners();
    setState(() {});
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
            _isLoadingUser
                ? "Loading..."
                : "Hi ${_customerDetail?.name ?? 'User'}",
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
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (_isLoadingUser)
                            ? null
                            : (_customerDetail?.profileImageUrl != null &&
                            _customerDetail!.profileImageUrl!.isNotEmpty)
                            ? NetworkImage(_customerDetail!.profileImageUrl!)
                            : const AssetImage('assets/images/default_user.png')
                        as ImageProvider,
                        child: (_isLoadingUser)
                            ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                            : (_customerDetail?.profileImageUrl == null ||
                            _customerDetail!.profileImageUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        right: 2,
                        bottom: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
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

                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () async {

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
            // GestureDetector(
            //   onTap: () {
            //     Get.to(() => NotificationPage());
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.only(right: 10),
            //     child: Icon(
            //       Icons.notifications_none,
            //       size: 28,
            //       color: Colors.black,
            //     ),
            //   ),
            // )

          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {

            FastAPIServices().fetchCustomerDetails();
            FastAPIServices().fetchCurrentUserDetails();
            FastAPIServices().getAllWalletDetails();
            FastAPIServices().fetchCurrentWallet();
            FastAPIServices().fetchAllAstrologers();
            FastAPIServices().fetchCurrentUserDetails();
            Provider.of<LiveAstrologerProvider>(context, listen: false)
                .fetchLiveAstrologers();

            _fetchUserProfile();

            _fetchAllData();

            Future.microtask(() =>
                Provider.of<GetAllAstrologerProvider>(context, listen: false)
                    .getAstrologers());

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
                      Container(
                        height: 40,
                      ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => AstrologyServicesPage());
                    },
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: (banners.isNotEmpty && banners.first["image_url"] != null)
                            ? Image.network(
                          "https://fastapi.jyotishionline.com${banners.first["image_url"]}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/banner2.png",
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : Image.asset(
                          "assets/images/banner2.png",
                          fit: BoxFit.cover,
                        ),
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

                                    Consumer<CosmicServicesProvider>(
                                      builder: (context, provider, _) {
                                        if (provider.isLoading) {
                                          return const SizedBox(); // or loader
                                        }

                                        // 🔍 Find Daily Horoscope service from API
                                        final dailyService = provider.services.firstWhere(
                                              (e) => e.name == 'Daily Horoscope',
                                          orElse: () => throw Exception('Daily Horoscope service not found'),
                                        );

                                        return GestureDetector(
                                          onTap: () {
                                            Get.to(
                                                  () => DailyPredictionInputScreen(
                                                serviceName: dailyService.name,
                                                servicePrice: dailyService.finalPrice.toDouble(), // ✅ INT
                                              ),
                                            );
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
                                                child: Center(
                                                  child: SizedBox(
                                                    height: 5.h,
                                                    width: 5.h,
                                                    child: Image.asset("assets/images/star.png"),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Daily\nHoroscope',
                                                textAlign: TextAlign.center,
                                                style: Get.theme.textTheme.titleSmall!.copyWith(
                                                  height: 1,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0,
                                                ),
                                              ).tr(),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),

                                Consumer<CosmicServicesProvider>(
                                  builder: (context, provider, _) {
                                    if (provider.isLoading) return const SizedBox();

                                    final planetService = provider.services.firstWhere(
                                          (e) => e.name == 'Planet Position',
                                      orElse: () => throw Exception('Planet Position service not found'),
                                    );

                                    return _ServiceCircle(
                                      iconWidget: const Icon(Icons.star),
                                      title: 'Planet\nPosition',
                                      onTap: () {
                                        Get.to(() => PlanetInputScreen(
                                          serviceName: planetService.name,
                                          servicePrice: planetService.finalPrice,

                                        ));
                                      },
                                    );
                                  },
                                ),

                                SizedBox(
                                  width: 5,
                                ),

                                Consumer<CosmicServicesProvider>(
                                  builder: (context, provider, _) {
                                    if (provider.isLoading) return const SizedBox();

                                    final loveService = provider.services.firstWhere(
                                          (e) => e.name == 'Love Compatibility',
                                      orElse: () => throw Exception('Love Compatibility service not found'),
                                    );

                                    return _ServiceCircle(
                                      icon: "assets/images/matching.png",
                                      title: 'Love\nCompatibility',
                                      onTap: () {
                                        Get.to(() => LoveCompatibilityInputScreen(
                                          serviceName: loveService.name,
                                          servicePrice: loveService.finalPrice,
                                        ));
                                        // price available: loveService.finalPrice
                                      },
                                    );
                                  },
                                ),

                                SizedBox(
                                  width: 5,
                                ),



                                Consumer<CosmicServicesProvider>(
                                  builder: (context, provider, _) {
                                    if (provider.isLoading) return const SizedBox();

                                    final kundliService = provider.services.firstWhere(
                                          (e) => e.name == 'Detailed Kundli',
                                      orElse: () => throw Exception('Detailed Kundli service not found'),
                                    );

                                    return _ServiceCircle(
                                      icon: "assets/images/kundali.png",
                                      title: 'Detailed\nKundli',
                                      onTap: () {
                                        Get.to(() => KundliInputScreen(servicePrice: kundliService.finalPrice, serviceName: kundliService.name,));
                                        // price available: kundliService.finalPrice
                                      },
                                    );
                                  },
                                ),

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

                      Consumer<LiveAstrologerProvider>(
                        builder: (context, provider, child) {

                          // 1️⃣ Show loader while fetching data
                          if (provider.isLoading) {
                            return SizedBox(
                              height: 170,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          // 2️⃣ Hide everything if no astrologers are live
                          if (provider.liveAstrologers.isEmpty) {
                            return SizedBox.shrink();   // << NOTHING IS SHOWN
                          }

                          // 3️⃣ Show "Live Now" + List ONLY when live astrologers exist
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                child: Text(
                                  "Live Now 🔴",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: 170,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  itemCount: provider.liveAstrologers.length,
                                  itemBuilder: (context, index) {
                                    final astro = provider.liveAstrologers[index];
                                    return LiveAstroCard(astro: astro);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Online Astrologers",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     // Navigator.push(
                            //     //   context,
                            //     //   MaterialPageRoute(
                            //     //     builder: (context) => ViewAllOnlineAstrologersPage(),
                            //     //   ),
                            //     // );
                            //   },
                            //   child: Text(
                            //     "View all",
                            //     style: TextStyle(
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w500,
                            //       color: Colors.blue,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      Container(
                        height: 150,
                        width: double.infinity,
                        child: Consumer<GetOnlineAstrologerProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (provider.astrologers.isEmpty) {
                              return const Center(child: Text("No astrologers online"));
                            }

                            return SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(12),
                                itemCount: provider.astrologers.length,
                                itemBuilder: (context, index) {
                                  final astro = provider.astrologers[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AstrologerDetailPage(
                                            astroId: astro.id,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 40,
                                      width: 90,
                                      child: _buildOnlineAstroTile(astro),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),





                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Top Astrologers",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    ViewAllAstrologersPage()));
                              },
                              child: Text(
                                "View all",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue, // make it look like a link
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                      Container(
                        height: 150,
                        width: double.infinity,
                        child: Consumer<GetAllAstrologerProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (provider.astrologers.isEmpty) {
                              return const Center(
                                  child: Text("No astrologers found"));
                            }

                            return SizedBox(
                              height: 100, // Horizontal scroll container height
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(12),
                                itemCount: provider.astrologers.length,
                                itemBuilder: (context, index) {
                                  final astrologer = provider.astrologers[index];
                                  return InkWell(
                                    onTap: () {
                                      // Navigate to detail page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AstrologerDetailPage(
                                            astroId: astrologer.astroId , // Pass the ID only
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12), // optional for ripple effect
                                    child: Container(


                                      height: 40,
                                      width: 90,
                                      child: _buildAstroTile(astrologer),
                                    ),
                                  );

                                },
                              ),
                            );

                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// --------------------------------------------------------
                            /// FIRST CARD
                            /// --------------------------------------------------------
                            GestureDetector(
                              onTap: () async {
                                global.showOnlyLoaderDialog(context);
                                bottomController.astrologerList = [];
                                bottomController.isAllDataLoaded = false;
                                bottomController.update();
                                await bottomController.getAstrologerList(isLazyLoading: false);
                                global.hideLoader();
                                bottomController.setBottomIndex(1, 0);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 150, // FIXED same size
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                  minWidth: 180,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: appYellow, width: 1.5),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),

                                child: Column(
                                  children: [
                                    /// ------------ TITLE (Auto-shrink for translations) ------------
                                    Flexible(
                                      flex: 1,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: appYellow.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          child: Text(
                                            "Live Chat with an Astrologer",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.grey.shade800,
                                            ),
                                          ).tr(),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    /// ------------ IMAGE (Auto-scale, never overflows) ------------
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Image.asset(
                                              "assets/images/chat3.png",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 5),

                            /// --------------------------------------------------------
                            /// SECOND COLUMN
                            /// --------------------------------------------------------
                            Expanded(
                              child: Column(
                                children: [
                                  /// --------------------------------------------------------
                                  /// SECOND CARD
                                  /// --------------------------------------------------------
                                  GestureDetector(
                                    onTap: () async {
                                      global.showOnlyLoaderDialog(context);
                                      bottomController.astrologerList = [];
                                      bottomController.isAllDataLoaded = false;
                                      bottomController.update();
                                      await bottomController.getAstrologerList(isLazyLoading: false);
                                      global.hideLoader();
                                      bottomController.setBottomIndex(2, 0);
                                    },
                                    child: Container(
                                      height: 150, // EXACT SAME HEIGHT
                                      constraints: const BoxConstraints(
                                        maxWidth: 300,
                                        minWidth: 180,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: appYellow, width: 1.5),
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          )
                                        ],
                                      ),

                                      child: Column(
                                        children: [
                                          /// ------------ TITLE ------------
                                          Flexible(
                                            flex: 1,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: appYellow.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                child: Text(
                                                  "Talk to an Astrologer",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ).tr(),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          /// ------------ IMAGE ------------
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Image.asset(
                                                    "assets/images/call1.jpg",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),



                      ///Stories

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

                      GestureDetector(
                        onTap: () {
                          Get.to(RechargeWalletScreen());
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
                    ],
                  ),
                ),],
            );
          }),
        ),

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

  Future<void> _fetchUserProfile() async {
    try {
      setState(() => _isLoadingUser = true);

      final customer = await FastAPIServices().fetchCurrentUserDetails();

      setState(() {
        _customerDetail = customer;
        userName = customer.name ?? "User";
        profileImageUrl = customer.profileImageUrl;
      });
    } catch (e) {
      print("❌ Error fetching user details: $e");
    } finally {
      setState(() => _isLoadingUser = false);
    }
  }

}

class _ServiceCircle extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? icon;
  final Widget? iconWidget;

  const _ServiceCircle({
    required this.title,
    required this.onTap,
    this.icon,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 8.h,
            width: 8.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appYellow,
            ),
            child: Center(
              child: SizedBox(
                height: 5.h,
                width: 5.h,
                child: icon != null
                    ? Image.asset(icon!)
                    : iconWidget,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Get.theme.textTheme.titleSmall!.copyWith(
              height: 1,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
          ).tr(),
        ],
      ),
    );
  }
}


Widget _buildOnlineAstroTile(OnlineAstrologerModel astro) {
  // ---- SAFE IMAGE URL HANDLING ----
  final String imageUrl = (astro.profileImage.isNotEmpty)
      ? (astro.profileImage.startsWith("http")
      ? astro.profileImage
      : "https://fastapi.jyotishionline.com${astro.profileImage}")
      : "https://via.placeholder.com/150";

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // ---- IMAGE ----
      ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          imageUrl,
          height: 60,
          width: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: const Icon(Icons.person, size: 30, color: Colors.white),
            );
          },
        ),
      ),

      const SizedBox(height: 6),

      // ---- NAME ----
      SizedBox(
        width: 80,
        child: Text(
          astro.name.isNotEmpty ? astro.name : "Unknown",
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      const SizedBox(height: 3),

      // ---- STATUS ----
      const Text(
        "Online",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    ],
  );
}




class LiveAstroCard extends StatelessWidget {
  final LiveAstrologerModel astro;

  const LiveAstroCard({super.key, required this.astro});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final api = FastAPIServices();

        try {
          // 🔥 Call join live API
          final res = await api.joinLive(astroId: astro.astroId);

          final channelName = res["channelName"];
          final rtcToken = res["rtc_token"];

          // Navigate to live viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveViewerPage(
                channelName: channelName,
                token: rtcToken,
                astroId: astro.astroId,
              ),
            ),
          );
        } catch (e) {
          print("❌ Failed to join live: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cannot join live right now")),
          );
        }
      },

      child: Container(
        width: 130,
        margin: EdgeInsets.only(right: 15),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    "https://fastapi.jyotishionline.com${astro.profileImage}",
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
                ),

                // 🔴 LIVE badge
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "LIVE",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Astrologer Name
            Text(
              astro.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Skill
            Text(
              astro.primarySkill,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}




Widget _buildAstroTile(GetAllAstrologerModel astrologer) {
  final rawImagePath = (astrologer.profileImage ?? '').trim();
  final hasImage = rawImagePath.isNotEmpty && !rawImagePath.toLowerCase().contains('null');

  // Fix: prepend base URL
  final imageUrl = hasImage
      ? (rawImagePath.startsWith("http")
      ? rawImagePath
      : "https://fastapi.jyotishionline.com$rawImagePath")
      : "";

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 80,
        height: 80,
        child: ClipOval(
          child: hasImage
              ? Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appColor),
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholderAvatar(astrologer.name ?? 'A'),
          )
              : _buildPlaceholderAvatar(astrologer.name ?? 'A'),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: 80,
        child: Text(
          astrologer.name ?? 'Unknown',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

// Helper method for placeholder avatar with initials
Widget _buildPlaceholderAvatar(String name) {
  final initials = name.isNotEmpty
      ? name
          .trim()
          .split(' ')
          .map((e) => e.isNotEmpty ? e[0] : '')
          .take(2)
          .join()
      : 'A';

  return Container(
    decoration: BoxDecoration(
      color: appYellow,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
  );
}

// Helper widget to build the skills and language chips
Widget _buildSkillLanguageRow(String? skill, String? language) {
  return Wrap(
    spacing: 8.0,
    runSpacing: 4.0,
    children: [
      _buildInfoChip(Icons.psychology_alt, skill ?? '—'),
      _buildInfoChip(Icons.language, language ?? '—'),
    ],
  );
}

// Helper widget for a single info chip
Widget _buildInfoChip(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.deepPurple),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
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
