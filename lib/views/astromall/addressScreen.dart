// ignore_for_file: must_be_immutable

import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/views/astromall/addNewAddressScreen.dart';
import 'package:AstrowayCustomer/views/astromall/productPurchaseScreen.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;


import '../../controllers/astromallController.dart';

import '../../widget/commonAppbar.dart';

class AddressScreen extends StatelessWidget {
  AddressScreen({Key? key}) : super(key: key);
  WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CommonAppBar(
            title: 'Address',
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: Get.width,
                child: GetBuilder<AstromallController>(builder: (astromallController) {
                  return TextButton(
                    onPressed: () async {
                      await astromallController.removeData();
                      Get.to(() => AddNewAddressScreen());
                    },
                    child: Text(
                      'Add new address',
                      style: Get.textTheme.titleLarge,
                    ).tr(),
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.black)),
                      ),
                    ),
                  );
                }),
              ),
              GetBuilder<AstromallController>(builder: (astromallController) {
                return astromallController.userAddress.isEmpty
                    ? Center(
                        child: Text('Please add your address').tr(),
                      )
                    : ListView.builder(
                        itemCount: astromallController.userAddress.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        //padding:,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${astromallController.userAddress[index].name}'),
                                          Text('${astromallController.userAddress[index].flatNo},${astromallController.userAddress[index].locality},${astromallController.userAddress[index].city},${astromallController.userAddress[index].state},${astromallController.userAddress[index].country}'),
                                          Text('${astromallController.userAddress[index].pincode}'),
                                          Text('${astromallController.userAddress[index].phoneNumber}'),
                                          if (astromallController.userAddress[index].phoneNumber2 != "") Text('${astromallController.userAddress[index].phoneNumber2}'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                              onTap: () async {
                                                global.showOnlyLoaderDialog(context);
                                                await astromallController.getEditAddress(index);
                                                astromallController.update();
                                                global.hideLoader();
                                                Get.to(() => AddNewAddressScreen(
                                                      id: astromallController.userAddress[index].id,
                                                    ));
                                              },
                                              child: Icon(Icons.edit)),
                                          TextButton(
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                                              fixedSize: WidgetStateProperty.all(Size.fromWidth(90)),
                                              backgroundColor: WidgetStateProperty.all(Colors.white),
                                              shape: WidgetStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  side: BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onPressed: () async {
                                              double charge = double.parse(astromallController.astroProductbyId[0].amount.toString());
                                              double gst= (astromallController.astroProductbyId[0].amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)))/100;
                                              if (charge + gst <= global.splashController.currentUser!.walletAmount!) {
                                                Get.to(() => OrderPurchaseScreen(amount: double.parse(astromallController.astroProductbyId[0].amount.toString())));
                                              } else {
                                                global.showOnlyLoaderDialog(context);
                                                await walletController.getAmount();
                                                global.hideLoader();
                                                openBottomSheetRechrage(context, (charge + gst).toString());
                                              }
                                            },
                                            child: Text(
                                              'Select',
                                              style: Get.theme.primaryTextTheme.bodySmall!.copyWith(color: Colors.green),
                                            ).tr(),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 2,
                              )
                            ],
                          );
                        });
              })
            ],
          ),
        ),
      ),
    );
  }

  void openBottomSheetRechrage(BuildContext context, String minBalance) {
    Get.bottomSheet(
      Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Padding(
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
                                child: minBalance != '' ? Text('${tr("Minimum balance")} ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance ${tr("is required to get product")}', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red)) : const SizedBox(),
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
