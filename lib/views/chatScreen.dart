// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/filtterTabController.dart';
import 'package:AstrowayCustomer/controllers/languageController.dart';
import 'package:AstrowayCustomer/controllers/reportController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/controllers/skillController.dart';
import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/main.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/utils/AppColors.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/addMoneyToWallet.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/astrologerProfile.dart';
import 'package:AstrowayCustomer/views/callIntakeFormScreen.dart';
import 'package:AstrowayCustomer/views/chat/incoming_chat_request.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
import 'package:AstrowayCustomer/views/searchAstrologerScreen.dart';
import 'package:AstrowayCustomer/widget/customAppbarWidget.dart';
import 'package:AstrowayCustomer/widget/drawerWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final drawerKey = new GlobalKey<ScaffoldState>();

  FiltterTabController filtterTabController = Get.find<FiltterTabController>();
  SkillController skillController = Get.find<SkillController>();
  LanguageController languageController = Get.find<LanguageController>();
  ReportController reportController = Get.find<ReportController>();
  BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();
  WalletController walletController = Get.find<WalletController>();
  ChatController cController = Get.find<ChatController>();
  final walletcontroller = Get.find<WalletController>();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    global.sp = await SharedPreferences.getInstance();
    await global.sp!.reload();
    global.sp = global.sp;
    if (global.sp!.getInt('chatBottom') == 1) {
      chatController.chatBottom = true;
      chatController.update();
    } else {
      chatController.chatBottom = false;
      chatController.update();
    }
    print(global.sp);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bottomNavigationController.setBottomIndex(0, 1);
        return false;
      },
      child: Scaffold(
        // backgroundColor:appYellow,
        backgroundColor: Colors.white,
        key: drawerKey,
        drawer: DrawerWidget(),
        appBar: CustomAppBar(
          flagId: 1,
          onBackPressed: () {},
          scaffoldKey: drawerKey,
          title: 'Chat with Astrologer',
          titleStyle: Get.theme.primaryTextTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          bgColor: Colors.white,
          actions: [
            InkWell(
              onTap: () async {
                global.showOnlyLoaderDialog(context);
                await walletcontroller.getAmount();
                global.hideLoader();
                Get.to(() => AddmoneyToWallet());
              },
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  global.splashController.currentUser?.walletAmount != null
                      ? Container(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.symmetric(vertical: 17),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Image.asset("assets/images/wallet1.png", height: 20, width: 20,),
                        SizedBox(
                            width :8
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3, right: 3),
                          child: Text(
                            '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)}${global.splashController.currentUser?.walletAmount.toString()}',
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )

                      : SizedBox(),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => SearchAstrologerScreen());
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Icon(FontAwesomeIcons.magnifyingGlass,
                    size: 15, color: Colors.black //Get.theme.iconTheme.color,
                    ),
              ),
            ),
            GestureDetector(
              onTap: () {
                openBottomSheetFilter(context);
                skillController.getSkills();
                languageController.getLanguages();
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(FontAwesomeIcons.filter,
                        size: 15,
                        color: Colors.black //Get.theme.iconTheme.color,
                        ),
                  ),
                  bottomNavigationController.applyFilter
                      ? Positioned(
                          right: 4,
                          top: 15,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 4,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            )
          ],
        ),
        body: GetBuilder<ChatController>(
          builder: (chatController) {
            return DefaultTabController(
              length: chatController.categoryList.length,
              child: Column(
                children: [
                  TabBar(
                    padding: EdgeInsets.only(top: 10),
                    controller: chatController.categoryTab,
                    isScrollable: true,
                    onTap: (value) async {
                      chatController.isSelected = value;
                      if (value == 0) {
                        global.showOnlyLoaderDialog(context);
                        bottomNavigationController.astrologerList = [];
                        bottomNavigationController.astrologerList.clear();
                        bottomNavigationController.isAllDataLoaded = false;
                        bottomNavigationController.update();
                        await bottomNavigationController.getAstrologerList(
                            isLazyLoading: false);
                        global.hideLoader();
                      } else {
                        for (var i = 0;
                            i < chatController.categoryList.length;
                            i++) {
                          if (value == i) {
                            bottomNavigationController.astrologerList = [];
                            bottomNavigationController.astrologerList.clear();
                            bottomNavigationController.isAllDataLoaded = false;
                            bottomNavigationController.update();
                            global.showOnlyLoaderDialog(context);
                            await bottomNavigationController.astroCat(
                                id: chatController.categoryList[i].id!,
                                isLazyLoading: false);
                            global.hideLoader();
                          }
                        }
                      }
                      chatController.update();
                    },
                    indicatorColor: Colors.transparent,
                    labelPadding: EdgeInsets.symmetric(horizontal: 1),
                    tabs: List.generate(chatController.categoryList.length,
                        (index) {
                      return GetBuilder<ChatController>(builder: (chatco) {
                        return SizedBox(
                          height: 30,
                          child: Chip(
                            padding: EdgeInsets.only(bottom: 5),
                            backgroundColor: chatController.isSelected == index
                                ? appYellow
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: chatController.isSelected == index
                                      ? Get.theme.primaryColor
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(7)),
                            label: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                    height: 20,
                                    width: 20,
                                    imageUrl:
                                        '${global.imgBaseurl}${chatController.categoryList[index].image}',
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(
                                        Icons.grid_view_rounded,
                                        // color: Get.theme.primaryColor,
                                        color: Colors.black,
                                        size: 20),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    chatController.categoryList[index].name,
                                    style: Get.theme.primaryTextTheme.bodySmall!
                                        .copyWith(fontWeight: FontWeight.w300),
                                  ).tr(),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }),
                  ),
                  GetBuilder<BottomNavigationController>(
                      builder: (bottomNavigationController) {
                    return bottomNavigationController.astrologerList.length == 0
                        ? Container(
                            height: Get.height * 0.63,
                            child: Center(
                              child: Text(
                                'Astrologer not available',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 18),
                              ).tr(),
                            ),
                          )
                        : Expanded(
                            child: TabBarView(
                            controller: chatController.categoryTab,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(
                                chatController.categoryList.length, (index) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  bottomNavigationController.astrologerList =
                                      [];
                                  bottomNavigationController.astrologerList
                                      .clear();
                                  bottomNavigationController.isAllDataLoaded =
                                      false;
                                  if (bottomNavigationController
                                          .genderFilterList !=
                                      null) {
                                    bottomNavigationController.genderFilterList!
                                        .clear();
                                  }
                                  if (bottomNavigationController
                                          .languageFilter !=
                                      null) {
                                    bottomNavigationController.languageFilter!
                                        .clear();
                                  }
                                  if (bottomNavigationController
                                          .skillFilterList !=
                                      null) {
                                    bottomNavigationController.skillFilterList!
                                        .clear();
                                  }
                                  bottomNavigationController.applyFilter =
                                      false;
                                  bottomNavigationController.update();
                                  await bottomNavigationController
                                      .getAstrologerList(isLazyLoading: false);
                                },
                                child: TabViewWidget(
                                  astrologerList:
                                      bottomNavigationController.astrologerList,
                                ),
                              );
                            }),
                          ));
                  }),
                ],
              ),
            );
          },
        ),
        bottomSheet: GetBuilder<ChatController>(builder: (C) {
          return chatController.chatBottom == true
              ? Container(
                  color: Get.theme.primaryColor,
                  height: 40,
                  width: Get.width,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                                'Start chat with ${cController.bottomAstrologerName}')
                            .tr(),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          cController.bottomAstrologerName =
                              global.sp!.getString('bottomAstrologerName') ??
                                  '';
                          cController.bottomAstrologerProfile =
                              global.sp!.getString('bottomAstrologerProfile') ??
                                  '';
                          cController.bottomFirebaseChatId =
                              global.sp!.getString('bottomFirebaseChatId') ??
                                  '';
                          cController.bottomChatId =
                              global.sp!.getInt('bottomChatId');
                          cController.bottomAstrologerId =
                              global.sp!.getInt('bottomAstrologerId');
                          cController.bottomFcmToken =
                              global.sp!.getString('bottomFcmToken');
                          cController.update();
                          Get.to(() => IncomingChatRequest(
                              astrologerName: cController.bottomAstrologerName,
                              profile: cController.bottomAstrologerProfile,
                              fireBasechatId:
                                  cController.bottomFirebaseChatId ?? "",
                              chatId: int.parse(cController.bottomChatId!.toString()),
                              astrologerId: cController.bottomAstrologerId!,
                              fcmToken: cController.bottomFcmToken,
                              duration: cController.duration.toString()));
                        },
                        child: Text(
                          'Start',
                          style: Get.theme.primaryTextTheme.bodySmall!
                              .copyWith(color: Colors.white),
                        ).tr(),
                      ),
                    ],
                  ),
                )
              : const SizedBox();
        }),
      ),
    );
  }

  void openBottomSheetFilter(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.09,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Sort & Filter').tr(),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(Icons.close),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 2, height: 0),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Obx(
                    () => RotatedBox(
                      quarterTurns: 1,
                      child: TabBar(
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                        controller: filtterTabController.filterTab,
                        indicatorColor: Colors.pink,
                        indicatorPadding: EdgeInsets.zero,
                        labelPadding: EdgeInsets.zero,
                        indicator: BoxDecoration(),
                        indicatorWeight: 0,
                        unselectedLabelColor: Colors.grey[50],
                        onTap: (index) {
                          filtterTabController.selectedFilterIndex.value =
                              index;
                          filtterTabController.update();
                        },
                        tabs: List.generate(
                          filtterTabController.filtterList.length,
                          (ind) {
                            return RotatedBox(
                              quarterTurns: -1,
                              child: Container(
                                color: filtterTabController
                                            .selectedFilterIndex.value ==
                                        ind
                                    ? Colors.white
                                    : Colors.grey[50],
                                height: 50,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        ),
                                        color: filtterTabController
                                                    .selectedFilterIndex
                                                    .value ==
                                                ind
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        filtterTabController.filtterList[ind],
                                        style: TextStyle(color: Colors.black54),
                                      ).tr(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: RotatedBox(
                    quarterTurns: 1,
                    child: TabBarView(
                      controller: filtterTabController.filterTab,
                      children: [
                        SizedBox(
                            child: RotatedBox(
                          quarterTurns: -1,
                          child: GetBuilder<ReportController>(
                            builder: (rpcont) {
                              return GetBuilder<SkillController>(
                                builder: (c) {
                                  return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: ListView.builder(
                                          itemCount:
                                              reportController.sorting.length,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            return RadioListTile(
                                              groupValue:
                                                  reportController.groupValue,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              contentPadding: EdgeInsets.zero,
                                              activeColor: Colors.black,
                                              value: reportController
                                                  .sorting[index].id,
                                              onChanged: (val) {
                                                reportController.groupValue =
                                                    val!;

                                                reportController.update();
                                              },
                                              title: Text(reportController
                                                      .sorting[index].name!)
                                                  .tr(),
                                            );
                                          }));
                                },
                              );
                            },
                          ),
                        )),
                        SizedBox(
                            child: RotatedBox(
                          quarterTurns: -1,
                          child: GetBuilder<SkillController>(
                            builder: (c) {
                              return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: ListView.builder(
                                    itemCount: skillController.skillList.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: Colors.black,
                                        value: skillController
                                            .skillList[index].isSelected,
                                        onChanged: (value) {
                                          skillController.skillList[index]
                                              .isSelected = value!;
                                          skillController.update();
                                        },
                                        title: Text(skillController
                                                .skillList[index].name)
                                            .tr(),
                                      );
                                    },
                                  ));
                            },
                          ),
                        )),
                        SizedBox(
                            child: RotatedBox(
                          quarterTurns: -1,
                          child: GetBuilder<LanguageController>(
                            builder: (c) {
                              return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: ListView.builder(
                                      itemCount: languageController
                                          .languageList.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return CheckboxListTile(
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: Colors.black,
                                          value: languageController
                                              .languageList[index].isSelected,
                                          onChanged: (value) {
                                            languageController
                                                .languageList[index]
                                                .isSelected = value!;
                                            languageController.update();
                                          },
                                          title: Text(languageController
                                                  .languageList[index]
                                                  .languageName)
                                              .tr(),
                                        );
                                      }));
                            },
                          ),
                        )),
                        SizedBox(
                            child: RotatedBox(
                          quarterTurns: -1,
                          child: GetBuilder<FiltterTabController>(builder: (c) {
                            return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: ListView.builder(
                                    itemCount:
                                        filtterTabController.gender.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: Colors.black,
                                        value: filtterTabController
                                            .gender[index].isCheck,
                                        onChanged: (value) {
                                          filtterTabController
                                              .gender[index].isCheck = value!;
                                          filtterTabController.update();
                                        },
                                        title: Text(filtterTabController
                                                .gender[index].name)
                                            .tr(),
                                      );
                                    }));
                          }),
                        )),
                        SizedBox()
                      ],
                    ),
                  ))
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Divider(thickness: 2),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: SizedBox(
                          width: 0,
                          child: TextButton(
                            onPressed: () async {
                              skillController.skillFilterList = [];
                              filtterTabController.genderFilterList = [];
                              languageController.languageFilterList = [];
                              reportController.sortingFilter = null;
                              for (var i = 0;
                                  i < skillController.skillList.length;
                                  i++) {
                                skillController.skillList[i].isSelected = false;

                                skillController.update();
                              }
                              for (var i = 0;
                                  i < languageController.languageList.length;
                                  i++) {
                                languageController.languageList[i].isSelected =
                                    false;

                                languageController.update();
                              }
                              for (var i = 0;
                                  i < filtterTabController.gender.length;
                                  i++) {
                                filtterTabController.gender[i].isCheck = false;

                                filtterTabController.update();
                              }
                              bottomNavigationController.astrologerList = [];
                              bottomNavigationController.astrologerList.clear();
                              bottomNavigationController.isAllDataLoaded =
                                  false;
                              bottomNavigationController.skillFilterList =
                                  skillController.skillFilterList;
                              bottomNavigationController.genderFilterList =
                                  filtterTabController.genderFilterList;
                              bottomNavigationController.languageFilter =
                                  languageController.languageFilterList;
                              bottomNavigationController.applyFilter = false;
                              bottomNavigationController.update();
                              Get.back();
                              global.showOnlyLoaderDialog(context);
                              await bottomNavigationController
                                  .getAstrologerList(
                                      skills: skillController.skillFilterList,
                                      gender:
                                          filtterTabController.genderFilterList,
                                      language:
                                          languageController.languageFilterList,
                                      isLazyLoading: false);
                              global.hideLoader();

                              reportController.groupValue = 0;
                              print('done');
                              reportController.update();
                            },
                            child: Text(
                              'Reset',
                              style: TextStyle(color: Colors.black54),
                            ).tr(),
                          ),
                        )),
                        Expanded(child: GetBuilder<SkillController>(
                          builder: (controller) {
                            return SizedBox(
                              width: 80,
                              height: 55,
                              child: TextButton(
                                onPressed: () async {
                                  skillController.skillFilterList = [];
                                  filtterTabController.genderFilterList = [];
                                  languageController.languageFilterList = [];
                                  reportController.sortingFilter = null;
                                  for (var i = 0;
                                      i < skillController.skillList.length;
                                      i++) {
                                    if (skillController
                                            .skillList[i].isSelected ==
                                        true) {
                                      skillController.skillFilterList.add(
                                          skillController.skillList[i].id!);
                                      skillController.update();
                                    }
                                  }
                                  for (var i = 0;
                                      i < filtterTabController.gender.length;
                                      i++) {
                                    if (filtterTabController
                                            .gender[i].isCheck ==
                                        true) {
                                      filtterTabController.genderFilterList.add(
                                          filtterTabController.gender[i].name);
                                      filtterTabController.update();
                                    }
                                  }
                                  for (var i = 0;
                                      i <
                                          languageController
                                              .languageList.length;
                                      i++) {
                                    if (languageController
                                            .languageList[i].isSelected ==
                                        true) {
                                      languageController.languageFilterList.add(
                                          languageController
                                              .languageList[i].id!);
                                      languageController.update();
                                    }
                                  }
                                  for (var i = 0;
                                      i < reportController.sorting.length;
                                      i++) {
                                    if (reportController.groupValue ==
                                        reportController.sorting[i].id) {
                                      reportController.sortingFilter =
                                          reportController.sorting[i].value;
                                      reportController.update();
                                    }
                                  }
                                  Get.back();
                                  bottomNavigationController.astrologerList =
                                      [];
                                  bottomNavigationController.astrologerList
                                      .clear();
                                  bottomNavigationController.isAllDataLoaded =
                                      false;
                                  bottomNavigationController.applyFilter = true;
                                  bottomNavigationController.skillFilterList =
                                      skillController.skillFilterList;
                                  bottomNavigationController.genderFilterList =
                                      filtterTabController.genderFilterList;
                                  bottomNavigationController.languageFilter =
                                      languageController.languageFilterList;
                                  bottomNavigationController.sortingFilter =
                                      reportController.sortingFilter;
                                  bottomNavigationController.update();
                                  global.showOnlyLoaderDialog(context);
                                  await bottomNavigationController
                                      .getAstrologerList(
                                          skills:
                                              skillController.skillFilterList,
                                          gender: filtterTabController
                                              .genderFilterList,
                                          language: languageController
                                              .languageFilterList,
                                          sortBy:
                                              reportController.sortingFilter,
                                          isLazyLoading: true);
                                  global.hideLoader();

                                  skillController.addFilter(
                                      catId: cController
                                          .categoryList[cController.isSelected]
                                          .id,
                                      skills: skillController.skillFilterList,
                                      language:
                                          languageController.languageFilterList,
                                      gender:
                                          filtterTabController.genderFilterList,
                                      sortBy: reportController.sortingFilter);
                                },
                                child: Text(
                                  'Apply',
                                  style: TextStyle(color: Colors.white),
                                ).tr(),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(8)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Get.theme.primaryColor),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}

class TabViewWidget extends StatelessWidget {
  final List astrologerList;
  final ChatController chatController = ChatController();
  WalletController walletController = Get.find<WalletController>();
  BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();
  TabViewWidget({
    required this.astrologerList,
    Key? key,
  }) : super(key: key);

  ScrollController chatScrollController = ScrollController();

  void paginateTask() {
    chatScrollController.addListener(() async {
      if (chatScrollController.position.pixels ==
              chatScrollController.position.maxScrollExtent &&
          !bottomNavigationController.isAllDataLoaded) {
        bottomNavigationController.isMoreDataAvailable = true;
        bottomNavigationController.update();
        if (bottomNavigationController.selectedCatId == null ||
            bottomNavigationController.selectedCatId! == 0) {
          if (bottomNavigationController.isChatAstroDataLoadedOnce == false) {
            bottomNavigationController.isChatAstroDataLoadedOnce = true;
            bottomNavigationController.update();
            await bottomNavigationController.getAstrologerList(
                skills: bottomNavigationController.skillFilterList,
                gender: bottomNavigationController.genderFilterList,
                language: bottomNavigationController.languageFilter,
                sortBy: bottomNavigationController.sortingFilter,
                isLazyLoading: true);
            bottomNavigationController.isChatAstroDataLoadedOnce = false;
            bottomNavigationController.update();
          }
        } else {
          bottomNavigationController.astrologerList = [];
          bottomNavigationController.astrologerList.clear();
          bottomNavigationController.isAllDataLoaded = false;
          bottomNavigationController.update();
          await bottomNavigationController.astroCat(
              id: bottomNavigationController.selectedCatId!,
              isLazyLoading: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    paginateTask();
    return ListView.builder(
      itemCount: astrologerList.length,
      controller: chatScrollController,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            Get.find<ReviewController>()
                .getReviewData(astrologerList[index].id);
            global.showOnlyLoaderDialog(context);
            await bottomNavigationController
                .getAstrologerbyId(astrologerList[index].id);
            global.hideLoader();
            Get.to(() => AstrologerProfile(
                  index: index,
                ));
          },
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 10),
                              //   child: Container(
                              //     height: 65,
                              //     width: 65,
                              //     decoration: BoxDecoration(
                              //       border: Border.all(
                              //           color: Get.theme.primaryColor),
                              //       borderRadius: BorderRadius.circular(7),
                              //     ),
                              //     child: CircleAvatar(
                              //       radius: 35,
                              //       backgroundColor: Colors.white,
                              //       child: CachedNetworkImage(
                              //         height: 55,
                              //         width: 55,
                              //         imageUrl:
                              //             '${global.imgBaseurl}${astrologerList[index].profileImage}',
                              //         placeholder: (context, url) =>
                              //             const Center(
                              //                 child:
                              //                     CircularProgressIndicator()),
                              //         errorWidget: (context, url, error) =>
                              //             Image.asset(
                              //           Images.deafultUser,
                              //           fit: BoxFit.cover,
                              //           height: 50,
                              //           width: 40,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              Container(
                                height: 14.h,
                                width: 12.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2.w),
                                  child: CachedNetworkImage(
                                    height: 14.h,
                                    width: 12.h,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        '${global.imgBaseurl}${astrologerList[index].profileImage}',
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      Images.deafultUser,
                                      fit: BoxFit.cover,
                                      height: 14.h,
                                      width: 12.h,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 1.w,
                                right: 1.w,
                                left: 1.w,
                                child: Container(
                                  width: 12.h,
                                  height: 3.5.h,
                                  decoration: BoxDecoration(
                                    color: getRandomColor(index),
                                    borderRadius: BorderRadius.circular(1.w),
                                  ),
                                  child: Center(
                                    child: Text(
                                      astrologerList[index]
                                          .allSkill
                                          .split(',')[0],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    astrologerList[index].name,
                                  ).tr(),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Image.asset(
                                    Images.right,
                                    height: 16,
                                  )
                                ],
                              ),
                              astrologerList[index].allSkill == ""
                                  ? const SizedBox()
                                  : Text(
                                      astrologerList[index].allSkill,
                                      style: Get
                                          .theme.primaryTextTheme.bodySmall!
                                          .copyWith(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.grey[600],
                                      ),
                                    ).tr(),
                              astrologerList[index].languageKnown == ""
                                  ? const SizedBox()
                                  : Text(
                                      astrologerList[index].languageKnown,
                                      style: Get
                                          .theme.primaryTextTheme.bodySmall!
                                          .copyWith(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.grey[600],
                                      ),
                                    ).tr(),
                              Text(
                                'Experience : ${astrologerList[index].experienceInYears} Years',
                                style: Get.theme.primaryTextTheme.bodySmall!
                                    .copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey[600],
                                ),
                              ).tr(),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(0)),
                              fixedSize:
                                  MaterialStateProperty.all(Size.fromWidth(90)),
                              backgroundColor: astrologerList[index]
                                          .chatStatus ==
                                      "Online"
                                  ? MaterialStateProperty.all(Colors.lightBlue)
                                  : MaterialStateProperty.all(
                                      Colors.orangeAccent),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              bool isLogin = await global.isLogin();
                              if (isLogin) {
                                await bottomNavigationController
                                    .getAstrologerbyId(
                                        astrologerList[index].id);
                                if (astrologerList[index].charge * 5 <=
                                        global.splashController.currentUser!
                                            .walletAmount ||
                                    astrologerList[index].isFreeAvailable ==
                                        true) {
                                  await bottomNavigationController
                                      .checkAlreadyInReq(
                                          astrologerList[index].id);
                                  if (bottomNavigationController
                                          .isUserAlreadyInChatReq ==
                                      false) {
                                    if (astrologerList[index].chatStatus ==
                                        "Online") {
                                      global.showOnlyLoaderDialog(context);

                                      if (astrologerList[index].chatWaitTime !=
                                          null) {
                                        if (astrologerList[index]
                                                .chatWaitTime!
                                                .difference(DateTime.now())
                                                .inMinutes <
                                            0) {
                                          await bottomNavigationController
                                              .changeOfflineStatus(
                                                  astrologerList[index].id,
                                                  "Online");
                                        }
                                      }
                                      await Get.to(() => CallIntakeFormScreen(
                                            type: "Chat",
                                            astrologerId:
                                                astrologerList[index].id,
                                            astrologerName:
                                                astrologerList[index].name,
                                            astrologerProfile:
                                                astrologerList[index]
                                                    .profileImage,
                                            isFreeAvailable:
                                                astrologerList[index]
                                                    .isFreeAvailable,
                                        rate:astrologerList[index].charge.toString() ,
                                          ));
                                      global.hideLoader();
                                    } else if (astrologerList[index]
                                                .chatStatus ==
                                            "Offline" ||
                                        astrologerList[index].chatStatus ==
                                            "Busy" ||
                                        astrologerList[index].chatStatus ==
                                            "Wait Time") {
                                      bottomNavigationController
                                          .dialogForJoinInWaitList(
                                              context,
                                              astrologerList[index].name,
                                              true,
                                              bottomNavigationController
                                                  .astrologerbyId[0].chatStatus
                                                  .toString(),
                                              astrologerList[index]
                                                  .profileImage);
                                    }
                                  } else {
                                    bottomNavigationController
                                        .dialogForNotCreatingSession(context);
                                  }
                                } else {
                                  global.showOnlyLoaderDialog(context);
                                  await walletController.getAmount();
                                  global.hideLoader();
                                  openBottomSheetRechrage(
                                      context,
                                      (astrologerList[index].charge * 5)
                                          .toString(),
                                      astrologerList[index].name);
                                }
                              }
                            },
                            child: astrologerList[index].isFreeAvailable == true
                                ? Text(
                                    'FREE',
                                    style: Get.theme.textTheme.titleMedium!
                                        .copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0,
                                            color: Colors.white
                                            //Color.fromARGB(255, 167, 1, 1),
                                            ),
                                  ).tr()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        CupertinoIcons.chat_bubble_fill,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${astrologerList[index].charge}/min',
                                        style: Get.theme.textTheme.titleMedium!
                                            .copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0,
                                          decoration: astrologerList[index]
                                                      .isFreeAvailable ==
                                                  true
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: astrologerList[index]
                                                      .isFreeAvailable ==
                                                  true
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ).tr(),
                                    ],
                                  ),
                          ),
                          astrologerList[index].chatStatus == "Offline"
                              ? Text(
                                  "Currently Offline",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 09),
                                ).tr()
                              : astrologerList[index].chatStatus == "Wait Time"
                                  ? Text(
                                      astrologerList[index]
                                                  .chatWaitTime!
                                                  .difference(DateTime.now())
                                                  .inMinutes >
                                              0
                                          ? "Wait till - ${astrologerList[index].chatWaitTime!.difference(DateTime.now()).inMinutes} min"
                                          : "Wait till",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 09),
                                    ).tr()
                                  : (astrologerList[index].chatStatus == "Busy"
                                      ? Text(
                                          "Currently Busy",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 09),
                                        ).tr()
                                      : SizedBox()),
                          RatingBar.builder(
                            initialRating: 0,
                            itemCount: 5,
                            allowHalfRating: false,
                            itemSize: 15,
                            ignoreGestures: true,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Get.theme.primaryColor,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                          astrologerList[index].totalOrder == 0 ||
                                  astrologerList[index].totalOrder == null
                              ? SizedBox()
                              : Text(
                                  '${astrologerList[index].totalOrder} orders',
                                  style: Get.theme.primaryTextTheme.bodySmall!
                                      .copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 9,
                                  ),
                                ).tr()
                        ],
                      )
                    ],
                  ),
                ),
              ),
              bottomNavigationController.isMoreDataAvailable == true &&
                      !bottomNavigationController.isAllDataLoaded &&
                      astrologerList.length - 1 == index
                  ? Column(
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )
                  : const SizedBox(),
              if (index == astrologerList.length - 1)
                const SizedBox(
                  height: 30,
                )
            ],
          ),
        );
      },
    );
  }

  void openBottomSheetRechrage(
      BuildContext context, String minBalance, String astrologer) {
    Get.bottomSheet(
      Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.85,
                                    child: minBalance != ''
                                        ? Text('Minimum balance of 5 minutes(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) is required to start chat with $astrologer ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red))
                                            .tr()
                                        : const SizedBox(),
                                  ),
                                  GestureDetector(
                                    child: Padding(
                                      padding: minBalance == ''
                                          ? const EdgeInsets.only(top: 8)
                                          : const EdgeInsets.only(top: 0),
                                      child: Icon(Icons.close, size: 18),
                                    ),
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 5),
                                child: Text('Recharge Now',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500))
                                    .tr(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Icon(Icons.lightbulb_rounded,
                                        color: Get.theme.primaryColor,
                                        size: 13),
                                  ),
                                  Expanded(
                                      child: Text(
                                              'Tip:90% users recharge for 10 mins or more.',
                                              style: TextStyle(fontSize: 12))
                                          .tr())
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 3.8 / 2.3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: walletController.rechrage.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => PaymentInformationScreen(
                              flag: 0,
                              amount: double.parse(
                                  walletController.payment[index])));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                                child: Text(
                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.rechrage[index]}',
                              style: TextStyle(fontSize: 13),
                            )),
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}
