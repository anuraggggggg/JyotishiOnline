// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/theme/nativeTheme.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/themeController.dart';

// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/theme/nativeTheme.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/themeController.dart';
import '../../theme/appTheme.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({Key? key, this.themeMode}) : super(key: key);
  final ValueChanged<ThemeMode>? themeMode;

  @override
  _ColorPickerPageState createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage>
    with SingleTickerProviderStateMixin {
  List<Color> fullMaterialColors = [
    Color(0xffef5350),
    Color(0xff3342ae),
    Colors.red,
    Colors.redAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.purple,
    Colors.purpleAccent,
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.indigoAccent,
    Colors.blue,
    Colors.blueAccent,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.teal,
    Colors.tealAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.amberAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.white,
    appYellow

  ];

  BottomNavigationController bottomNavigationController =
  Get.find<BottomNavigationController>();
  ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    // Set transparent status bar when page loads
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.dark,
    // ));
    //
    // if (themeController.pickColor != appYellow) {
    //   themeController.setPickColor(appYellow);
    // }

  }

  @override
  Widget build(BuildContext context) {
    // Ensure status bar stays transparent even when color changes
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.dark,
    // ));

    return WillPopScope(
      onWillPop: (() async {
        bottomNavigationController.setBottomIndex(0, 1);
        bottomNavigationController.update();
        Get.off(() => BottomNavigationBarScreen());
        return true;
      }),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: GetBuilder<ThemeController>(builder: (c) {
            return AppBar(
              backgroundColor: themeController.pickColor,
              elevation: 0, // Remove shadow
              title: Text(
                'Theme',
                style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: themeController.pickColor == Colors.white
                      ? Colors.black
                      : Colors.white,
                ),
              ).tr(),
              leading: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  bottomNavigationController.setBottomIndex(0, 1);
                  bottomNavigationController.update();
                  Get.off(() => BottomNavigationBarScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Icon(
                    kIsWeb
                        ? Icons.arrow_back
                        : Platform.isIOS
                        ? Icons.arrow_back_ios
                        : Icons.arrow_back,
                    color: themeController.pickColor == Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
        body: Scrollbar(
          child: GetBuilder<ThemeController>(builder: (themeController) {
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                      ),
                      itemCount: fullMaterialColors.length,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            themeController.setPickColor(fullMaterialColors[index]);
                            // Keep status bar transparent after color change
                            // SystemChrome.setSystemUIOverlayStyle(
                            //   SystemUiOverlayStyle(
                            //     statusBarColor: Colors.transparent,
                            //     statusBarIconBrightness: Brightness.dark,
                            //   ),
                            // );
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: fullMaterialColors[index],
                                  ),
                                ),
                              ),
                              fullMaterialColors[index].value ==
                                  themeController.pickColor.value
                                  ? Icon(
                                Icons.check,
                                color: fullMaterialColors[index] == Colors.white
                                    ? Colors.black
                                    : Colors.white,
                              )
                                  : SizedBox(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}