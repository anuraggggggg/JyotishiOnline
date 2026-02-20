// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/splashController.dart';
import 'chat/newChatScreen.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  final int index;

  const BottomNavigationBarScreen({super.key, this.index = 0});

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {

  /// ---------------- ICONS ----------------
  final List<IconData> iconList = [
    Icons.home,
    Icons.chat,
    Icons.call,
    Icons.star,
  ];

  /// ---------------- CONTROLLERS ----------------
  final HomeController homeController = Get.find<HomeController>();
  final HistoryController historyController = Get.find<HistoryController>();
  final ChatController chatController = Get.find<ChatController>();
  final SplashController splashController = Get.find<SplashController>();
  final BottomNavigationController bottomNavigationController =
  Get.find<BottomNavigationController>();


  /// ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _restoreActiveChat();
  }


  /// ---------------- RESTORE CHAT ----------------
  Future<void> _restoreActiveChat() async {
    final prefs = await SharedPreferences.getInstance();

    final isActive = prefs.getBool("chat_active") ?? false;
    if (!isActive) return;

    final astroId = prefs.getString("astro_id");
    final roomId = prefs.getString("room_id");
    final astroName = prefs.getString("astro_name");

    if (astroId == null || roomId == null || astroName == null) return;

    Future.delayed(const Duration(milliseconds: 400), () {
      Get.to(() => CustomerChatPage(
        astrologerUserId: astroId,
        astrologerProfileId: "",
        roomId: roomId,
        myUserId: "",
        astrologerName: astroName,
      ));
    });
  }


  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GetBuilder<BottomNavigationController>(builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,

          /// ---------- BOTTOM NAV ----------
          bottomNavigationBar: kIsWeb
              ? const SizedBox()
              : SafeArea(
            top: false,
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: appYellow,
              unselectedItemColor: Colors.grey,
              iconSize: 22.sp,
              currentIndex:
              bottomNavigationController.bottomNavIndex,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 8,

              /// ---------- ITEMS ----------
              items: List.generate(iconList.length, (index) {
                if (index == 1) {
                  return BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
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
                      colorFilter: const ColorFilter.mode(
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
                }

                return BottomNavigationBarItem(
                  icon: Icon(iconList[index]),
                  activeIcon: Icon(iconList[index]),
                  label: '',
                );
              }),

              /// ---------- TAP ----------
              onTap: (index) {
                bottomNavigationController.setBottomIndex(index, 0);
              },
            ),
          ),

          /// ---------- BODY ----------
          body: bottomNavigationController
              .screens()
              .elementAt(bottomNavigationController.bottomNavIndex),
        );
      }),
    );
  }
}
