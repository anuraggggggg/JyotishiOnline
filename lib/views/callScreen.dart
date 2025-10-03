import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';

import 'astrologerProfile/FastApi/astroProfile.dart';

class CallAstrologerScreen extends StatefulWidget {
  const CallAstrologerScreen({Key? key}) : super(key: key);

  @override
  _CallAstrologerScreenState createState() => _CallAstrologerScreenState();
}

class _CallAstrologerScreenState extends State<CallAstrologerScreen> {
  final FastAPIServices _apiService = FastAPIServices();
  late Future<List<dynamic>> _futureAstrologers;
  List<dynamic> _allAstrologers = [];

  static const Color appYellow = Color(0xFFFFC31F);

  @override
  void initState() {
    super.initState();
    _futureAstrologers = _apiService.fetchAllAstrologers();
  }

  Widget _buildAstrologerCard(Map<String, dynamic> astro) {
    final isOnline = astro['isOnline'] ?? false;
    final charge = astro['charge'] ?? 0;
    final astroId = astro['astro_id'] ?? astro['id'] ?? ''; // Get the astrologer ID

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to AstrologerDetailPage when card is tapped
          if (astroId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AstrologerDetailPage(astroId: astroId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Unable to load astrologer details"),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Image + Online Status
              Stack(
                children: [
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: (astro['profileImage'] != null &&
                            astro['profileImage'].toString().isNotEmpty)
                            ? Image.network(
                          astro['profileImage'].toString().startsWith("http")
                              ? astro['profileImage']
                              : "https://fastapi.jyotishionline.com${astro['profileImage']}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: Icon(Icons.person, color: Colors.grey.shade400),
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.person, color: Colors.grey.shade400),
                        ),
                      )
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Name + Skill + Charge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      astro['name'] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${astro['primarySkill'] ?? 'Astrologer'} • ${astro['experienceInYears'] ?? 0} yrs exp",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹$charge",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Call Button
              IconButton(
                icon: const Icon(Icons.call, color: Colors.green, size: 28),
                onPressed: () {
                  // Navigate to detail page and auto-select call option
                  if (astroId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AstrologerDetailPage(astroId: astroId),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Calling ${astro['name']}..."),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
            ),
            title: Container(
              height: 14,
              color: Colors.grey.shade200,
            ),
            subtitle: Container(
              height: 12,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.only(top: 6),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Call Astrologer",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureAstrologers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No astrologers available"));
          }

          _allAstrologers = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureAstrologers = _apiService.fetchAllAstrologers();
              });
            },
            child: ListView.builder(
              itemCount: _allAstrologers.length,
              itemBuilder: (context, index) {
                return _buildAstrologerCard(_allAstrologers[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
// // ignore_for_file: must_be_immutable, deprecated_member_use



//
//
// import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
// import 'package:AstrowayCustomer/controllers/callController.dart';
// import 'package:AstrowayCustomer/controllers/chatController.dart';
// import 'package:AstrowayCustomer/controllers/filtterTabController.dart';
// import 'package:AstrowayCustomer/controllers/languageController.dart';
// import 'package:AstrowayCustomer/controllers/reportController.dart';
// import 'package:AstrowayCustomer/controllers/skillController.dart';
// import 'package:AstrowayCustomer/controllers/walletController.dart';
// import 'package:AstrowayCustomer/theme/appTheme.dart';
// import 'package:AstrowayCustomer/utils/AppColors.dart';
// import 'package:AstrowayCustomer/utils/images.dart';
// import 'package:AstrowayCustomer/views/addMoneyToWallet.dart';
// import 'package:AstrowayCustomer/views/call/incoming_call_request.dart';
// import 'package:AstrowayCustomer/views/callIntakeFormScreen.dart';
// import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
// import 'package:AstrowayCustomer/views/searchAstrologerScreen.dart';
// import 'package:AstrowayCustomer/widget/customAppbarWidget.dart';
// import 'package:AstrowayCustomer/widget/drawerWidget.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:AstrowayCustomer/utils/global.dart' as global;
// import 'package:responsive_sizer/responsive_sizer.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../controllers/reviewController.dart';
// import 'astrologerProfile/astrologerProfile.dart';
// import 'call/oneToOneVideo/onetooneVideo.dart';
//
// class CallScreen extends StatefulWidget {
//   int flag;
//
//   CallScreen({super.key, required this.flag});
//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }
//
// class _CallScreenState extends State<CallScreen> {
//   final drawerKey = new GlobalKey<ScaffoldState>();
//   FiltterTabController filtterTabController = Get.find<FiltterTabController>();
//
//   SkillController skillController = Get.find<SkillController>();
//
//   LanguageController languageController = Get.find<LanguageController>();
//
//   ReportController reportController = Get.find<ReportController>();
//
//   ChatController chatController = Get.find<ChatController>();
//   CallController callController = Get.find<CallController>();
//
//   BottomNavigationController bottomNavigationController =
//       Get.find<BottomNavigationController>();
//   WalletController walletController = Get.find<WalletController>();
//
//   @override
//   void initState() {
//     init();
//     super.initState();
//   }
//
//   init() async {
//     global.sp = await SharedPreferences.getInstance();
//     await global.sp!.reload();
//     global.sp = global.sp;
//     print("callScreenCall");
//     print("${global.sp!.getInt('callBottom')}");
//     if (global.sp!.getInt('callBottom') == 1) {
//       callController.callBottom = true;
//       callController.update();
//     } else {
//       callController.callBottom = false;
//       callController.update();
//     }
//     print(global.sp);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         key: drawerKey,
//         drawer: DrawerWidget(),
//         appBar: CustomAppBar(
//           flagforCategory: widget.flag,
//           flagId: 1,
//           onBackPressed: () {},
//           scaffoldKey: drawerKey,
//           title: 'Call with Astrologer',
//           titleStyle: Get.theme.primaryTextTheme.titleSmall!.copyWith(
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//           ),
//           bgColor: Colors.white,
//
//
//           actions: [
//             Flex(
//               direction: Axis.horizontal,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 global.splashController.currentUser?.walletAmount != null
//                     ? InkWell(
//                         onTap: () async {
//                           global.showOnlyLoaderDialog(context);
//                           await walletController.getAmount();
//                           global.hideLoader();
//                           Get.to(() => AddmoneyToWallet());
//                         },
//                         child: Container(
//                           padding: EdgeInsets.all(2),
//                           margin: EdgeInsets.symmetric(vertical: 17),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.black),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           alignment: Alignment.center,
//                           child: Row(
//                             children: [
//                               Image.asset("assets/images/wallet1.png", height: 20, width: 20,),
//                               SizedBox(
//                                   width :8
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 3, right: 3),
//                                 child: Text(
//                                   '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)}${global.splashController.currentUser?.walletAmount.toString()}',
//                                   style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       )
//                     : SizedBox(),
//               ],
//             ),
//             GestureDetector(
//               onTap: () {
//                 Get.to(() => SearchAstrologerScreen(
//                       type: 'Call',
//                     ));
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10, right: 10),
//                 child: Icon(FontAwesomeIcons.magnifyingGlass,
//                     size: 15, color: Colors.black //Get.theme.iconTheme.color,
//                     ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 openBottomSheetFilter(context);
//                 skillController.getSkills();
//                 languageController.getLanguages();
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 10),
//                 child: Stack(
//                   clipBehavior: Clip.none,
//                   alignment: Alignment.center,
//                   children: [
//                     Icon(FontAwesomeIcons.filter,
//                         size: 15,
//                         color: Colors.black //Get.theme.iconTheme.color,
//                         ),
//                     bottomNavigationController.applyFilter
//                         ? Positioned(
//                             right: 0,
//                             top: 15,
//                             child: CircleAvatar(
//                               backgroundColor: Colors.blue,
//                               radius: 4,
//                             ),
//                           )
//                         : const SizedBox(),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//         body: GetBuilder<CallController>(
//           builder: (callController) {
//             return DefaultTabController(
//               length: chatController.categoryList.length,
//               child: Column(
//                 children: [
//                   TabBar(
//                     padding: EdgeInsets.only(top: 10),
//                     controller: chatController.categoryTab,
//                     isScrollable: true,
//                     onTap: (value) async {
//                       chatController.isSelected = value;
//                       if (value == 0) {
//                         bottomNavigationController.astrologerList = [];
//                         bottomNavigationController.astrologerList.clear();
//                         bottomNavigationController.isAllDataLoaded = false;
//                         bottomNavigationController.update();
//                         global.showOnlyLoaderDialog(context);
//                         await bottomNavigationController.getAstrologerList(
//                             isLazyLoading: false);
//                         global.hideLoader();
//                       } else {
//                         for (var i = 0;
//                             i < chatController.categoryList.length;
//                             i++) {
//                           if (value == i) {
//                             bottomNavigationController.astrologerList = [];
//                             bottomNavigationController.astrologerList.clear();
//                             bottomNavigationController.isAllDataLoaded = false;
//                             bottomNavigationController.update();
//                             global.showOnlyLoaderDialog(context);
//                             await bottomNavigationController.astroCat(
//                                 id: chatController.categoryList[i].id!,
//                                 isLazyLoading: false);
//                             global.hideLoader();
//                           }
//                         }
//                       }
//                       chatController.update();
//                     },
//                     indicatorColor: Colors.transparent,
//                     labelPadding: EdgeInsets.only(right: 5),
//                     tabs: List.generate(chatController.categoryList.length,
//                         (index) {
//                       return GetBuilder<ChatController>(builder: (chatco) {
//                         return SizedBox(
//                           height: 30,
//                           child: Chip(
//                             padding: EdgeInsets.only(bottom: 5),
//                             backgroundColor: chatController.isSelected == index
//                                 ? appYellow
//                                 : Colors.white,
//                             shape: RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   color: chatController.isSelected == index
//                                       ? Get.theme.primaryColor
//                                       : Colors.transparent,
//                                 ),
//                                 borderRadius: BorderRadius.circular(7)),
//                             label: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 5),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CachedNetworkImage(
//                                     height: 20,
//                                     width: 20,
//                                     imageUrl:
//                                         '${global.imgBaseurl}${chatController.categoryList[index].image}',
//                                     placeholder: (context, url) => const Center(
//                                         child: CircularProgressIndicator()),
//                                     errorWidget: (context, url, error) =>
//                                         Icon(Icons.grid_view_rounded, size: 20, color: Colors.black,),
//                                   ),
//                                   SizedBox(width: 5),
//                                   Text(
//                                     chatController.categoryList[index].name,
//                                     style: Get.theme.primaryTextTheme.bodySmall!
//                                         .copyWith(fontWeight: FontWeight.w300),
//                                   ).tr(),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       });
//                     }),
//                   ),
//                   GetBuilder<BottomNavigationController>(builder: (b) {
//                     return bottomNavigationController.astrologerList.length == 0
//                         ? Container(
//                             //NO ASTROLOGER IN THIS CATEGORY
//                             height: 500,
//                             child: Center(
//                               child: Text(
//                                 'Astrologer not available',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w400, fontSize: 18),
//                               ).tr(),
//                             ),
//                           )
//                         : Expanded(
//                             child: TabBarView(
//                             controller: chatController.categoryTab,
//                             physics: const NeverScrollableScrollPhysics(),
//                             children: List.generate(
//                                 chatController.categoryList.length, (index) {
//                               return RefreshIndicator(
//                                 onRefresh: () async {
//                                   bottomNavigationController.astrologerList =
//                                       [];
//                                   bottomNavigationController.astrologerList
//                                       .clear();
//                                   bottomNavigationController.isAllDataLoaded =
//                                       false;
//                                   if (bottomNavigationController
//                                           .genderFilterList !=
//                                       null) {
//                                     bottomNavigationController.genderFilterList!
//                                         .clear();
//                                   }
//                                   if (bottomNavigationController
//                                           .languageFilter !=
//                                       null) {
//                                     bottomNavigationController.languageFilter!
//                                         .clear();
//                                   }
//                                   if (bottomNavigationController
//                                           .skillFilterList !=
//                                       null) {
//                                     bottomNavigationController.skillFilterList!
//                                         .clear();
//                                   }
//                                   bottomNavigationController.applyFilter =
//                                       false;
//                                   bottomNavigationController.update();
//                                   await bottomNavigationController
//                                       .getAstrologerList(isLazyLoading: false);
//                                 },
//                                 child: TabViewAstrologer(
//                                   astrologerList:
//                                       bottomNavigationController.astrologerList,
//                                 ),
//                               );
//                             }),
//                           ));
//                   }),
//                 ],
//               ),
//             );
//           },
//         ),
//         bottomSheet: GetBuilder<CallController>(builder: (callController) {
//           return callController.callBottom
//               ? Container(
//                   color: Get.theme.primaryColor,
//                   height: 40,
//                   width: Get.width,
//                   padding: const EdgeInsets.all(8),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(global.sp!
//                                         .getString('bottomCallcallType')
//                                         .toString() ==
//                                     "11"
//                                 ? 'Start Video call with ${callController.bottomAstrologerName}'
//                                 : 'Start call with ${callController.bottomAstrologerName}')
//                             .tr(),
//                       ),
//                       TextButton(
//                         style: ButtonStyle(
//                           padding: MaterialStateProperty.all(EdgeInsets.all(0)),
//                           backgroundColor:
//                               MaterialStateProperty.all(Colors.green),
//                           shape: MaterialStateProperty.all(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                         onPressed: () async {
//                           callController.showBottomAcceptCall = false;
//                           callController.callBottom = false;
//                           global.sp!.remove('callBottom');
//                           global.sp!.setInt('callBottom', 0);
//                           callController.callBottom = false;
//                           callController.update();
//                           callController.bottomAstrologerName = global.sp!
//                                   .getString('bottomCallAstrologerName') ??
//                               '';
//                           callController.bottomAstrologerProfile = global.sp!
//                                   .getString('bottomCallAstrologerProfile') ??
//                               '';
//                           callController.bottomCallId =
//                               global.sp!.getInt('bottomCallId');
//                           callController.bottomChannel =
//                               global.sp!.getString('bottomCallChannel');
//                           callController.bottomAstrologerId =
//                               global.sp!.getInt('bottomCallAstrologerId');
//                           callController.bottomToken =
//                               global.sp!.getString('bottomCallToken');
//                           callController.bottomFcmToken =
//                               global.sp!.getString('bottomCallFcmToken');
//                           callController.callType =
//                               global.sp!.getString('bottomCallcallType')!;
//                           callController.update();
//                           callController.callType.toString() == "11"
//                               ? Get.to(() =>
//                                   // OneToOneLiveScreen():
//                                   OneToOneLiveScreen(
//                                     channelname: callController.bottomChannel!,
//                                     callId: callController.bottomCallId!,
//                                     fcmToken: callController.bottomFcmToken!,
//                                     end_time:
//                                         callController.duration.toString(),
//                                   ))
//                               : Get.to(() => IncomingCallRequest(
//                                     astrologerName:
//                                         callController.bottomAstrologerName,
//                                     astrologerProfile:
//                                         callController.bottomAstrologerProfile,
//                                     callId: callController.bottomCallId!,
//                                     channel: callController.bottomChannel!,
//                                     token: callController.bottomToken!,
//                                     astrologerId:
//                                         callController.bottomAstrologerId!,
//                                     fcmToken: callController.bottomFcmToken!,
//                                     duration:
//                                         callController.duration.toString(),
//                                   ));
//                         },
//                         child: Text(
//                           'Start',
//                           style: Get.theme.primaryTextTheme.bodySmall!
//                               .copyWith(color: Colors.white),
//                         ).tr(),
//                       ),
//                     ],
//                   ),
//                 )
//               : const SizedBox();
//         }),
//       ),
//     );
//   }
//
//   void openBottomSheetFilter(BuildContext context) {
//     Get.bottomSheet(
//       Container(
//         height: MediaQuery.of(context).size.height * 0.6,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height * 0.09,
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text('Sort & Filter').tr(),
//                         Expanded(
//                           child: Align(
//                             alignment: Alignment.topRight,
//                             child: IconButton(
//                               onPressed: () {
//                                 Get.back();
//                               },
//                               icon: Icon(Icons.close),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Divider(thickness: 2, height: 0),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Row(
//                 children: [
//                   Obx(
//                     () => RotatedBox(
//                       quarterTurns: 1,
//                       child: TabBar(
//                         isScrollable: true,
//                         indicatorSize: TabBarIndicatorSize.label,
//                         controller: filtterTabController.filterTab,
//                         indicatorColor: Colors.pink,
//                         indicatorPadding: EdgeInsets.zero,
//                         labelPadding: EdgeInsets.zero,
//                         indicator: BoxDecoration(),
//                         indicatorWeight: 0,
//                         unselectedLabelColor: Colors.grey[50],
//                         onTap: (index) {
//                           filtterTabController.selectedFilterIndex.value =
//                               index;
//                           filtterTabController.update();
//                         },
//                         tabs: List.generate(
//                           filtterTabController.filtterList.length,
//                           (ind) {
//                             return RotatedBox(
//                               quarterTurns: -1,
//                               child: Container(
//                                 color: filtterTabController
//                                             .selectedFilterIndex.value ==
//                                         ind
//                                     ? Colors.white
//                                     : Colors.green[100],
//                                 height: 50,
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       width: 5,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(5),
//                                           bottomRight: Radius.circular(5),
//                                         ),
//                                         color: filtterTabController
//                                                     .selectedFilterIndex
//                                                     .value ==
//                                                 ind
//                                             ? Colors.white
//                                             : Colors.green,
//                                       ),
//                                     ),
//                                     Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.25,
//                                       alignment: Alignment.centerLeft,
//                                       padding:
//                                           EdgeInsets.symmetric(horizontal: 8),
//                                       child: Text(
//                                         filtterTabController.filtterList[ind],
//                                         style: TextStyle(color: Colors.black54),
//                                       ).tr(),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                       child: RotatedBox(
//                     quarterTurns: 1,
//                     child: TabBarView(
//                       controller: filtterTabController.filterTab,
//                       children: [
//                         SizedBox(
//                             child: RotatedBox(
//                           quarterTurns: -1,
//                           child: GetBuilder<ReportController>(
//                             builder: (rpcont) {
//                               return GetBuilder<SkillController>(
//                                 builder: (c) {
//                                   return Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 10),
//                                       child: ListView.builder(
//                                           itemCount:
//                                               reportController.sorting.length,
//                                           padding: EdgeInsets.zero,
//                                           itemBuilder: (context, index) {
//                                             return RadioListTile(
//                                               groupValue:
//                                                   reportController.groupValue,
//                                               controlAffinity:
//                                                   ListTileControlAffinity
//                                                       .leading,
//                                               contentPadding: EdgeInsets.zero,
//                                               activeColor: Colors.black,
//                                               value: reportController
//                                                   .sorting[index].id,
//                                               onChanged: (val) {
//                                                 reportController.groupValue =
//                                                     val!;
//
//                                                 reportController.update();
//                                               },
//                                               title: Text(reportController
//                                                       .sorting[index].name!)
//                                                   .tr(),
//                                             );
//                                           }));
//                                 },
//                               );
//                             },
//                           ),
//                         )),
//                         SizedBox(
//                             child: RotatedBox(
//                           quarterTurns: -1,
//                           child: GetBuilder<SkillController>(
//                             builder: (c) {
//                               return Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 10),
//                                   child: ListView.builder(
//                                       itemCount:
//                                           skillController.skillList.length,
//                                       padding: EdgeInsets.zero,
//                                       itemBuilder: (context, index) {
//                                         return CheckboxListTile(
//                                           controlAffinity:
//                                               ListTileControlAffinity.leading,
//                                           contentPadding: EdgeInsets.zero,
//                                           activeColor: Colors.black,
//                                           value: skillController
//                                               .skillList[index].isSelected,
//                                           onChanged: (value) {
//                                             skillController.skillList[index]
//                                                 .isSelected = value!;
//                                             skillController.update();
//                                           },
//                                           title: Text(skillController
//                                                   .skillList[index].name)
//                                               .tr(),
//                                         );
//                                       }));
//                             },
//                           ),
//                         )),
//                         SizedBox(
//                             child: RotatedBox(
//                           quarterTurns: -1,
//                           child: GetBuilder<LanguageController>(
//                             builder: (c) {
//                               return Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 10),
//                                   child: ListView.builder(
//                                       itemCount: languageController
//                                           .languageList.length,
//                                       padding: EdgeInsets.zero,
//                                       itemBuilder: (context, index) {
//                                         return CheckboxListTile(
//                                           controlAffinity:
//                                               ListTileControlAffinity.leading,
//                                           contentPadding: EdgeInsets.zero,
//                                           activeColor: Colors.black,
//                                           value: languageController
//                                               .languageList[index].isSelected,
//                                           onChanged: (value) {
//                                             languageController
//                                                 .languageList[index]
//                                                 .isSelected = value!;
//                                             languageController.update();
//                                           },
//                                           title: Text(languageController
//                                                   .languageList[index]
//                                                   .languageName)
//                                               .tr(),
//                                         );
//                                       }));
//                             },
//                           ),
//                         )),
//                         SizedBox(
//                             child: RotatedBox(
//                           quarterTurns: -1,
//                           child: GetBuilder<FiltterTabController>(builder: (c) {
//                             return Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 10),
//                                 child: ListView.builder(
//                                     itemCount:
//                                         filtterTabController.gender.length,
//                                     padding: EdgeInsets.zero,
//                                     itemBuilder: (context, index) {
//                                       return CheckboxListTile(
//                                         controlAffinity:
//                                             ListTileControlAffinity.leading,
//                                         contentPadding: EdgeInsets.zero,
//                                         activeColor: Colors.black,
//                                         value: filtterTabController
//                                             .gender[index].isCheck,
//                                         onChanged: (value) {
//                                           filtterTabController
//                                               .gender[index].isCheck = value!;
//                                           filtterTabController.update();
//                                         },
//                                         title: Text(filtterTabController
//                                                 .gender[index].name)
//                                             .tr(),
//                                       );
//                                     }));
//                           }),
//                         )),
//                         SizedBox()
//                       ],
//                     ),
//                   ))
//                 ],
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Divider(thickness: 2),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Expanded(
//                             child: SizedBox(
//                           width: 0,
//                           child: TextButton(
//                             onPressed: () async {
//                               skillController.skillFilterList = [];
//                               filtterTabController.genderFilterList = [];
//                               languageController.languageFilterList = [];
//                               reportController.sortingFilter = null;
//                               for (var i = 0;
//                                   i < skillController.skillList.length;
//                                   i++) {
//                                 skillController.skillList[i].isSelected = false;
//
//                                 skillController.update();
//                               }
//                               for (var i = 0;
//                                   i < languageController.languageList.length;
//                                   i++) {
//                                 languageController.languageList[i].isSelected =
//                                     false;
//
//                                 languageController.update();
//                               }
//                               for (var i = 0;
//                                   i < filtterTabController.gender.length;
//                                   i++) {
//                                 filtterTabController.gender[i].isCheck = false;
//
//                                 filtterTabController.update();
//                               }
//                               Get.back();
//                               bottomNavigationController.astrologerList = [];
//                               bottomNavigationController.astrologerList.clear();
//                               bottomNavigationController.isAllDataLoaded =
//                                   false;
//                               bottomNavigationController.skillFilterList =
//                                   skillController.skillFilterList;
//                               bottomNavigationController.genderFilterList =
//                                   filtterTabController.genderFilterList;
//                               bottomNavigationController.languageFilter =
//                                   languageController.languageFilterList;
//                               bottomNavigationController.applyFilter = false;
//                               bottomNavigationController.update();
//                               global.showOnlyLoaderDialog(context);
//                               await bottomNavigationController
//                                   .getAstrologerList(
//                                       skills: skillController.skillFilterList,
//                                       gender:
//                                           filtterTabController.genderFilterList,
//                                       language: languageController
//                                           .languageFilterList);
//
//                               global.hideLoader();
//                               reportController.groupValue = 0;
//                               print('done');
//                               reportController.update();
//                             },
//                             child: Text(
//                               'Reset',
//                               style: TextStyle(color: Colors.black54),
//                             ).tr(),
//                           ),
//                         )),
//                         Expanded(child: GetBuilder<SkillController>(
//                           builder: (controller) {
//                             return SizedBox(
//                               width: 80,
//                               height: 55,
//                               child: TextButton(
//                                 onPressed: () async {
//                                   skillController.skillFilterList = [];
//                                   filtterTabController.genderFilterList = [];
//                                   languageController.languageFilterList = [];
//                                   reportController.sortingFilter = null;
//
//                                   for (var i = 0;
//                                       i < skillController.skillList.length;
//                                       i++) {
//                                     if (skillController
//                                             .skillList[i].isSelected ==
//                                         true) {
//                                       skillController.skillFilterList.add(
//                                           skillController.skillList[i].id!);
//                                       skillController.update();
//                                     }
//                                   }
//                                   for (var i = 0;
//                                       i < filtterTabController.gender.length;
//                                       i++) {
//                                     if (filtterTabController
//                                             .gender[i].isCheck ==
//                                         true) {
//                                       filtterTabController.genderFilterList.add(
//                                           filtterTabController.gender[i].name);
//                                       filtterTabController.update();
//                                     }
//                                   }
//                                   for (var i = 0;
//                                       i <
//                                           languageController
//                                               .languageList.length;
//                                       i++) {
//                                     if (languageController
//                                             .languageList[i].isSelected ==
//                                         true) {
//                                       languageController.languageFilterList.add(
//                                           languageController
//                                               .languageList[i].id!);
//                                       languageController.update();
//                                     }
//                                   }
//                                   for (var i = 0;
//                                       i < reportController.sorting.length;
//                                       i++) {
//                                     if (reportController.groupValue ==
//                                         reportController.sorting[i].id) {
//                                       reportController.sortingFilter =
//                                           reportController.sorting[i].value;
//                                       reportController.update();
//                                     }
//                                   }
//                                   Get.back();
//                                   global.showOnlyLoaderDialog(context);
//                                   bottomNavigationController.astrologerList =
//                                       [];
//                                   bottomNavigationController.astrologerList
//                                       .clear();
//                                   bottomNavigationController.isAllDataLoaded =
//                                       false;
//                                   bottomNavigationController.applyFilter = true;
//                                   bottomNavigationController.skillFilterList =
//                                       skillController.skillFilterList;
//                                   bottomNavigationController.genderFilterList =
//                                       filtterTabController.genderFilterList;
//                                   bottomNavigationController.languageFilter =
//                                       languageController.languageFilterList;
//                                   bottomNavigationController.sortingFilter =
//                                       reportController.sortingFilter;
//                                   bottomNavigationController.update();
//                                   await bottomNavigationController
//                                       .getAstrologerList(
//                                           skills:
//                                               skillController.skillFilterList,
//                                           gender: filtterTabController
//                                               .genderFilterList,
//                                           language: languageController
//                                               .languageFilterList,
//                                           sortBy:
//                                               reportController.sortingFilter);
//                                   global.hideLoader();
//                                 },
//                                 child: Text('Apply').tr(),
//                                 style: ButtonStyle(
//                                   padding: MaterialStateProperty.all(
//                                       EdgeInsets.all(8)),
//                                   backgroundColor: MaterialStateProperty.all(
//                                       Get.theme.primaryColor),
//                                   foregroundColor:
//                                       MaterialStateProperty.all(Colors.black),
//                                   shape: MaterialStateProperty.all(
//                                     RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       barrierColor: Colors.black.withOpacity(0.8),
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//     );
//   }
// }
//
// class TabViewAstrologer extends StatelessWidget {
//   final List astrologerList;
//   TabViewAstrologer({
//     required this.astrologerList,
//     Key? key,
//   }) : super(key: key);
//   WalletController walletController = Get.find<WalletController>();
//   BottomNavigationController bottomNavigationController =
//       Get.find<BottomNavigationController>();
//   ScrollController callScrollController = ScrollController();
//
//   void paginateTask() {
//     callScrollController.addListener(() async {
//       if (callScrollController.position.pixels ==
//               callScrollController.position.maxScrollExtent &&
//           !bottomNavigationController.isAllDataLoaded) {
//         bottomNavigationController.isMoreDataAvailable = true;
//         bottomNavigationController.update();
//         if (bottomNavigationController.selectedCatId == null ||
//             bottomNavigationController.selectedCatId! == 0) {
//           if (bottomNavigationController.isCallAstroDataLoadedOnce == false) {
//             bottomNavigationController.isCallAstroDataLoadedOnce = true;
//             bottomNavigationController.update();
//             await bottomNavigationController.getAstrologerList(
//                 skills: bottomNavigationController.skillFilterList,
//                 gender: bottomNavigationController.genderFilterList,
//                 language: bottomNavigationController.languageFilter,
//                 sortBy: bottomNavigationController.sortingFilter,
//                 isLazyLoading: true);
//             bottomNavigationController.isCallAstroDataLoadedOnce = false;
//             bottomNavigationController.update();
//           }
//         } else {
//           bottomNavigationController.astrologerList = [];
//           bottomNavigationController.astrologerList.clear();
//           bottomNavigationController.isAllDataLoaded = false;
//           bottomNavigationController.update();
//           await bottomNavigationController.astroCat(
//               id: bottomNavigationController.selectedCatId!,
//               isLazyLoading: true);
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     paginateTask();
//     return ListView.builder(
//       controller: callScrollController,
//       itemCount: astrologerList.length,
//       shrinkWrap: true,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () async {
//             Get.find<ReviewController>()
//                 .getReviewData(astrologerList[index].id);
//             global.showOnlyLoaderDialog(context);
//             await bottomNavigationController
//                 .getAstrologerbyId(astrologerList[index].id);
//             global.hideLoader();
//             Get.to(() => AstrologerProfile(
//                   index: index,
//                 ));
//           },
//           child: Column(
//             children: [
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Column(
//                         children: [
//                           Stack(
//                             children: [
//                               // Padding(
//                               //   padding: const EdgeInsets.only(top: 10),
//                               //   child: Container(
//                               //     height: 65,
//                               //     width: 65,
//                               //     decoration: BoxDecoration(
//                               //       border: Border.all(
//                               //           color: Get.theme.primaryColor),
//                               //       borderRadius: BorderRadius.circular(7),
//                               //     ),
//                               //     child: CircleAvatar(
//                               //       radius: 35,
//                               //       backgroundColor: Colors.white,
//                               //       child: CachedNetworkImage(
//                               //         height: 55,
//                               //         width: 55,
//                               //         imageUrl:
//                               //             '${global.imgBaseurl}${astrologerList[index].profileImage}',
//                               //         placeholder: (context, url) =>
//                               //             const Center(
//                               //                 child:
//                               //                     CircularProgressIndicator()),
//                               //         errorWidget: (context, url, error) =>
//                               //             Image.asset(
//                               //           Images.deafultUser,
//                               //           fit: BoxFit.cover,
//                               //           height: 50,
//                               //           width: 40,
//                               //         ),
//                               //       ),
//                               //     ),
//                               //   ),
//                               // ),
//                               Container(
//                                 height: 14.h,
//                                 width: 12.h,
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(2.w),
//                                   child: CachedNetworkImage(
//                                     height: 14.h,
//                                     width: 12.h,
//                                     fit: BoxFit.cover,
//                                     imageUrl:
//                                         '${global.imgBaseurl}${astrologerList[index].profileImage}',
//                                     placeholder: (context, url) => const Center(
//                                         child: CircularProgressIndicator()),
//                                     errorWidget: (context, url, error) =>
//                                         Image.asset(
//                                       Images.deafultUser,
//                                       fit: BoxFit.cover,
//                                       height: 14.h,
//                                       width: 12.h,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 1.w,
//                                 right: 1.w,
//                                 left: 1.w,
//                                 child: Container(
//                                   width: 12.h,
//                                   height: 3.5.h,
//                                   decoration: BoxDecoration(
//                                     color: getRandomColor(index),
//                                     borderRadius: BorderRadius.circular(1.w),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       astrologerList[index]
//                                           .allSkill
//                                           .split(',')[0],
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     astrologerList[index].name,
//                                   ).tr(),
//                                   SizedBox(
//                                     width: 3,
//                                   ),
//                                   Image.asset(
//                                     Images.right,
//                                     height: 18,
//                                   )
//                                 ],
//                               ),
//                               astrologerList[index].allSkill == ""
//                                   ? const SizedBox()
//                                   : Text(
//                                       astrologerList[index].allSkill,
//                                       style: Get
//                                           .theme.primaryTextTheme.bodySmall!
//                                           .copyWith(
//                                         fontWeight: FontWeight.w300,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ).tr(),
//                               astrologerList[index].languageKnown == ""
//                                   ? const SizedBox()
//                                   : Text(
//                                       astrologerList[index].languageKnown,
//                                       style: Get
//                                           .theme.primaryTextTheme.bodySmall!
//                                           .copyWith(
//                                         fontWeight: FontWeight.w300,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ).tr(),
//                               Text(
//                                 'Experience : ${astrologerList[index].experienceInYears} Years',
//                                 style: Get.theme.primaryTextTheme.bodySmall!
//                                     .copyWith(
//                                   fontWeight: FontWeight.w300,
//                                   color: Colors.grey[600],
//                                 ),
//                               ).tr(),
//                               Row(
//                                 children: [
//                                   astrologerList[index].isFreeAvailable == true
//                                       ? Text(
//                                           'FREE',
//                                           style: Get
//                                               .theme.textTheme.titleMedium!
//                                               .copyWith(
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.w500,
//                                             letterSpacing: 0,
//                                             color:
//                                                 Color.fromARGB(255, 167, 1, 1),
//                                           ),
//                                         ).tr()
//                                       : const SizedBox(),
//                                   SizedBox(
//                                     width:
//                                         astrologerList[index].isFreeAvailable ==
//                                                 true
//                                             ? 10
//                                             : 0,
//                                   ),
//                                   Text(
//                                     '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${astrologerList[index].charge}/min',
//                                     style: Get.theme.textTheme.titleMedium!
//                                         .copyWith(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w500,
//                                       letterSpacing: 0,
//                                       decoration: astrologerList[index]
//                                                   .isFreeAvailable ==
//                                               true
//                                           ? TextDecoration.lineThrough
//                                           : null,
//                                       color: astrologerList[index]
//                                                   .isFreeAvailable ==
//                                               true
//                                           ? Colors.grey
//                                           : Color.fromARGB(255, 167, 1, 1),
//                                     ),
//                                   ).tr(),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 80,
//                         width: 80,
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: 4,
//                             ),
//                             Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: Container(
//                                       child: Center(
//                                         child: GetBuilder<CallController>(
//                                           builder:
//                                               (CallController controller) =>
//                                                   InkWell(
//                                             onTap: () async {
//                                               bool isLogin =
//                                                   await global.isLogin();
//
//                                               _logedIn(context, isLogin, index,
//                                                   true,astrologerList[index].charge);
//                                             },
//                                             child: CircleAvatar(
//                                               radius: 18,
//                                               backgroundColor:
//                                                   astrologerList[index]
//                                                               .callStatus ==
//                                                           "Online"
//                                                       ? Colors.green
//                                                       : Colors.orangeAccent,
//                                               child: Center(
//                                                 child: Icon(
//                                                   Icons.call,
//                                                   color: Colors.white,
//                                                   size: 15,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Container(
//                                       child: Center(
//                                         child: GetBuilder<CallController>(
//                                           builder:
//                                               (CallController controller) =>
//                                                   InkWell(
//                                             onTap: () async {
//                                               bool isLogin =
//                                                   await global.isLogin();
//                                               _logedIn(context, isLogin, index,
//                                                   false,astrologerList[index].videoCallRate);
//                                             },
//                                             child: CircleAvatar(
//                                               radius: 18,
//                                               backgroundColor:
//                                                   astrologerList[index]
//                                                               .callStatus ==
//                                                           "Online"
//                                                       ? Colors.redAccent
//                                                       : Colors.orangeAccent,
//                                               child: Center(
//                                                 child: Icon(
//                                                   Icons.video_call,
//                                                   color: Colors.white,
//                                                   size: 15,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ]),
//                             SizedBox(
//                               height: 4,
//                             ),
//                             RatingBar.builder(
//                               initialRating: 0,
//                               itemCount: 5,
//                               allowHalfRating: false,
//                               itemSize: 15,
//                               ignoreGestures: true,
//                               itemBuilder: (context, _) => Icon(
//                                 Icons.star,
//                                 color: Get.theme.primaryColor,
//                               ),
//                               onRatingUpdate: (rating) {},
//                             ),
//                             astrologerList[index].totalOrder == 0 ||
//                                     astrologerList[index].totalOrder == null
//                                 ? SizedBox()
//                                 : Text(
//                                     '${astrologerList[index].totalOrder} orders',
//                                     style: Get.theme.primaryTextTheme.bodySmall!
//                                         .copyWith(
//                                       fontWeight: FontWeight.w300,
//                                       fontSize: 9,
//                                     ),
//                                   ).tr()
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               bottomNavigationController.isMoreDataAvailable == true &&
//                       !bottomNavigationController.isAllDataLoaded &&
//                       astrologerList.length - 1 == index
//                   ? const CircularProgressIndicator()
//                   : const SizedBox(),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void openBottomSheetRechrage(
//       BuildContext context, String minBalance, String astrologer) {
//     Get.bottomSheet(
//       Container(
//         height: 250,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   SizedBox(
//                                     width: Get.width * 0.85,
//                                     child: minBalance != ''
//                                         ? Text('Minimum balance of 5 minutes(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) is required to start call with $astrologer ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.w500,
//                                                     color: Colors.red))
//                                             .tr()
//                                         : const SizedBox(),
//                                   ),
//                                   GestureDetector(
//                                     child: Padding(
//                                       padding: minBalance == ''
//                                           ? const EdgeInsets.only(top: 8)
//                                           : const EdgeInsets.only(top: 0),
//                                       child: Icon(Icons.close, size: 18),
//                                     ),
//                                     onTap: () {
//                                       Get.back();
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.only(top: 8.0, bottom: 5),
//                                 child: Text('Recharge Now',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w500))
//                                     .tr(),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(right: 5),
//                                     child: Icon(Icons.lightbulb_rounded,
//                                         color: Get.theme.primaryColor,
//                                         size: 13),
//                                   ),
//                                   Expanded(
//                                       child: Text(
//                                               'Minimum balance required ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance',
//                                               style: TextStyle(fontSize: 12))
//                                           .tr())
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//                 child: GridView.builder(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 3.8 / 2.3,
//                       crossAxisSpacing: 1,
//                       mainAxisSpacing: 1,
//                     ),
//                     physics: NeverScrollableScrollPhysics(),
//                     padding: EdgeInsets.all(8),
//                     shrinkWrap: true,
//                     itemCount: walletController.rechrage.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           Get.to(() => PaymentInformationScreen(
//                               flag: 0,
//                               amount: double.parse(
//                                   walletController.payment[index])));
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.all(8.0),
//                           child: Container(
//                             height: 30,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Center(
//                                 child: Text(
//                               '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.rechrage[index]}',
//                               style: TextStyle(fontSize: 13),
//                             )),
//                           ),
//                         ),
//                       );
//                     }))
//           ],
//         ),
//       ),
//       barrierColor: Colors.black.withOpacity(0.8),
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   void _logedIn(context, isLogin, index, audio,dynamic charge) async {
//     if (isLogin) {
//       //_checkAstrologerAvailability(index);
//       await bottomNavigationController
//           .getAstrologerbyId(astrologerList[index].id);
//       print('charge${charge}');
//       if (charge * 5 <=
//               global.splashController.currentUser!.walletAmount! ||
//           astrologerList[index].isFreeAvailable == true) {
//         await bottomNavigationController
//             .checkAlreadyInReqForCall(astrologerList[index].id);
//         if (bottomNavigationController.isUserAlreadyInCallReq == false) {
//           if (astrologerList[index].callStatus == "Online") {
//             global.showOnlyLoaderDialog(context);
//             if (astrologerList[index].callWaitTime != null) {
//               if (astrologerList[index]
//                       .callWaitTime!
//                       .difference(DateTime.now())
//                       .inMinutes <
//                   0) {
//                 await bottomNavigationController.changeOfflineCallStatus(
//                     astrologerList[index].id, "Online");
//               }
//             }
//             await Get.to(() => CallIntakeFormScreen(
//                   astrologerProfile: astrologerList[index].profileImage,
//                   type: audio ? "Call" : "Videocall",
//                   astrologerId: astrologerList[index].id,
//                   astrologerName: astrologerList[index].name,
//                   isFreeAvailable: astrologerList[index].isFreeAvailable,
//               rate:audio ? astrologerList[index].charge.toString():astrologerList[index].videoCallRate.toString(),
//                 ));
//
//             global.hideLoader();
//           } else if (astrologerList[index].callStatus == "Offline" ||
//               astrologerList[index].callStatus == "Busy" ||
//               astrologerList[index].callStatus == "Wait Time") {
//             bottomNavigationController.dialogForJoinInWaitList(
//                 context,
//                 astrologerList[index].name,
//                 true,
//                 bottomNavigationController.astrologerbyId[0].callStatus
//                     .toString(),
//                 astrologerList[index].profileImage);
//           }
//         } else {
//           bottomNavigationController.dialogForNotCreatingSession(context);
//         }
//       } else {
//         global.showOnlyLoaderDialog(context);
//         await walletController.getAmount();
//         global.hideLoader();
//         openBottomSheetRechrage(
//             context,
//             (charge * 5).toString(),
//             '${astrologerList[index].name}');
//       }
//     }
//   }
// }


