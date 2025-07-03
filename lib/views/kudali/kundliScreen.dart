import 'dart:math';

import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/views/kudali/createNewKundli.dart';
import 'package:AstrowayCustomer/views/kudali/editKundliScreen.dart';
import 'package:AstrowayCustomer/views/kudali/kundliDetailsScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;


// ignore: must_be_immutable
class KundaliScreen extends StatelessWidget {
  int? flag;
  KundaliScreen({Key? key, this.flag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child:  kIsWeb?
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(onTap: () => Get.back(), child: Icon(Icons.arrow_back_ios)),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Kundli', style: Get.textTheme.titleMedium).tr()
                ],
              ),
              SizedBox(
                height: 15,
              ),
              GetBuilder<KundliController>(builder: (kundliController) {
                return SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: (value) {
                      kundliController.searchKundli(value);
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Get.theme.iconTheme.color,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        hintText:tr('Search kundli by name'),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 11.8, fontWeight: FontWeight.w500)),
                  )
                );
              }),
              GetBuilder<KundliController>(builder: (kundliController) {
                return kundliController.searchKundliList.length == 0
                    ? Column(
                        children: [
                          Container(
                              height: 500,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              alignment: Alignment.center,
                              child: Text(
                                'Kundli not available',
                                style: TextStyle(fontSize: 18),
                              ).tr()),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: kundliController.searchKundliList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              global.showOnlyLoaderDialog(context);
                              kundliController.pdfKundali(kundliController.searchKundliList[index].id.toString()).then((value) {

                                global.hideLoader();
                                Get.to(() => KundliDetailsScreen());
                              });

                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8),
                                leading: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(color: Colors.primaries[Random().nextInt(Colors.primaries.length)], borderRadius: BorderRadius.circular(7)),
                                  child: Center(child: Text(kundliController.searchKundliList[index].name[0].toUpperCase(), style: TextStyle(color: Colors.white))),
                                ),
                                title: Text(kundliController.searchKundliList[index].name, style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500)).tr(),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat("dd MMM yyyy").format(kundliController.searchKundliList[index].birthDate)},${kundliController.searchKundliList[index].birthTime}',
                                      style: Get.textTheme.titleMedium!.copyWith(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      kundliController.searchKundliList[index].birthPlace,
                                      style: Get.textTheme.titleMedium!.copyWith(fontSize: 12, color: Colors.grey),
                                    ).tr(),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        global.showOnlyLoaderDialog(context);
                                        await kundliController.getKundliListById(index);

                                        global.hideLoader();
                                        Get.to(() => EditKundliScreen(id: kundliController.searchKundliList[index].id!));
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Color.fromARGB(255, 235, 231, 231),
                                        radius: 12,
                                        child: Icon(Icons.edit, size: 14, color: Colors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.dialog(
                                          AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: Text(
                                              "Are you sure you want to permanently delete this kundli?",
                                              style: Get.textTheme.bodyMedium,
                                            ).tr(),
                                            content: Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: const Text('NO').tr(),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      global.showOnlyLoaderDialog(context);
                                                      await kundliController.deleteKundli(kundliController.searchKundliList[index].id!);
                                                      await kundliController.getKundliList();
                                                      Get.back();
                                                      global.hideLoader();
                                                    },
                                                    child: const Text('YES').tr(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Color.fromARGB(255, 235, 231, 231),
                                        radius: 12,
                                        child: Icon(Icons.delete, size: 14, color: Colors.red),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
              }),
              const SizedBox(height: 48),
            ],
          ):
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(onTap: () => Get.back(), child: Icon(Icons.arrow_back_ios)),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Kundli', style: Get.textTheme.titleMedium).tr()
                ],
              ),
              SizedBox(
                height: 15,
              ),
              GetBuilder<KundliController>(builder: (kundliController) {
                return SizedBox(
                    height: 38,
                    child: TextField(
                      onChanged: (value) {
                        kundliController.searchKundli(value);
                      },
                      decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Get.theme.iconTheme.color,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          ),
                          hintText:tr('Search kundli by name'),
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 11.8, fontWeight: FontWeight.w500)),
                    )
                );
              }),
              GetBuilder<KundliController>(builder: (kundliController) {
                return kundliController.searchKundliList.length == 0
                    ? Column(
                  children: [
                    Container(
                        height: 500,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        alignment: Alignment.center,
                        child: Text(
                          'Kundli not available',
                          style: TextStyle(fontSize: 18),
                        ).tr()),
                  ],
                )
                    : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: kundliController.searchKundliList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          global.showOnlyLoaderDialog(context);
                          kundliController.pdfKundali(kundliController.searchKundliList[index].id.toString()).then((value) {
                            global.hideLoader();
                            Get.to(() => KundliDetailsScreen());
                          });
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8),
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(color: Colors.primaries[Random().nextInt(Colors.primaries.length)], borderRadius: BorderRadius.circular(7)),
                              child: Center(child: Text(kundliController.searchKundliList[index].name[0].toUpperCase(), style: TextStyle(color: Colors.white))),
                            ),
                            title: Text(kundliController.searchKundliList[index].name, style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500)).tr(),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat("dd MMM yyyy").format(kundliController.searchKundliList[index].birthDate)},${kundliController.searchKundliList[index].birthTime}',
                                  style: Get.textTheme.titleMedium!.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  kundliController.searchKundliList[index].birthPlace,
                                  style: Get.textTheme.titleMedium!.copyWith(fontSize: 12, color: Colors.grey),
                                ).tr(),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    global.showOnlyLoaderDialog(context);
                                    await kundliController.getKundliListById(index);

                                    global.hideLoader();
                                    Get.to(() => EditKundliScreen(id: kundliController.searchKundliList[index].id!));
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Color.fromARGB(255, 235, 231, 231),
                                    radius: 12,
                                    child: Icon(Icons.edit, size: 14, color: Colors.black),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.dialog(
                                      AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text(
                                          "Are you sure you want to permanently delete this kundli?",
                                          style: Get.textTheme.bodyMedium,
                                        ).tr(),
                                        content: Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                child: const Text('NO').tr(),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  global.showOnlyLoaderDialog(context);
                                                  await kundliController.deleteKundli(kundliController.searchKundliList[index].id!);
                                                  await kundliController.getKundliList();
                                                  Get.back();
                                                  global.hideLoader();
                                                },
                                                child: const Text('YES').tr(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Color.fromARGB(255, 235, 231, 231),
                                    radius: 12,
                                    child: Icon(Icons.delete, size: 14, color: Colors.red),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              }),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomSheet: SizedBox(
        height: 60,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.all(10)),
              backgroundColor: WidgetStateProperty.all(Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            onPressed: () {
              KundliController kundliController = Get.find<KundliController>();
              kundliController.userName = "";
              kundliController.userNameController.clear();
              kundliController.birthKundliPlaceController.clear();
              kundliController.selectedGender = null;
              kundliController.selectedDate = null;
              kundliController.selectedTime = null;
              kundliController.isDisable = true;
              kundliController.initialIndex = 0;
              kundliController.updateIcon(0);
              kundliController.updateAllBg();
              kundliController.update();
              kundliController.pdfPrice().then((value) {
              if(value==1)
                {
                  Get.to(() => CreateNewKundki());
                }
              else
                {
                  Fluttertoast.showToast(msg: "Something went wrong");
                }
              });

            },
            child: Text(
              'Create New Kundli',
              textAlign: TextAlign.center,
              style: Get.theme.primaryTextTheme.titleMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w500,
              color: Colors.white),
            ).tr(),
          ),
        ),
      ),
    ));
  }
}
