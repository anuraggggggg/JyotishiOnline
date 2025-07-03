// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import '../controllers/bottomNavigationController.dart';
import '../utils/images.dart';
import '../views/bottomNavigationBarScreen.dart';

class CommonAppBar extends StatelessWidget {
  final int flagId;
  final String title;
  final isProfilePic;
  final String? profileImg;
  List<Widget>? actions;
  CommonAppBar(
      {Key? key,
      required this.title,
      this.isProfilePic = false,
      this.profileImg,
      this.actions,
      this.flagId = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: actions,
      backgroundColor: Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
      title: isProfilePic
          ? Row(
              children: [
                profileImg == ""
                    ? CircleAvatar(
                        backgroundImage: AssetImage(Images.deafultUser),
                      )
                    : CachedNetworkImage(
                        imageUrl: "${global.imgBaseurl}$profileImg",
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            backgroundColor: Get.theme.primaryColor,
                            backgroundImage: imageProvider,
                          );
                        },
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) {
                          return CircleAvatar(
                              backgroundColor: Get.theme.primaryColor,
                              child: Image.asset(
                                Images.deafultUser,
                                fit: BoxFit.fill,
                                height: 40,
                              ));
                        },
                      ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ).tr(),
              ],
            )
          : Text(
              title,
              style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ).tr(),
      leading: IconButton(
        onPressed: () {
          if (flagId == 1) {
            BottomNavigationController bottomNavigationController =
                Get.find<BottomNavigationController>();
            bottomNavigationController.setIndex(0, 0);
            Get.to(() => BottomNavigationBarScreen(
                  index: 0,
                ));
          } else {
            Get.back();
          }
        },
        icon: Icon(
            kIsWeb
                ? Icons.arrow_back
                : Platform.isIOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back,
            color: Colors.black //Get.theme.iconTheme.color,
            ),
      ),
    );
  }
}
