import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CreateKundliTitleWidget extends StatelessWidget {
  final String title;
  const CreateKundliTitleWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Get.textTheme.headlineSmall).tr();
  }
}
