import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EndDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        "You can end chat after one minute",
        style: Get.textTheme.titleMedium,
      ).tr(),
      actions: [
        CupertinoDialogAction(
          onPressed: () async {
            // Your onPressed logic here
            Get.back();
          },
          child: Text('OK', style: TextStyle(color: Colors.blue)).tr(),
        ),
      ],
    );
  }
}
