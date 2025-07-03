import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/views/kundliMatching/kudliMatchingResultScreen.dart';
import 'package:AstrowayCustomer/views/kundliMatching/newMatchingScreen.dart';
import 'package:AstrowayCustomer/views/kundliMatching/openKundliScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;


import '../../controllers/kundliMatchingController.dart';
import '../../widget/commonAppbar.dart';

class KundliMatchingScreen extends StatelessWidget {
  KundliMatchingScreen({Key? key}) : super(key: key);
  final KundliMatchingController kundliMatchingController = Get.find<KundliMatchingController>();
  final KundliController kundliController = Get.find<KundliController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<KundliMatchingController>(
          init: kundliMatchingController,
          builder: (controller) {
            return Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: CommonAppBar(
                    title: 'Kundli Matching',
                  )),
              body: Container(
                decoration: const BoxDecoration(
                 color: Colors.white
                ),
                child: DefaultTabController(
                    length: 2,
                    initialIndex: kundliMatchingController.currentIndex,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: TabBar(
                                unselectedLabelColor: Colors.black,
                                labelColor: Colors.black,
                                indicatorWeight: 0.1,
                                indicatorColor: Colors.blue,
                                labelPadding: EdgeInsets.zero,
                                tabs: [
                                  Obx(
                                    () => kundliMatchingController.homeTabIndex.value == 0
                                        ? Container(
                                            height: Get.height,
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              color: Get.theme.primaryColor,
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                              border: Border.all(color: Colors.grey),
                                            ),
                                            child: Center(child: Text('Open Kundli',style: TextStyle(
                                              color: Colors.white
                                            ),).tr()),
                                          )
                                        : Center(
                                            child: Text('Open Kundli',
                                            style: TextStyle(),).tr(),
                                          ),
                                  ),
                                  Obx(
                                    () => kundliMatchingController.homeTabIndex.value == 1
                                        ? Container(
                                            height: Get.height,
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              color: Get.theme.primaryColor,
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(12),
                                                topLeft: Radius.circular(12),
                                                bottomRight: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                              ),
                                              border: Border.all(color: Colors.grey),
                                            ),
                                            child: Center(child: Text('New Matching',
                                            style: TextStyle(
                                              color: Colors.white
                                            ),).tr()),
                                          )
                                        : Center(
                                            child: Text('New Matching').tr(),
                                          ),
                                  ),
                                ],
                                onTap: (index) {
                                  global.showOnlyLoaderDialog(Get.context);
                                  kundliMatchingController.onHomeTabBarIndexChanged(index);
                                  global.hideLoader();
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: kundliMatchingController.homeTabIndex.value == 1
                              ?
//First Tabbar
                              NewMatchingScreen()
                              :
//Second Tabbar
                              OpenKundliScreen(),
                        )
                      ],
                    )),
              ),
              bottomNavigationBar: kundliMatchingController.homeTabIndex.value == 1
                  ? Container(
                      decoration: const BoxDecoration(
                        color: Colors.white
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Get.theme.primaryColor,
                            maximumSize: Size(MediaQuery.of(context).size.width, 100),
                            minimumSize: Size(MediaQuery.of(context).size.width, 48),
                          ),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            bool isvalid = kundliMatchingController.isValidData();
                            if (!isvalid) {
                              global.showToast(
                                message: kundliMatchingController.errorMessage ?? "",
                                textColor: global.textColor,
                                bgColor: global.toastBackGoundColor,
                              );
                            } else {
                              _showMyDialog(context);
                            }
                          },
                          child: const Text(
                            "Match Horoscope",
                            style: TextStyle(color: Colors.white),
                          ).tr(),
                        ),
                      ),
                    )
                  : const SizedBox(),
            );
          }),
    );
  }

  void _showMyDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return const MyDialog();
      },
    );
    if (result != null) {
      debugPrint('Selected Direction: $result');
    }
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});
  @override
  _MyDialogState createState() => _MyDialogState();
}
final KundliMatchingController kundliMatchingController =
Get.find<KundliMatchingController>();
class _MyDialogState extends State<MyDialog> {
  String direction="South";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Choose Direaction').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('South'),
            leading: Radio(
              value: tr('South'),
              groupValue:direction ,
              onChanged: (value) {
                setState(() {});
                direction=value as String;
              },
            ),
          ),
          ListTile(
            title: const Text('North'),
            leading: Radio(
              value: tr('North'),
              groupValue: direction,
              onChanged: (value) {
                setState(() {});
                direction=value as String;
              },
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await kundliMatchingController.addKundliMatchData(direction);
            kundliMatchingController.update();
            Get.to(() => KudliMatchingResultScreen(northKundaliMatchingModel: kundliMatchingController.northKundaliMatchingModel,
            southKundaliMatchingModel: kundliMatchingController.southKundaliMatchingModel,));
            // Get.back();

            //  await kundliMatchingController.addKundliMatchData();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
