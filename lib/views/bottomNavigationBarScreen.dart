// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/model/fastApiModel/UserModel.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/splashController.dart';
import '../utils/AppColors.dart';
import '../utils/global.dart' as global;

class BottomNavigationBarScreen extends StatelessWidget {
  final int index;

  BottomNavigationBarScreen({
    this.index = 0,
  }) : super();

  // Added one more icon for the new services tab
  final List<IconData> iconList = [
    Icons.home,
    Icons.chat,
    Icons.call,
    Icons.history_sharp,
    Icons.star, // New tab icon (you can change to any icon)
  ];

  final HomeController homeController = Get.find<HomeController>();
  final HistoryController historyController = Get.find<HistoryController>();
  final ChatController chatController = Get.find<ChatController>();
  final SplashController splashController = Get.find<SplashController>();
  final BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GetBuilder<BottomNavigationController>(builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: kIsWeb
              ? const SizedBox()
              : GetBuilder<BottomNavigationController>(
                  builder: (c) {
                    return SizedBox(
                      height: 8.h,
                      child: BottomNavigationBar(
                        backgroundColor: Colors.white,
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: appYellow,
                        unselectedItemColor: Colors.grey,
                        iconSize: 22.sp,
                        currentIndex: bottomNavigationController.bottomNavIndex,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        elevation: 5,
                        items: List.generate(iconList.length, (index) {
                          bool isSelected =
                              bottomNavigationController.bottomNavIndex ==
                                  index;

                          if (index == 1) {
                            // Custom Chat Icon
                            return BottomNavigationBarItem(
                              icon: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  'assets/images/chat1.png',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              activeIcon: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  appYellow,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  'assets/images/chat1.png',
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                              label: '',
                            );
                          } else {
                            return BottomNavigationBarItem(
                              icon: Icon(iconList[index]),
                              activeIcon: Icon(iconList[index]),
                              label: '',
                            );
                          }
                        }),
                        onTap: (index) async {
                          if (index == 3) {
                            bool isLogin = await global.isLogin();
                            if (isLogin) {
                              global.showOnlyLoaderDialog(context);
                              await global.splashController
                                  .getCurrentUserData();
                              await historyController.getPaymentLogs(
                                  global.currentUserId!, false);
                              historyController.walletTransactionList.clear();
                              historyController.walletAllDataLoaded = false;
                              await historyController.getWalletTransaction(
                                  global.currentUserId!, false);
                              global.hideLoader();
                            }
                          }

                          bottomNavigationController.setBottomIndex(
                              index, bottomNavigationController.historyIndex);
                        },
                      ),
                    );
                  },
                ),
          body: bottomNavigationController
              .screens()
              .elementAt(bottomNavigationController.bottomNavIndex),
        );
      }),
    );
  }
}
