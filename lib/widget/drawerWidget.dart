// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:AstrowayCustomer/controllers/advancedPanchangController.dart';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/counsellorController.dart';
import 'package:AstrowayCustomer/controllers/follow_astrologer_controller.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/themeController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/views/freeServicesScreen.dart';
import 'package:AstrowayCustomer/views/getReportScreen.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:AstrowayCustomer/views/myFollowingScreen.dart';
import 'package:AstrowayCustomer/views/profile/editUserProfileScreen.dart';
import 'package:AstrowayCustomer/views/settings/colorPicker.dart';
import 'package:AstrowayCustomer/views/settings/settingsScreen.dart';
import 'package:AstrowayCustomer/views/wallet/paymentLogScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';

import '../controllers/astrologer_assistant_controller.dart';
import '../controllers/customer_support_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/images.dart';
import '../views/callScreen.dart';
import '../views/counsellor/counsellorScreen.dart';
import '../views/customer_support/customerSupportChatScreen.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final SplashController splashController = Get.find<SplashController>();

  CallController callController = Get.put(CallController());

  PanchangController panchangController = Get.find<PanchangController>();

  HistoryController historyController = Get.find<HistoryController>();
  String? userName;

  @override
  void initState() {
    super.initState();

    _loadUserName();
  }

  Future<void> _loadUserName() async {


    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name"); // read the saved name
       var userId = FastAPIServices().userId ;  // read the saved name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      child: SingleChildScrollView(
        child: GetBuilder<SplashController>(builder: (splashController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {

                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EditCustomerDetailsPage()),
                        );

                      },
                      child:
                           CachedNetworkImage(
                              imageUrl:
                                  "${global.imgBaseurl}${splashController.currentUser?.profile}",
                              imageBuilder: (context, imageProvider) {
                                return CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                      "${global.imgBaseurl}${splashController.currentUser?.profile}"),
                                );
                              },
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) {
                                return CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Get.theme.primaryColor.withOpacity(0.2),
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Get.theme.primaryColor,
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName == null || userName == ""
                                ? "Guest User"
                                : "${userName}",
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).tr(),
                          if (splashController.currentUser != null &&
                              splashController.currentUser!.email != null &&
                              splashController.currentUser!.email!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${splashController.currentUser!.email}',
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (splashController.currentUser != null &&
                              splashController.currentUser!.contactNo != null &&
                              splashController
                                  .currentUser!.contactNo!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                '${splashController.currentUser!.countryCode}-${splashController.currentUser!.contactNo}',
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // _buildMenuItem(
                    //   icon: Icons.note_alt_outlined,
                    //   title: 'Get Report',
                    //   onTap: () async {
                    //     final BottomNavigationController
                    //         bottomNavigationController =
                    //         Get.find<BottomNavigationController>();
                    //     bottomNavigationController.astrologerList = [];
                    //     bottomNavigationController.astrologerList.clear();
                    //     bottomNavigationController.isAllDataLoaded = false;
                    //     bottomNavigationController.update();
                    //     global.showOnlyLoaderDialog(context);
                    //     await bottomNavigationController.getAstrologerList(
                    //         isLazyLoading: false);
                    //     global.hideLoader();
                    //     Get.to(() => GetReportScreen());
                    //   },
                    // ),

                    _buildMenuItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat with Astrologer',
                      onTap: () async {
                        Get.to(() => CallAstrologerScreen());
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons
                          .payment, // you can choose any payment-related icon
                      title: 'Payment Logs',
                      onTap: () async {
                        Get.to(() => PaymentLogScreen());
                        // global.showOnlyLoaderDialog(context);

                        // // final navController = Get.find<BottomNavigationController>();
                        // // // 🟢 Clear old data if you keep it in controller
                        // // navController.paymentLogsList = [];
                        // // navController.paymentLogsList.clear();
                        // // navController.isAllPaymentLogsLoaded = false;
                        // // navController.update();

                        // // 🟢 Fetch Payment Logs (replace with your actual API call)
                        // await navController.getPaymentLogs(isLazyLoading: false);

                        // global.hideLoader();

                        // Switch to Payment Logs tab/screen
                        // navController.setBottomIndex(3, 0);
                      },
                    ),

                    // _buildMenuItem(
                    //   icon: Icons.people_alt_outlined,
                    //   title: 'Chat With Counsellors',
                    //   onTap: () async {
                    //     global.showOnlyLoaderDialog(context);
                    //     final counsellorController =
                    //         Get.find<CounsellorController>();
                    //     counsellorController.counsellorList = [];
                    //     counsellorController.update();
                    //     await counsellorController.getCounsellorsData(false);
                    //     global.hideLoader();
                    //     Get.to(() => CounsellorScreen());
                    //   },
                    // ),

                    // _buildMenuItem(
                    //   icon: Icons.verified_user_outlined,
                    //   title: 'My Following',
                    //   onTap: () async {
                    //     // bool isLogin = await global.isLogin();
                    //     // if (isLogin) {
                    //     //   final followAstrologerController =
                    //     //       Get.find<FollowAstrologerController>();
                    //     //   followAstrologerController.followedAstrologer.clear();
                    //     //   followAstrologerController.isAllDataLoaded = false;
                    //     //   global.showOnlyLoaderDialog(context);
                    //     //   await followAstrologerController
                    //     //       .getFollowedAstrologerList(false);
                    //     //   global.hideLoader();
                    //     //   Get.to(() => MyFollowingScreen());
                    //     }
                    //   },
                    // ),

                    // _buildMenuItem(
                    //   icon: Icons.workspace_premium_outlined,
                    //   title: 'Free Services',
                    //   onTap: () async {
                    //     DateTime datePanchang = DateTime.now();
                    //     int formattedYear = int.parse(DateFormat('yyyy').format(datePanchang));
                    //     int formattedDay = int.parse(DateFormat('dd').format(datePanchang));
                    //     int formattedMonth = int.parse(DateFormat('MM').format(datePanchang));
                    //     int formattedHour = int.parse(DateFormat('HH').format(datePanchang));
                    //     int formattedMint = int.parse(DateFormat('mm').format(datePanchang));
                    //     global.showOnlyLoaderDialog(context);
                    //     await Get.find<HomeController>().getBlog();
                    //     await Get.find<HomeController>().getAstrologyVideos();
                    //     await panchangController.getPanchangDetail(
                    //       day: formattedDay,
                    //       hour: formattedHour,
                    //       min: formattedMint,
                    //       month: formattedMonth,
                    //       year: formattedYear,
                    //     );
                    //     global.hideLoader();
                    //     Get.to(() => FreeServiceScreen());
                    //   },
                    // ),

                    _buildMenuItem(
                      icon: Icons.person_add_alt_1_outlined,
                      title: 'Sign Up as Astrologer',
                      onTap: () {
                        if (Platform.isAndroid) {
                          StoreRedirect.redirect(
                            androidAppId: "com.astrowaydiploy.user",
                          );
                        }
                      },
                    ),

                    // if (global.currentUserId != null)
                    //   _buildMenuItem(
                    //     icon: Icons.settings_outlined,
                    //     title: 'Settings',
                    //     onTap: () async {
                    //       final settingsController =
                    //           Get.find<SettingsController>();
                    //       global.showOnlyLoaderDialog(context);
                    //       await settingsController.getBlockAstrologerList();
                    //       global.hideLoader();
                    //       Get.to(() => SettingListScreen());
                    //     },
                    //   )
                    // else
                    //   _buildMenuItem(
                    //     icon: Icons.login_outlined,
                    //     title: 'Login',
                    //     onTap: () {
                    //       Get.off(() => LoginScreen());
                    //     },
                    //   ),

                    // _buildMenuItem(
                    //   icon: Icons.support_agent_outlined,
                    //   title: 'Support Chat',
                    //   onTap: () async {
                    //     bool isLogin = await global.isLogin();
                    //     if (isLogin) {
                    //       final customerSupportController =
                    //           Get.find<CustomerSupportController>();
                    //       final astrologerAssistantController =
                    //           Get.find<AstrologerAssistantController>();
                    //       global.showOnlyLoaderDialog(context);
                    //       await customerSupportController.getCustomerTickets();
                    //       await astrologerAssistantController
                    //           .getChatWithAstrologerAssisteant();
                    //       global.hideLoader();
                    //       Get.to(() => CustomerSupportChat());
                    //     }
                    //   },
                    // ),

                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout my account',
                      onTap: () async {
                        bool isLogin = await global.isLogin();
                        if (isLogin)

                          // Changed to an async function
                          // Close the dialog

                          // Clear all local data on the history controller
                          historyController.chatHistoryList.clear();
                        historyController.astroMallHistoryList.clear();
                        historyController.reportHistoryList.clear();
                        historyController.callHistoryList.clear();
                        historyController.paymentLogsList.clear();
                        historyController.walletTransactionList.clear();

                        // Call the new logout function from FastAPIServices
                        await FastAPIServices().logout();

                        Get.back();
                      },
                    ),
                  ],
                ),
              ),

              Divider(
                color: Colors.grey.withOpacity(0.3),
                thickness: 1,
                height: 20,
              ),

              // Social Media Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Also Available On",
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ).tr(),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSocialIcon("assets/images/facebook.png"),
                        _buildSocialIcon("assets/images/instagram.png"),
                        _buildSocialIcon("assets/images/twitter.png"),
                        _buildSocialIcon("assets/images/youtube.png"),
                      ],
                    ),
                  ],
                ),
              ),

              // App Version
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "App Version: 1.0.0",
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr(),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Get.theme.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ).tr(),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minLeadingWidth: 10,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSocialIcon(String imagePath) {
    return InkWell(
      onTap: () {
        // Add social media link functionality here
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Image.asset(
          imagePath,
          height: 20,
          width: 20,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
