import 'package:AstrowayCustomer/controllers/astromallController.dart';

import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/widget/commonAppbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:AstrowayCustomer/utils/global.dart' as global;


// ignore: must_be_immutable
class OrderPurchaseScreen extends StatelessWidget {
  final double amount;
  final int? flag;
  OrderPurchaseScreen({Key? key, required this.amount, this.flag}) : super(key: key);
  final WalletController walletController = Get.find<WalletController>();
  SplashController splashController = Get.find<SplashController>();
  AstromallController astromallController = Get.find<AstromallController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CommonAppBar(
            title: 'Payment Information',
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GetBuilder<WalletController>(builder: (c) {
            return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Details', style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 15)).tr(),
                        SizedBox(
                          height: 5,
                        ),
                        flag == 1
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${astromallController.astroProductbyId[0].name}'),
                                  Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${double.parse(astromallController.astroProductbyId[0].amount.toString())}'),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount').tr(),
                            Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $amount'),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('GST ${global.getSystemFlagValue(global.systemFlagNameList.gst)}'),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('${amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100}'),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${tr("Total Payable Amount")}', style: Get.textTheme.titleMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${(amount + amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100).toStringAsFixed(2)}', style: Get.textTheme.titleMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ]);
          }),
        ),
      ),
      bottomSheet: SizedBox(
        height: 60,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () async {
              await astromallController.orderRequest(
                addId: astromallController.userAddress[0].id,
                catId: astromallController.astroProductbyId[0].productCategoryId,
                gstPercent: int.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)),
                payAmount: double.parse(astromallController.astroProductbyId[0].amount.toString()),
                payMethod: 'Wallet',
                prodId: astromallController.astroProductbyId[0].id,
                totalPayment: double.parse(astromallController.astroProductbyId[0].amount.toString()) + (double.parse(astromallController.astroProductbyId[0].amount.toString()) * int.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100),
              );
              astromallController.update();
              Get.back();
            },
            child: Text('Proceed to Pay', style: Get.textTheme.titleMedium!.copyWith(fontSize: 12,color: Colors.white)).tr(),
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.all(0)),
              backgroundColor: WidgetStateProperty.all(Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
