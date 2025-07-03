import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/callIntakeFormScreen.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

// ignore: must_be_immutable
class RecommendedAstrologerWidget extends StatelessWidget {
  BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
  WalletController walletController = Get.find<WalletController>();
  final List astrologerList;
  RecommendedAstrologerWidget({
    required this.astrologerList,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border.all(color: Get.theme.primaryColor),
      ),
      padding: EdgeInsets.all(10).copyWith(bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Free Call with recommended astrologers',
                style: Get.theme.primaryTextTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ).tr(),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.grey[350],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemCount: bottomNavigationController.astrologerList.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 1),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(right: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Get.theme.primaryColor,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: CachedNetworkImage(
                                imageUrl: '${global.imgBaseurl}${bottomNavigationController.astrologerList[index].profileImage}',
                                imageBuilder: (context, imageProvider) => CircleAvatar(radius: 35, backgroundImage: imageProvider),
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Image.asset(
                                  Images.deafultUser,
                                  fit: BoxFit.cover,
                                  height: 50,
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          bottomNavigationController.astrologerList[index].name!,
                          textAlign: TextAlign.center,
                          style: Get.theme.textTheme.titleMedium!.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ).tr(),
                        Text(
                          '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${bottomNavigationController.astrologerList[index].charge}/min',
                          textAlign: TextAlign.center,
                          style: Get.theme.textTheme.titleMedium!.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0,
                          ),
                        ).tr(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6).copyWith(top: 5),
                          child: SizedBox(
                            height: 30,
                            child: TextButton(
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                                fixedSize: WidgetStateProperty.all(Size.fromWidth(90)),
                                backgroundColor: WidgetStateProperty.all(Colors.white),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                print("object");
                                bool isLogin = await global.isLogin();
                                if (isLogin) {
                                  double charge = double.parse(bottomNavigationController.astrologerList[index].charge.toString());
                                  if (charge * 5 <= global.splashController.currentUser!.walletAmount!) {
                                    global.showOnlyLoaderDialog(context);
                                    await Get.to(() => CallIntakeFormScreen(
                                          type: "Call",
                                          astrologerId: bottomNavigationController.astrologerList[index].id!,
                                          astrologerName: bottomNavigationController.astrologerList[index].name!,
                                          astrologerProfile: bottomNavigationController.astrologerList[index].profileImage!,
                                      rate:bottomNavigationController.astrologerList[index].charge.toString()! ,
                                        ));
                                    Get.back();
                                    global.hideLoader();
                                  } else {
                                    global.showOnlyLoaderDialog(context);
                                    await walletController.getAmount();
                                    global.hideLoader();
                                    openBottomSheetRechrage(context, (charge * 5).toString(), '${bottomNavigationController.astrologerList[index].name!}');
                                  }
                                }
                              },
                              child: Text(
                                'Call',
                                style: Get.theme.primaryTextTheme.bodySmall!.copyWith(color: Colors.green),
                              ).tr(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void openBottomSheetRechrage(BuildContext context, String minBalance, String astrologer) {
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.85,
                                    child: minBalance != '' ? Text('Minimum balance of 5 minutes(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) is required to start call with $astrologer ', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red)).tr() : const SizedBox(),
                                  ),
                                  GestureDetector(
                                    child: Padding(
                                      padding: minBalance == '' ? const EdgeInsets.only(top: 8) : const EdgeInsets.only(top: 0),
                                      child: Icon(Icons.close, size: 18),
                                    ),
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 5),
                                child: Text('Recharge Now', style: TextStyle(fontWeight: FontWeight.w500)).tr(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Icon(Icons.lightbulb_rounded, color: Get.theme.primaryColor, size: 13),
                                  ),
                                  Expanded(child: Text('Tip:90% users recharge for 10 mins or more.', style: TextStyle(fontSize: 12)).tr())
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          Get.to(() => PaymentInformationScreen(flag: 0, amount: double.parse(walletController.payment[index])));
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
