import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

class QuickLinnkWidget extends StatelessWidget {
  final String image;
  final String text;
  final void Function() onTap;
  const QuickLinnkWidget(
      {Key? key, required this.image, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 13.h,
        height: 13.h,
        margin: EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: 4.h,
              width: 4.h,
            ),
            SizedBox(
              height: 1.h,
            ),
            Center(
                child: Text(
              text,
              style: Get.textTheme.titleMedium!.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ).tr())
          ],
        ),
      ),
    );
  }
}
