import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function onBackPressed;
  final List<Widget> actions;
  final Color bgColor;
  final TextStyle titleStyle;
  final int flagId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int ?flagforCategory;
  CustomAppBar({required this.title, required this.bgColor, this.flagId = 0, required this.onBackPressed, required this.actions, required this.titleStyle, required this.scaffoldKey,this.flagforCategory});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor:bgColor,
      leading: InkWell(
        onTap: () {
          if(flagforCategory==1)
          {
            Get.back();
          }
          else{
            if (scaffoldKey.currentState!.isDrawerOpen) {
              scaffoldKey.currentState!.closeDrawer();
              Get.back();
            } else {
              scaffoldKey.currentState!.openDrawer();
            }
          }

        },
        child: Icon(
          flagId == 1
              ? Icons.menu
              : (flagId == 2
                  ? (flagforCategory==0?Icons.phone:Icons.arrow_back)
                  : Icons.menu),
          color: Colors.black//Get.theme.iconTheme.color,
        ),
      ),
      title: Text(
        title,
        style: titleStyle,
      ).tr(),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
