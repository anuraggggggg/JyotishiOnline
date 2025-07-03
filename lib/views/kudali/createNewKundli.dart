import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/widget/createKundliTitleWidget.dart';
import 'package:AstrowayCustomer/widget/kundliBrithdateWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../../widget/kudliBirthTimeWidget.dart';
import '../../widget/kudliBornPlaceWidget.dart';
import '../../widget/kundliGenderWidget.dart';
import '../../widget/kundliNameWidget.dart';

class CreateNewKundki extends StatelessWidget {
  CreateNewKundki({Key? key}) : super(key: key);
  final KundliController kundliController = Get.find<KundliController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        width: double.infinity,
        height: Get.height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topLeft, colors: [Get.theme.primaryColor, Colors.white]),
        ),
        child: SingleChildScrollView(
          child: GetBuilder<KundliController>(builder: (c) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.arrow_back_ios,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Kundli', style: Get.textTheme.titleMedium).tr()
                  ],
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 5,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: kundliController.listIcon[index].isSelected
                            ? CircleAvatar(
                                radius: 13,
                                backgroundColor: Get.theme.primaryColor,
                                child: Icon(
                                  kundliController.listIcon[kundliController.initialIndex].icon,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              )
                            : kundliController.initialIndex >= index
                                ? GestureDetector(
                                    onTap: () {
                                      kundliController.backStepForCreateKundli(index);
                                      kundliController.updateIcon(kundliController.initialIndex);
                                    },
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Get.theme.primaryColor,
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.grey,
                                  ),
                      );
                    },
                  ),
                ),
                CreateKundliTitleWidget(
                  title: kundliController.initialIndex == 0
                      ? kundliController.kundliTitle[0]
                      : kundliController.initialIndex == 1
                          ? kundliController.kundliTitle[1]
                          : kundliController.initialIndex == 2
                              ? kundliController.kundliTitle[2]
                              : kundliController.initialIndex == 3
                                  ? kundliController.kundliTitle[3]
                                  : kundliController.kundliTitle[4],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (kundliController.initialIndex == 0)
                  KundliNameWidget(
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                    kundliController: kundliController,
                    onPressed: () {
                      if (!kundliController.isDisable) {
                        kundliController.updateInitialIndex();
                        kundliController.updateIcon(kundliController.initialIndex);
                      }
                    },
                  ),
                if (kundliController.initialIndex == 1)
                  KundliGenderWidget(
                    kundliController: kundliController,
                  ),
                if (kundliController.initialIndex == 2)
                  KundliBirthDateWidget(
                    kundliController: kundliController,
                    onPressed: () {
                      kundliController.updateInitialIndex();
                      kundliController.updateIcon(kundliController.initialIndex);
                    },
                  ),
                if (kundliController.initialIndex == 3)
                  KundliBirthTimeWidget(
                    kundliController: kundliController,
                    onPressed: () {
                      kundliController.updateInitialIndex();
                      kundliController.updateIcon(kundliController.initialIndex);
                    },
                  ),
                if (kundliController.initialIndex == 4)
                  KundliBornPlaceWidget(
                    kundliController: kundliController,
                  )
              ],
            );
          }),
        ),
      ),
    ));
  }
}
