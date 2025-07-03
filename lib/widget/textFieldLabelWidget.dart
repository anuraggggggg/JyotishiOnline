import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class TextFieldLabelWidget extends StatelessWidget {
  final label;
  const TextFieldLabelWidget({Key? key, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
      child: Text(
        label,
        style: Get.theme.textTheme.titleMedium!.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ).tr(),
    );
  }
}
